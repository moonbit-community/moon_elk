///|
let dot_importer_option_separate_connected_components = "org.eclipse.elk.separateConnectedComponents"

///|
let dot_importer_option_random_seed = "org.eclipse.elk.randomSeed"

///|
let dot_importer_option_edge_routing = "org.eclipse.elk.edgeRouting"

///|
let dot_importer_option_node_size_constraints_fixed = "[FIXED]"

///|
let dot_importer_option_node_size_constraints_minimum = "[MINIMUM_SIZE]"

///|
let dot_importer_def_width = 10.0

///|
pub struct DotImporterPropertyHolder {
  layout_options : Map[String, String]
  mut def_width : Double?
  mut def_height : Double?
}

///|
fn new_dot_importer_property_holder() -> DotImporterPropertyHolder {
  { layout_options: {}, def_width: None, def_height: None }
}

///|
fn dot_importer_property_holder_copy(
  source : DotImporterPropertyHolder,
) -> DotImporterPropertyHolder {
  let copied_layout_options : Map[String, String] = {}
  for entry in source.layout_options.to_array() {
    copied_layout_options[entry.0] = entry.1
  }
  {
    layout_options: copied_layout_options,
    def_width: source.def_width,
    def_height: source.def_height,
  }
}

///|
pub struct DotImporter {
  mut node_id_map : Map[String, ElkNode]
  mut port_id_map : Map[String, ElkPort]
  node_statement_map : Map[ElkNode, DotStatement]
  edge_statement_map : Map[ElkEdge, DotEdgeStatement]
  edge_statement_attached : Map[ElkEdge, Bool]
  root_graph_map : Map[ElkNode, DotGraph]
}

///|
pub fn new_dot_importer() -> DotImporter {
  {
    node_id_map: {},
    port_id_map: {},
    node_statement_map: {},
    edge_statement_map: {},
    edge_statement_attached: {},
    root_graph_map: {},
  }
}

///|
fn dot_importer_is_number_char(c : Char) -> Bool {
  (c >= '0' && c <= '9') ||
  c == '-' ||
  c == '+' ||
  c == '.' ||
  c == 'e' ||
  c == 'E'
}

///|
fn dot_importer_parse_numbers(text : String) -> Array[Double] {
  let numbers : Array[Double] = []
  let mut token_start = -1
  let mut index = 0
  while index < text.length() {
    let current = text[index].unsafe_to_char()
    if dot_importer_is_number_char(current) {
      if token_start < 0 {
        token_start = index
      }
    } else if token_start >= 0 {
      match
        dot_exporter_parse_double_token(
          text.substring(start=token_start, end=index),
        ) {
        Some(value) => numbers.push(value)
        None => ()
      }
      token_start = -1
    }
    index += 1
  }
  if token_start >= 0 {
    match dot_exporter_parse_double_token(text.substring(start=token_start)) {
      Some(value) => numbers.push(value)
      None => ()
    }
  }
  numbers
}

///|
fn dot_importer_parse_optional_double(text : String) -> Double? {
  let numbers = dot_importer_parse_numbers(text)
  if numbers.is_empty() {
    None
  } else {
    Some(numbers[0])
  }
}

///|
fn dot_importer_parse_optional_int(text : String) -> Int? {
  match dot_importer_parse_optional_double(text) {
    Some(value) => Some(value.to_int())
    None => None
  }
}

///|
fn dot_importer_parse_padding_value(value : String) -> ElkPadding? {
  if value.contains(",") {
    let numbers = dot_importer_parse_numbers(value)
    if numbers.length() >= 2 {
      Some(
        new_elk_padding_left_right_top_bottom(
          numbers[0] / 2.0,
          numbers[1] / 2.0,
        ),
      )
    } else {
      None
    }
  } else {
    match dot_importer_parse_optional_double(value) {
      Some(number) => Some(new_elk_padding_any(number))
      None => None
    }
  }
}

///|
fn dot_importer_trim_value(attribute : DotAttribute) -> String {
  let value = match attribute.get_value() {
    Some(v) => v
    None => "true"
  }
  if value.length() >= 2 && value.has_prefix("\"") && value.has_suffix("\"") {
    value.substring(start=1, end=value.length() - 1).trim().to_string()
  } else {
    value
  }
}

///|
fn dot_importer_remove_attributes(
  attributes : Array[DotAttribute],
  key : String,
) -> Unit {
  let mut index = attributes.length()
  while index > 0 {
    index -= 1
    if attributes[index].get_name() == Some(key) {
      ignore(attributes.remove(index))
    }
  }
}

///|
fn dot_importer_remove_graph_attributes(
  statements : Array[DotStatement],
  key : String,
) -> Unit {
  let mut index = statements.length()
  while index > 0 {
    index -= 1
    match statements[index] {
      DotStatementAttribute(attribute) =>
        if attribute.get_name() == Some(key) {
          ignore(statements.remove(index))
        }
      DotStatementAttributeStatement(attribute_statement) =>
        if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(dot_attribute_type_graph()) {
          dot_importer_remove_attributes(
            attribute_statement.get_attributes(),
            key,
          )
          if attribute_statement.get_attributes().is_empty() {
            ignore(statements.remove(index))
          }
        }
      _ => ()
    }
  }
}

///|
fn dot_importer_attribute_name(attribute : DotAttribute) -> String? {
  attribute.get_name()
}

///|
fn dot_importer_rankdir_to_direction(value : String) -> String? {
  if value == "TB" {
    Some("DOWN")
  } else if value == "BT" {
    Some("UP")
  } else if value == "LR" {
    Some("RIGHT")
  } else if value == "RL" {
    Some("LEFT")
  } else {
    None
  }
}

///|
fn dot_importer_normalize_edge_routing(value : String) -> String? {
  if value == "spline" || value == "true" {
    Some("SPLINES")
  } else if value == "polyline" || value == "line" || value == "false" {
    Some("POLYLINE")
  } else if value == "ortho" {
    Some("ORTHOGONAL")
  } else {
    None
  }
}

///|
fn dot_importer_algorithm_value(value : String) -> String {
  match command_parse(value) {
    Invalid => value
    command =>
      "org.eclipse.elk.algorithm.graphviz." + command_to_string(command)
  }
}

///|
fn dot_importer_apply_attribute_to_holder(
  holder : DotImporterPropertyHolder,
  attribute : DotAttribute,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
) -> Unit {
  let name = match dot_importer_attribute_name(attribute) {
    Some(v) => v
    None => return
  }
  let value = dot_importer_trim_value(attribute)
  if name == dot_attr_layout {
    holder.layout_options[algorithm.get_id()] = dot_importer_algorithm_value(
      value,
    )
  } else if name == dot_attr_width {
    match dot_importer_parse_optional_double(value) {
      Some(parsed) =>
        holder.def_width = Some(parsed * dot_exporter_dpi.to_double())
      None =>
        trans_data.log(
          "Discarding attribute \{name}=\{value} since its value could not be parsed correctly.",
        )
    }
  } else if name == dot_attr_height {
    match dot_importer_parse_optional_double(value) {
      Some(parsed) =>
        holder.def_height = Some(parsed * dot_exporter_dpi.to_double())
      None =>
        trans_data.log(
          "Discarding attribute \{name}=\{value} since its value could not be parsed correctly.",
        )
    }
  } else if name == dot_attr_fixedsize {
    let normalized = value.to_lower()
    holder.layout_options[node_size_constraints.get_id()] = if normalized ==
      "true" {
      dot_importer_option_node_size_constraints_fixed
    } else {
      dot_importer_option_node_size_constraints_minimum
    }
  } else if name == dot_attr_nodesep {
    match dot_importer_parse_optional_double(value) {
      Some(parsed) =>
        holder.layout_options[spacing_node_node.get_id()] = parsed.to_string()
      None =>
        trans_data.log(
          "Discarding attribute \{name}=\{value} since its value could not be parsed correctly.",
        )
    }
  } else if name == dot_attr_pack {
    holder.layout_options[dot_importer_option_separate_connected_components] = value
  } else if name == dot_attr_pad {
    match dot_importer_parse_padding_value(value) {
      Some(parsed) =>
        holder.layout_options[padding.get_id()] = parsed.to_string()
      None =>
        trans_data.log(
          "Discarding attribute \{name}=\{value} since its value could not be parsed correctly.",
        )
    }
  } else if name == dot_attr_rankdir {
    match dot_importer_rankdir_to_direction(value) {
      Some(parsed) => holder.layout_options[direction.get_id()] = parsed
      None => ()
    }
  } else if name == dot_attr_splines {
    match dot_importer_normalize_edge_routing(value) {
      Some(parsed) =>
        holder.layout_options[dot_importer_option_edge_routing] = parsed
      None => ()
    }
  } else if name == dot_attr_start {
    if value.has_prefix("random") {
      let random_value = match
        dot_importer_parse_optional_int(
          value.substring(start="random".length()),
        ) {
        Some(parsed) => parsed
        None => 0
      }
      holder.layout_options[dot_importer_option_random_seed] = random_value.to_string()
    }
  } else if name == dot_attr_weight {
    match dot_importer_parse_optional_double(value) {
      Some(parsed) =>
        holder.layout_options[priority.get_id()] = parsed.to_int().to_string()
      None =>
        trans_data.log(
          "Discarding attribute \{name}=\{value} since its value could not be parsed correctly.",
        )
    }
  }
}

///|
fn dot_importer_apply_attribute_to_node(
  node : ElkNode,
  attribute : DotAttribute,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
) -> Unit {
  let holder = new_dot_importer_property_holder()
  dot_importer_apply_attribute_to_holder(holder, attribute, trans_data)
  for entry in holder.layout_options.to_array() {
    if entry.0 == algorithm.get_id() {
      node_set_string_property(node, algorithm, entry.1)
    } else if entry.0 == direction.get_id() {
      node_set_string_property(node, direction, entry.1)
    } else if entry.0 == padding.get_id() {
      node_set_string_property(node, padding, entry.1)
    } else if entry.0 == spacing_node_node.get_id() {
      match dot_importer_parse_optional_double(entry.1) {
        Some(parsed) =>
          node_set_double_property(node, spacing_node_node, parsed)
        None => ()
      }
    } else if entry.0 == priority.get_id() {
      match dot_importer_parse_optional_double(entry.1) {
        Some(parsed) => node_set_double_property(node, priority, parsed)
        None => ()
      }
    } else {
      node_set_layout_option_string_by_id(node, entry.0, entry.1)
    }
  }
}

///|
fn dot_importer_apply_attribute_to_edge(
  edge : ElkEdge,
  attribute : DotAttribute,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
) -> Unit {
  let holder = new_dot_importer_property_holder()
  dot_importer_apply_attribute_to_holder(holder, attribute, trans_data)
  for entry in holder.layout_options.to_array() {
    edge_set_layout_option_string_by_id(edge, entry.0, entry.1)
  }
}

///|
fn dot_importer_apply_holder_to_node(
  holder : DotImporterPropertyHolder,
  node : ElkNode,
) -> Unit {
  for entry in holder.layout_options.to_array() {
    if entry.0 == algorithm.get_id() {
      node_set_string_property(node, algorithm, entry.1)
    } else if entry.0 == direction.get_id() {
      node_set_string_property(node, direction, entry.1)
    } else if entry.0 == padding.get_id() {
      node_set_string_property(node, padding, entry.1)
    } else if entry.0 == spacing_node_node.get_id() {
      match dot_importer_parse_optional_double(entry.1) {
        Some(parsed) =>
          node_set_double_property(node, spacing_node_node, parsed)
        None => ()
      }
    } else if entry.0 == priority.get_id() {
      match dot_importer_parse_optional_double(entry.1) {
        Some(parsed) => node_set_double_property(node, priority, parsed)
        None => ()
      }
    } else {
      node_set_layout_option_string_by_id(node, entry.0, entry.1)
    }
  }
  match holder.def_width {
    Some(width) => node_set_dimensions(node, width, node_height(node))
    None => ()
  }
  match holder.def_height {
    Some(height) => node_set_dimensions(node, node_width(node), height)
    None => ()
  }
}

///|
fn dot_importer_apply_holder_to_edge(
  holder : DotImporterPropertyHolder,
  edge : ElkEdge,
) -> Unit {
  for entry in holder.layout_options.to_array() {
    edge_set_layout_option_string_by_id(edge, entry.0, entry.1)
  }
}

///|
fn dot_importer_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  let outgoing = node_outgoing_edges(node).copy()
  for port in node_ports(node) {
    for edge in port_outgoing_edges(port) {
      outgoing.push(edge)
    }
  }
  outgoing
}

///|
fn dot_importer_copy_attribute(attribute : DotAttribute) -> DotAttribute {
  let copied = dot_create_attribute()
  copied.set_name(attribute.get_name())
  copied.set_value(attribute.get_value())
  copied
}

///|
fn dot_importer_copy_edge_target(edge_target : DotEdgeTarget) -> DotEdgeTarget {
  let copied = dot_create_edge_target()
  copied.set_operator(Some(edge_target.get_operator()))
  match edge_target.get_targetnode() {
    Some(target_node) => copied.set_targetnode(Some(target_node))
    None => ()
  }
  match edge_target.get_target_subgraph() {
    Some(subgraph) => copied.set_target_subgraph(Some(subgraph))
    None => ()
  }
  copied
}

///|
pub fn DotImporter::transform_node_identifier(
  self : DotImporter,
  node_id : String?,
  parent : ElkNode,
) -> ElkNode {
  let key = match node_id {
    Some(v) => v
    None => ""
  }
  match self.node_id_map.get(key) {
    Some(existing) => existing
    None => {
      let created = create_node(Some(parent))
      node_set_dimensions(
        created, dot_importer_def_width, dot_importer_def_width,
      )
      node_set_identifier(created, key)
      self.node_id_map[key] = created
      created
    }
  }
}

///|
pub fn DotImporter::transform_port_identifier(
  self : DotImporter,
  port_id : String?,
  node : ElkNode,
) -> ElkPort {
  let port_key = match port_id {
    Some(v) => v
    None => ""
  }
  let key = node.to_string() + "::" + port_key
  match self.port_id_map.get(key) {
    Some(existing) => existing
    None => {
      let created = create_port(Some(node))
      self.port_id_map[key] = created
      created
    }
  }
}

///|
pub fn DotImporter::transform_node_statement(
  self : DotImporter,
  statement : DotNodeStatement,
  parent : ElkNode,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
  default_props : DotImporterPropertyHolder,
) -> Unit {
  let elknode = self.transform_node_identifier(
    match statement.get_node() {
      Some(node) => node.get_name()
      None => None
    },
    parent,
  )
  if self.node_statement_map.contains(elknode) {
    let name = match statement.get_node() {
      Some(node) =>
        match node.get_name() {
          Some(v) => v
          None => ""
        }
      None => ""
    }
    trans_data.log("Discarding node \"\{name}\" since its id is already used.")
    return
  }

  dot_importer_apply_holder_to_node(default_props, elknode)
  self.node_statement_map[elknode] = dot_statement_node_statement(statement)

  let node_name = match statement.get_node() {
    Some(node) =>
      match node.get_name() {
        Some(v) => v
        None => ""
      }
    None => ""
  }
  for attr in statement.get_attributes() {
    let attr_name = match attr.get_name() {
      Some(v) => v
      None => continue
    }
    let value = dot_importer_trim_value(attr)
    if attr_name == dot_attr_label {
      let label = create_label(Some(make_node_label_parent(elknode)))
      label_set_text(label, value)
    } else if attr_name == dot_attr_pos {
      match dot_exporter_parse_point_token(value) {
        Some(pos) =>
          node_set_location(
            elknode,
            pos.x * dot_exporter_dpi.to_double(),
            pos.y * dot_exporter_dpi.to_double(),
          )
        None =>
          trans_data.log(
            "Discarding attribute \"\{attr_name}\" for node \"\{node_name}\" since its value could not be parsed correctly.",
          )
      }
    } else if attr_name == dot_attr_width {
      match dot_importer_parse_optional_double(value) {
        Some(parsed) =>
          node_set_dimensions(
            elknode,
            parsed * dot_exporter_dpi.to_double(),
            node_height(elknode),
          )
        None =>
          trans_data.log(
            "Discarding attribute \"\{attr_name}\" for node \"\{node_name}\" since its value could not be parsed correctly.",
          )
      }
    } else if attr_name == dot_attr_height {
      match dot_importer_parse_optional_double(value) {
        Some(parsed) =>
          node_set_dimensions(
            elknode,
            node_width(elknode),
            parsed * dot_exporter_dpi.to_double(),
          )
        None =>
          trans_data.log(
            "Discarding attribute \"\{attr_name}\" for node \"\{node_name}\" since its value could not be parsed correctly.",
          )
      }
    } else {
      dot_importer_apply_attribute_to_node(elknode, attr, trans_data)
    }
  }
}

///|
pub fn DotImporter::transform_edge_statement(
  self : DotImporter,
  statement : DotEdgeStatement,
  parent : ElkNode,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
  default_props : DotImporterPropertyHolder,
) -> Unit {
  let source_name = match statement.get_source_node() {
    Some(node) =>
      match node.get_name() {
        Some(name) => name
        None => ""
      }
    None => return
  }
  let source_node_def = match statement.get_source_node() {
    Some(node) => node
    None => return
  }
  let mut source = self.transform_node_identifier(Some(source_name), parent)
  let mut source_port : ElkPort? = None
  match source_node_def.get_port() {
    Some(port) => {
      let port_name = match port.get_compass_pt() {
        Some(compass) => compass
        None =>
          match port.get_name() {
            Some(name) => name
            None => ""
          }
      }
      source_port = Some(
        self.transform_port_identifier(Some(port_name), source),
      )
    }
    None => ()
  }

  let original_targets = statement.get_edge_targets().copy()
  if original_targets.length() > 1 {
    statement.get_edge_targets().clear()
    statement.get_edge_targets().push(original_targets[0])
  }

  let mut target_index = 0
  while target_index < original_targets.length() {
    let edge_target = original_targets[target_index]
    let elkedge = create_edge(None)
    match source_port {
      Some(port) => edge_add_source(elkedge, make_port_shape(port))
      None => edge_add_source(elkedge, make_node_shape(source))
    }

    let edge_target_node = edge_target.get_targetnode()
    let target_name = match edge_target_node {
      Some(node) =>
        match node.get_name() {
          Some(name) => name
          None => ""
        }
      None =>
        match edge_target.get_target_subgraph() {
          Some(subgraph) =>
            match subgraph.get_name() {
              Some(name) => name
              None => ""
            }
          None => ""
        }
    }
    let target = self.transform_node_identifier(Some(target_name), parent)
    let mut target_port : ElkPort? = None
    match edge_target_node {
      Some(node) =>
        match node.get_port() {
          Some(port) => {
            let port_name = match port.get_compass_pt() {
              Some(compass) => compass
              None =>
                match port.get_name() {
                  Some(name) => name
                  None => ""
                }
            }
            target_port = Some(
              self.transform_port_identifier(Some(port_name), target),
            )
          }
          None => ()
        }
      None => ()
    }

    match target_port {
      Some(port) => edge_add_target(elkedge, make_port_shape(port))
      None => edge_add_target(elkedge, make_node_shape(target))
    }

    dot_importer_apply_holder_to_edge(default_props, elkedge)
    let mapped_statement = if target_index == 0 {
      statement
    } else {
      let new_statement = dot_create_edge_statement()
      let new_source = dot_create_node()
      new_source.set_name(Some(source_name))
      new_statement.set_source_node(Some(new_source))
      new_statement
      .get_edge_targets()
      .push(dot_importer_copy_edge_target(edge_target))
      for attr in statement.get_attributes() {
        new_statement.get_attributes().push(dot_importer_copy_attribute(attr))
      }
      new_statement
    }
    self.edge_statement_map[elkedge] = mapped_statement
    self.edge_statement_attached[elkedge] = target_index == 0

    for attr in statement.get_attributes() {
      let attr_name = match attr.get_name() {
        Some(v) => v
        None => continue
      }
      let value = dot_importer_trim_value(attr)
      if attr_name == dot_attr_label {
        let label = create_label(Some(make_edge_label_parent(elkedge)))
        label_set_text(label, value)
        label_set_layout_option_string_by_id(
          label, dot_exporter_option_edge_labels_placement, "CENTER",
        )
      } else if attr_name == dot_attr_headlabel {
        let label = create_label(Some(make_edge_label_parent(elkedge)))
        label_set_text(label, value)
        label_set_layout_option_string_by_id(
          label, dot_exporter_option_edge_labels_placement, "HEAD",
        )
      } else if attr_name == dot_attr_taillabel {
        let label = create_label(Some(make_edge_label_parent(elkedge)))
        label_set_text(label, value)
        label_set_layout_option_string_by_id(
          label, dot_exporter_option_edge_labels_placement, "TAIL",
        )
      } else {
        dot_importer_apply_attribute_to_edge(elkedge, attr, trans_data)
      }
    }

    source = target
    source_port = target_port
    target_index += 1
  }
}

///|
pub fn DotImporter::transform_statements(
  self : DotImporter,
  statements : Array[DotStatement],
  parent : ElkNode,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
  node_props : DotImporterPropertyHolder,
  edge_props : DotImporterPropertyHolder,
) -> Unit {
  for statement in statements {
    match statement {
      DotStatementNodeStatement(node_statement) =>
        self.transform_node_statement(
          node_statement, parent, trans_data, node_props,
        )
      DotStatementEdgeStatement(edge_statement) =>
        self.transform_edge_statement(
          edge_statement, parent, trans_data, edge_props,
        )
      DotStatementSubgraph(subgraph) => {
        let mut sub_elk_node = parent
        let subgraph_name = subgraph.get_name()
        if subgraph_name is Some(name) && name.has_prefix("cluster") {
          sub_elk_node = self.transform_node_identifier(subgraph_name, parent)
          if self.node_statement_map.contains(sub_elk_node) {
            trans_data.log(
              "Discarding cluster subgraph \"\{name}\" since its id is already used.",
            )
            continue
          } else {
            for entry in node_layout_option_string_entries(parent) {
              node_set_layout_option_string_by_id(
                sub_elk_node,
                entry.0,
                entry.1,
              )
            }
            self.node_statement_map[sub_elk_node] = dot_statement_subgraph(
              subgraph,
            )
          }
        }
        let sub_node_props = dot_importer_property_holder_copy(node_props)
        let sub_edge_props = dot_importer_property_holder_copy(edge_props)
        self.transform_statements(
          subgraph.get_statements(),
          sub_elk_node,
          trans_data,
          sub_node_props,
          sub_edge_props,
        )
      }
      DotStatementAttributeStatement(attribute_statement) =>
        if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(dot_attribute_type_graph()) {
          for attribute in attribute_statement.get_attributes() {
            let attr_name = match attribute.get_name() {
              Some(v) => v
              None => continue
            }
            if attr_name == dot_attr_margin {
              let margin_value = dot_importer_trim_value(attribute)
              let margin_numbers = dot_importer_parse_numbers(margin_value)
              if margin_value.contains(",") {
                if margin_numbers.length() >= 2 {
                  let padding_value = new_elk_padding()
                  padding_value.set_left(margin_numbers[0])
                  padding_value.set_right(margin_numbers[0])
                  padding_value.set_top(margin_numbers[1])
                  padding_value.set_bottom(margin_numbers[1])
                  node_set_string_property(
                    parent,
                    padding,
                    padding_value.to_string(),
                  )
                } else {
                  trans_data.log(
                    "Discarding attribute \"\{attr_name}\" since its value could not be parsed correctly.",
                  )
                }
              } else {
                match dot_importer_parse_optional_double(margin_value) {
                  Some(parsed) => {
                    let padding_value = new_elk_padding_any(parsed)
                    node_set_string_property(
                      parent,
                      padding,
                      padding_value.to_string(),
                    )
                  }
                  None =>
                    trans_data.log(
                      "Discarding attribute \"\{attr_name}\" since its value could not be parsed correctly.",
                    )
                }
              }
            } else {
              dot_importer_apply_attribute_to_node(
                parent, attribute, trans_data,
              )
            }
          }
        } else if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(dot_attribute_type_node()) {
          for attribute in attribute_statement.get_attributes() {
            dot_importer_apply_attribute_to_holder(
              node_props, attribute, trans_data,
            )
          }
        } else if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(dot_attribute_type_edge()) {
          for attribute in attribute_statement.get_attributes() {
            dot_importer_apply_attribute_to_holder(
              edge_props, attribute, trans_data,
            )
          }
        }
      DotStatementAttribute(attribute) => {
        let attr_name = match attribute.get_name() {
          Some(v) => v
          None => continue
        }
        if attr_name == dot_attr_margin {
          let margin_value = dot_importer_trim_value(attribute)
          let margin_numbers = dot_importer_parse_numbers(margin_value)
          if margin_value.contains(",") {
            if margin_numbers.length() >= 2 {
              let padding_value = new_elk_padding()
              padding_value.set_left(margin_numbers[0])
              padding_value.set_right(margin_numbers[0])
              padding_value.set_top(margin_numbers[1])
              padding_value.set_bottom(margin_numbers[1])
              node_set_string_property(
                parent,
                padding,
                padding_value.to_string(),
              )
            } else {
              trans_data.log(
                "Discarding attribute \"\{attr_name}\" since its value could not be parsed correctly.",
              )
            }
          } else {
            match dot_importer_parse_optional_double(margin_value) {
              Some(parsed) => {
                let padding_value = new_elk_padding_any(parsed)
                node_set_string_property(
                  parent,
                  padding,
                  padding_value.to_string(),
                )
              }
              None =>
                trans_data.log(
                  "Discarding attribute \"\{attr_name}\" since its value could not be parsed correctly.",
                )
            }
          }
        } else {
          dot_importer_apply_attribute_to_node(parent, attribute, trans_data)
        }
      }
      _ => ()
    }
  }
}

///|
pub fn DotImporter::transform(
  self : DotImporter,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
) -> Unit {
  let source_model = match trans_data.get_source_graph() {
    Some(model) => model
    None => return
  }
  for graph in source_model.get_graphs() {
    let parent = create_graph()
    self.node_id_map = {}
    self.port_id_map = {}
    self.transform_statements(
      graph.get_statements(),
      parent,
      trans_data,
      new_dot_importer_property_holder(),
      new_dot_importer_property_holder(),
    )
    trans_data.get_target_graphs().push(parent)
    self.root_graph_map[parent] = graph
  }
}

///|
pub fn DotImporter::apply_layout_node(
  self : DotImporter,
  parent : ElkNode,
  offset : KVector,
  graph : DotGraph,
) -> Unit {
  for elknode in node_children(parent) {
    let statement = match self.node_statement_map.get(elknode) {
      Some(found) => found
      None => {
        let node_statement = dot_create_node_statement()
        let node = dot_create_node()
        node.set_name(Some(node_identifier(elknode)))
        node_statement.set_node(Some(node))
        graph
        .get_statements()
        .push(dot_statement_node_statement(node_statement))
        let created_statement = dot_statement_node_statement(node_statement)
        self.node_statement_map[elknode] = created_statement
        created_statement
      }
    }
    match statement {
      DotStatementNodeStatement(node_statement) => {
        let attributes = node_statement.get_attributes()
        dot_importer_remove_attributes(attributes, dot_attr_pos)
        let xpos = node_x(elknode) + node_width(elknode) / 2.0 + offset.x
        let ypos = node_y(elknode) + node_height(elknode) / 2.0 + offset.y
        let pos_string = "\"" + xpos.to_string() + "," + ypos.to_string() + "\""
        attributes.push(dot_exporter_create_attribute(dot_attr_pos, pos_string))
        dot_importer_remove_attributes(attributes, dot_attr_width)
        attributes.push(
          dot_exporter_create_attribute_double(
            dot_attr_width,
            node_width(elknode) / dot_exporter_dpi.to_double(),
          ),
        )
        dot_importer_remove_attributes(attributes, dot_attr_height)
        attributes.push(
          dot_exporter_create_attribute_double(
            dot_attr_height,
            node_height(elknode) / dot_exporter_dpi.to_double(),
          ),
        )
      }
      DotStatementSubgraph(_) =>
        self.apply_layout_node(
          elknode,
          new_kvector_copy(offset).add_xy(node_x(elknode), node_y(elknode)),
          graph,
        )
      _ => ()
    }

    for edge in dot_importer_outgoing_edges(elknode) {
      self.apply_layout_edge(edge, offset, graph)
    }
  }

  let statements = match self.node_statement_map.get(parent) {
    Some(DotStatementSubgraph(subgraph)) => subgraph.get_statements()
    _ => graph.get_statements()
  }
  dot_importer_remove_graph_attributes(statements, dot_attr_boundingbox)
  let bb_string = "\"0,0," +
    node_width(parent).to_string() +
    "," +
    node_height(parent).to_string() +
    "\""
  statements.push(
    dot_statement_attribute(
      dot_exporter_create_attribute(dot_attr_boundingbox, bb_string),
    ),
  )
}

///|
pub fn DotImporter::apply_layout_edge(
  self : DotImporter,
  edge : ElkEdge,
  offset : KVector,
  graph : DotGraph,
) -> Unit {
  let edge_statement = match self.edge_statement_map.get(edge) {
    Some(statement) => statement
    None => return
  }
  let attached = match self.edge_statement_attached.get(edge) {
    Some(value) => value
    None => false
  }
  if !attached {
    graph.get_statements().push(dot_statement_edge_statement(edge_statement))
    self.edge_statement_attached[edge] = true
  }

  let attributes = edge_statement.get_attributes()
  dot_importer_remove_attributes(attributes, dot_attr_pos)
  let sections = edge_sections(edge)
  if !sections.is_empty() {
    let section = sections[0]
    let bendpoint_string = "\"" +
      (edge_section_start_x(section) + offset.x).to_string() +
      "," +
      (edge_section_start_y(section) + offset.y).to_string() +
      " " +
      (edge_section_end_x(section) + offset.x).to_string() +
      "," +
      (edge_section_end_y(section) + offset.y).to_string() +
      "\""
    attributes.push(
      dot_exporter_create_attribute(dot_attr_pos, bendpoint_string),
    )
  }

  for label in edge_labels(edge) {
    let placement = dot_exporter_parse_edge_label_placement(
      label_layout_option_string_value(
        label, dot_exporter_option_edge_labels_placement,
      ),
    )
    let attr_key = match placement {
      Centered => Some(dot_attr_labelpos)
      Head => Some(dot_attr_headlp)
      Tail => Some(dot_attr_taillp)
    }
    match attr_key {
      Some(key) => {
        dot_importer_remove_attributes(attributes, key)
        let xpos = label_x(label) + label_width(label) / 2.0 + offset.x
        let ypos = label_y(label) + label_height(label) / 2.0 + offset.y
        let pos_string = "\"" + xpos.to_string() + "," + ypos.to_string() + "\""
        attributes.push(dot_exporter_create_attribute(key, pos_string))
      }
      None => ()
    }
  }
}

///|
pub fn DotImporter::transfer_layout(
  self : DotImporter,
  trans_data : DotTransformationData[DotGraphvizModel, ElkNode],
) -> Unit {
  for layout_node in trans_data.get_target_graphs() {
    match self.root_graph_map.get(layout_node) {
      Some(graph) => self.apply_layout_node(layout_node, new_kvector(), graph)
      None => ()
    }
  }
}
