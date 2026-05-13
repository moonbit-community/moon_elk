///|
pub let dot_exporter_def_spacing_small : Double = 20.0

///|
pub let dot_exporter_def_spacing_large : Double = 40.0

///|
pub let dot_exporter_def_spacing_xlarge : Double = 60.0

///|
pub let dot_exporter_dpi : Float = 72.0

///|
pub suberror DotExporterException {
  DotExporterException(String)
} derive(Debug, ToJson)

///|
fn dot_exporter_raise_unit(message : String) -> Unit raise DotExporterException {
  raise DotExporterException(message)
}

///|
pub let dot_exporter_command : @graph.IProperty[Command] = @graph.new_property(
  "dotExporter.command",
  command_parse("dot"),
)

///|
pub let dot_exporter_use_edge_ids : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.useEdgeIds", false,
)

///|
pub let dot_exporter_hierarchy : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.hierarchy", false,
)

///|
pub let dot_exporter_transform_node_layout : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.transformNodeLayout", true,
)

///|
pub let dot_exporter_transform_edge_layout : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.transformEdgeLayout", true,
)

///|
pub let dot_exporter_transform_node_labels : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.transformNodeLabels", true,
)

///|
pub let dot_exporter_adapt_port_positions : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.adaptPortPositions", false,
)

///|
pub let dot_exporter_option_edge_labels_placement = "org.eclipse.elk.edgeLabels.placement"

///|
pub let dot_exporter_option_font_name = "org.eclipse.elk.font.name"

///|
pub let dot_exporter_option_font_size = "org.eclipse.elk.font.size"

///|
let dot_exporter_font_size_mult : Double = 1.4

///|
pub let dot_exporter_option_edge_routing = "org.eclipse.elk.edgeRouting"

///|
pub let dot_exporter_graph_elems : @graph.IProperty[
  Map[String, DotGraphElement],
] = @graph.new_property("dotExporter.graphElemMap", {})

///|
pub let dot_exporter_use_splines : @graph.IProperty[Bool] = @graph.new_property(
  "dotExporter.useSplines", false,
)

///|
pub let dot_exporter_next_node_id : @graph.IProperty[Int] = @graph.new_property(
  "dotExporter.nextNodeId", 1,
)

///|
pub let dot_exporter_next_edge_id : @graph.IProperty[Int] = @graph.new_property(
  "dotExporter.nextEdgeId", 1,
)

///|
pub let dot_exporter_cluster_dummy : @graph.IProperty[String] = @graph.new_property(
  "dotExporter.clusterDummy", "",
)

///|
let dot_exporter_min_out_char = ' '

///|
let dot_exporter_max_out_char = '~'

///|
pub struct DotExporter {
  _dummy : Unit
}

///|
pub fn new_dot_exporter() -> DotExporter {
  { _dummy: () }
}

///|
pub fn dot_exporter_create_attribute(
  name : String,
  value : String,
) -> DotAttribute {
  let attribute = dot_create_attribute()
  attribute.set_name(Some(name))
  attribute.set_value(Some(value))
  attribute
}

///|
pub fn dot_exporter_create_attribute_int(
  name : String,
  value : Int,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_create_attribute_float(
  name : String,
  value : Float,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_create_attribute_double(
  name : String,
  value : Double,
) -> DotAttribute {
  dot_exporter_create_attribute(name, "\"" + value.to_string() + "\"")
}

///|
pub fn dot_exporter_set_general_node_attributes(
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let node_attr_statement = dot_create_attribute_statement()
  node_attr_statement.set_type(Some(dot_attribute_type_node()))
  let node_attrs = node_attr_statement.get_attributes()
  statements.push(dot_statement_attribute_statement(node_attr_statement))
  node_attrs.push(dot_exporter_create_attribute(dot_attr_shape, "box"))
  node_attrs.push(dot_exporter_create_attribute(dot_attr_fixedsize, "true"))
  node_attrs
}

///|
pub fn DotExporter::set_graph_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
  parent_node : @graph.ElkNode,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let _ = self
  let _ = statements
  let _ = parent_node
  let _ = trans_data
}

///|
pub fn DotExporter::set_general_node_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let _ = self
  dot_exporter_set_general_node_attributes(statements)
}

///|
pub fn DotExporter::set_general_edge_attributes(
  self : DotExporter,
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let _ = self
  dot_exporter_set_general_edge_attributes(statements)
}

///|
pub fn dot_exporter_set_general_edge_attributes(
  statements : Array[DotStatement],
) -> Array[DotAttribute] {
  let edge_attr_statement = dot_create_attribute_statement()
  edge_attr_statement.set_type(Some(dot_attribute_type_edge()))
  let edge_attrs = edge_attr_statement.get_attributes()
  statements.push(dot_statement_attribute_statement(edge_attr_statement))
  edge_attrs.push(dot_exporter_create_attribute(dot_attr_edgedir, "none"))
  edge_attrs
}

///|
fn dot_exporter_parse_edge_label_placement(
  value : String?,
) -> @core.EdgeLabelPlacement {
  let normalized = match value {
    Some(v) => v.trim().to_owned().to_upper()
    None => ""
  }
  if normalized == "HEAD" || normalized.has_suffix(".HEAD") {
    Head
  } else if normalized == "TAIL" || normalized.has_suffix(".TAIL") {
    Tail
  } else {
    Centered
  }
}

///|
fn dot_exporter_parse_int_token(text : String?) -> Int? {
  let normalized = match text {
    Some(v) => v.trim().to_owned()
    None => ""
  }
  if normalized.is_empty() {
    return None
  }
  let parsed_int : Result[Int, Error] = try? @string.parse_int(normalized)
  match parsed_int {
    Ok(value) => Some(value)
    Err(_) =>
      match dot_exporter_parse_double_token(normalized) {
        Some(value) => Some(value.to_int())
        None => None
      }
  }
}

///|
fn dot_exporter_parse_edge_label_spacing(edge : @graph.ElkEdge) -> Double {
  match
    @graph.edge_layout_option_string_value(
      edge,
      @core.spacing_edge_label.get_id(),
    ) {
    Some(raw_value) =>
      match dot_exporter_parse_double_token(raw_value) {
        Some(value) => value
        None => @core.spacing_edge_label.get_default()
      }
    None => @core.spacing_edge_label.get_default()
  }
}

///|
fn dot_exporter_append_label_line(current : String, line : String) -> String {
  if current.is_empty() {
    line
  } else {
    current + "\n" + line
  }
}

///|
pub fn dot_exporter_set_edge_labels(
  elkedge : @graph.ElkEdge,
  attributes : Array[DotAttribute],
  is_vertical : Bool,
) -> Unit {
  let labels = @graph.edge_labels(elkedge)
  if labels.is_empty() {
    return
  }

  let mut mid_label = ""
  let mut head_label = ""
  let mut tail_label = ""
  let mut font_name : String? = None
  let mut font_size = 0
  let mut is_center_font_name = false
  let mut is_center_font_size = false

  for label in labels {
    let placement = dot_exporter_parse_edge_label_placement(
      @graph.label_layout_option_string_value(
        label, dot_exporter_option_edge_labels_placement,
      ),
    )
    let mut take_font_name = false
    let mut take_font_size = false
    match placement {
      Head => {
        take_font_name = font_name is None
        take_font_size = font_size <= 0
        head_label = dot_exporter_append_label_line(
          head_label,
          @graph.label_text(label),
        )
      }
      Tail => {
        take_font_name = font_name is None
        take_font_size = font_size <= 0
        tail_label = dot_exporter_append_label_line(
          tail_label,
          @graph.label_text(label),
        )
      }
      Centered => {
        take_font_name = font_name is None || !is_center_font_name
        is_center_font_name = true
        take_font_size = font_size <= 0 || !is_center_font_size
        is_center_font_size = true
        mid_label = dot_exporter_append_label_line(
          mid_label,
          @graph.label_text(label),
        )
      }
    }
    if take_font_name {
      font_name = @graph.label_layout_option_string_value(
        label, dot_exporter_option_font_name,
      )
    }
    if take_font_size {
      match
        dot_exporter_parse_int_token(
          @graph.label_layout_option_string_value(
            label, dot_exporter_option_font_size,
          ),
        ) {
        Some(parsed_size) => {
          font_size = parsed_size
          if font_size > 0 {
            font_size = (font_size.to_double() * dot_exporter_font_size_mult).to_int()
          }
        }
        None => ()
      }
    }
  }

  if !mid_label.is_empty() {
    let mut label_spacing = dot_exporter_parse_edge_label_spacing(elkedge)
    if label_spacing < 1.0 {
      label_spacing = 0.0
    }
    let chars_to_add = label_spacing.to_int() - 1
    let mut index = 0
    while index < chars_to_add {
      if is_vertical {
        mid_label = mid_label + "O"
      } else {
        mid_label = mid_label + "\nO"
      }
      index += 1
    }
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_label,
        dot_exporter_create_string(mid_label),
      ),
    )
  }
  if !head_label.is_empty() {
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_headlabel,
        dot_exporter_create_string(head_label),
      ),
    )
  }
  if !tail_label.is_empty() {
    attributes.push(
      dot_exporter_create_attribute(
        dot_attr_taillabel,
        dot_exporter_create_string(tail_label),
      ),
    )
  }
  match font_name {
    Some(name) =>
      if !name.is_empty() {
        attributes.push(
          dot_exporter_create_attribute(dot_attr_fontname, "\"" + name + "\""),
        )
      }
    None => ()
  }
  if font_size > 0 {
    attributes.push(
      dot_exporter_create_attribute_int(dot_attr_fontsize, font_size),
    )
  }
}

///|
pub fn DotExporter::set_edge_labels(
  self : DotExporter,
  elkedge : @graph.ElkEdge,
  attributes : Array[DotAttribute],
  is_vertical : Bool,
) -> Unit {
  let _ = self
  dot_exporter_set_edge_labels(elkedge, attributes, is_vertical)
}

///|
pub fn dot_exporter_is_inside_graph(
  node : @graph.ElkNode,
  root : @graph.ElkNode,
) -> Bool {
  let mut current : @graph.ElkNode? = Some(node)
  while current is Some(value) {
    if value == root {
      return true
    }
    current = @graph.node_parent(value)
  }
  false
}

///|
pub fn DotExporter::is_inside_graph(
  self : DotExporter,
  node : @graph.ElkNode,
  root : @graph.ElkNode,
) -> Bool {
  let _ = self
  dot_exporter_is_inside_graph(node, root)
}

///|
pub enum DotExporterNodeType {
  DotExporterNodeTypeNode
  DotExporterNodeTypeCluster
  DotExporterNodeTypeDummy
}

///|
pub fn dot_exporter_node_type_node() -> DotExporterNodeType {
  DotExporterNodeTypeNode
}

///|
pub fn dot_exporter_node_type_cluster() -> DotExporterNodeType {
  DotExporterNodeTypeCluster
}

///|
pub fn dot_exporter_node_type_dummy() -> DotExporterNodeType {
  DotExporterNodeTypeDummy
}

///|
pub fn dot_exporter_get_node_id(
  node : @graph.ElkNode,
  node_type : DotExporterNodeType,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> String {
  let id = trans_data.get_int_property(dot_exporter_next_node_id)
  trans_data.set_int_property(dot_exporter_next_node_id, id + 1)
  let id_string = match node_type {
    DotExporterNodeTypeNode => "node" + id.to_string()
    DotExporterNodeTypeCluster => "cluster" + id.to_string()
    DotExporterNodeTypeDummy => "dummy" + id.to_string()
  }
  match node_type {
    DotExporterNodeTypeNode =>
      trans_data.get_graph_elem_map_property(dot_exporter_graph_elems)[id_string] = dot_graph_element_node(
        node,
      )
    DotExporterNodeTypeCluster =>
      trans_data.get_graph_elem_map_property(dot_exporter_graph_elems)[id_string] = dot_graph_element_node(
        node,
      )
    DotExporterNodeTypeDummy =>
      @graph.node_set_string_property(
        node, dot_exporter_cluster_dummy, id_string,
      )
  }
  id_string
}

///|
pub fn dot_exporter_get_edge_id(
  edge : @graph.ElkEdge,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> String {
  let id = trans_data.get_int_property(dot_exporter_next_edge_id)
  trans_data.set_int_property(dot_exporter_next_edge_id, id + 1)
  let id_string = "edge" + id.to_string()
  trans_data.get_graph_elem_map_property(dot_exporter_graph_elems)[id_string] = dot_graph_element_edge(
    edge,
  )
  id_string
}

///|
fn dot_exporter_all_outgoing_edges(
  node : @graph.ElkNode,
) -> Array[@graph.ElkEdge] {
  let outgoing = @graph.node_outgoing_edges(node).copy()
  for port in @graph.node_ports(node) {
    for edge in @graph.port_outgoing_edges(port) {
      outgoing.push(edge)
    }
  }
  outgoing
}

///|
fn dot_exporter_find_node_id(
  graph_elems : Map[String, DotGraphElement],
  node : @graph.ElkNode,
) -> String? {
  for entry in graph_elems.to_array() {
    if dot_graph_element_as_node(entry.1) == Some(node) {
      return Some(entry.0)
    }
  }
  None
}

///|
fn dot_exporter_layout_direction_is_vertical(parent : @graph.ElkNode) -> Bool {
  let direction_value = @graph.node_get_string_property(parent, @core.direction).to_upper()
  direction_value == "" ||
  direction_value == "DOWN" ||
  direction_value == "UP" ||
  direction_value == "UNDEFINED"
}

///|
fn dot_exporter_parse_padding(node : @graph.ElkNode) -> @core.ElkPadding {
  let value = @graph.node_get_string_property(node, @core.padding)
  let parsed = @core.new_elk_padding()
  parsed.parse(value)
  parsed
}

///|
fn dot_exporter_first_or_create_edge_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  let section = if sections.is_empty() {
    @graph.create_edge_section(edge)
  } else {
    sections[0]
  }
  if @graph.edge_section_incoming_shape(section) is None {
    let sources = @graph.edge_sources(edge)
    if sources.length() == 1 {
      @graph.edge_section_set_incoming_shape(section, Some(sources[0]))
    }
  }
  if @graph.edge_section_outgoing_shape(section) is None {
    let targets = @graph.edge_targets(edge)
    if targets.length() == 1 {
      @graph.edge_section_set_outgoing_shape(section, Some(targets[0]))
    }
  }
  section
}

///|
fn dot_exporter_node_absolute_offset(node : @graph.ElkNode?) -> @core.KVector {
  let offset = @core.new_kvector()
  let mut current = node
  while current is Some(value) {
    ignore(offset.add_xy(@graph.node_x(value), @graph.node_y(value)))
    current = @graph.node_parent(value)
  }
  offset
}

///|
fn dot_exporter_to_absolute(
  point : @core.KVector,
  reference_node : @graph.ElkNode?,
) -> @core.KVector {
  @core.new_kvector_copy(point).add(
    dot_exporter_node_absolute_offset(reference_node),
  )
}

///|
pub fn DotExporter::transform(
  self : DotExporter,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let source_graph = match trans_data.get_source_graph() {
    Some(graph) => graph
    None => return
  }
  trans_data.set_graph_elem_map_property(dot_exporter_graph_elems, {})
  trans_data.set_int_property(dot_exporter_next_node_id, 1)
  trans_data.set_int_property(dot_exporter_next_edge_id, 1)

  let graphviz_model = dot_create_graphviz_model()
  let graph = dot_create_graph()
  graph.set_type(Some(dot_graph_type_digraph()))
  graphviz_model.get_graphs().push(graph)

  self.transform_nodes(
    source_graph,
    graph.get_statements(),
    @core.new_kvector(),
    trans_data,
  )
  self.transform_edges(source_graph, graph.get_statements(), trans_data)
  trans_data.get_target_graphs().push(graphviz_model)
}

///|
pub fn DotExporter::transform_nodes(
  self : DotExporter,
  parent : @graph.ElkNode,
  statements : Array[DotStatement],
  offset : @core.KVector,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  self.set_graph_attributes(statements, parent, trans_data)
  let hierarchy = trans_data.get_bool_property(dot_exporter_hierarchy)
  let transform_node_layout = trans_data.get_bool_property(
    dot_exporter_transform_node_layout,
  )
  let transform_node_labels = trans_data.get_bool_property(
    dot_exporter_transform_node_labels,
  )

  for child_node in @graph.node_children(parent) {
    let node_statement = dot_create_node_statement()
    let attributes = node_statement.get_attributes()
    let mut node_id = ""
    if hierarchy && !@graph.node_children(child_node).is_empty() {
      let cluster_node_id = dot_exporter_get_node_id(
        child_node,
        dot_exporter_node_type_cluster(),
        trans_data,
      )
      let subgraph = dot_create_subgraph()
      subgraph.set_name(Some(cluster_node_id))
      statements.push(dot_statement_subgraph(subgraph))

      let child_padding = dot_exporter_parse_padding(child_node)
      let subgraph_x = @graph.node_x(child_node) + child_padding.get_left()
      let subgraph_y = @graph.node_y(child_node) + child_padding.get_top()
      self.transform_nodes(
        child_node,
        subgraph.get_statements(),
        @core.new_kvector_copy(offset).add_xy(subgraph_x, subgraph_y),
        trans_data,
      )

      node_id = dot_exporter_get_node_id(
        child_node,
        dot_exporter_node_type_dummy(),
        trans_data,
      )
      attributes.push(dot_exporter_create_attribute(dot_attr_style, "invis"))
      attributes.push(dot_exporter_create_attribute_int(dot_attr_width, 0))
      attributes.push(dot_exporter_create_attribute_int(dot_attr_height, 0))
      subgraph
      .get_statements()
      .push(dot_statement_node_statement(node_statement))
    } else {
      node_id = dot_exporter_get_node_id(
        child_node,
        dot_exporter_node_type_node(),
        trans_data,
      )
      if @graph.node_width(child_node) > 0.0 {
        attributes.push(
          dot_exporter_create_attribute_double(
            dot_attr_width,
            @graph.node_width(child_node) / dot_exporter_dpi.to_double(),
          ),
        )
      }
      if @graph.node_height(child_node) > 0.0 {
        attributes.push(
          dot_exporter_create_attribute_double(
            dot_attr_height,
            @graph.node_height(child_node) / dot_exporter_dpi.to_double(),
          ),
        )
      }
      let labels = @graph.node_labels(child_node)
      if transform_node_labels &&
        !labels.is_empty() &&
        !@graph.label_text(labels[0]).is_empty() {
        attributes.push(
          dot_exporter_create_attribute(
            dot_attr_label,
            dot_exporter_create_string(@graph.label_text(labels[0])),
          ),
        )
      }
      if transform_node_layout &&
        (@graph.node_x(child_node) != 0.0 || @graph.node_y(child_node) != 0.0) {
        let xpos = @graph.node_x(child_node) +
          @graph.node_width(child_node) / 2.0 +
          offset.x
        let ypos = @graph.node_y(child_node) +
          @graph.node_height(child_node) / 2.0 +
          offset.y
        let pos_string = "\"" + xpos.to_string() + "," + ypos.to_string() + "\""
        attributes.push(dot_exporter_create_attribute(dot_attr_pos, pos_string))
      }
      statements.push(dot_statement_node_statement(node_statement))
    }
    let node = dot_create_node()
    node.set_name(Some(node_id))
    node_statement.set_node(Some(node))
  }
}

///|
pub fn DotExporter::transform_edges(
  self : DotExporter,
  parent : @graph.ElkNode,
  statements : Array[DotStatement],
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let _ = self
  let hierarchy = trans_data.get_bool_property(dot_exporter_hierarchy)
  let transform_edge_layout = trans_data.get_bool_property(
    dot_exporter_transform_edge_layout,
  )
  let vertical = dot_exporter_layout_direction_is_vertical(parent)
  let graph_elems = trans_data.get_graph_elem_map_property(
    dot_exporter_graph_elems,
  )
  let source_root = match trans_data.get_source_graph() {
    Some(graph) => graph
    None => return
  }

  let nodes = @graph.node_children(parent).copy()
  let mut index = 0
  while index < nodes.length() {
    let source = nodes[index]
    index += 1
    for edge in dot_exporter_all_outgoing_edges(source) {
      if @graph.edge_sources(edge).length() != 1 ||
        @graph.edge_targets(edge).length() != 1 {
        try dot_exporter_raise_unit("Hyperedges are not supported.") catch {
          DotExporterException(message) =>
            @core.layout_runtime_report_unsupported_configuration(
              "org.eclipse.elk.alg.graphviz.dot.transform.DotExporter: " +
              message,
            )
        } noraise {
          _ => ()
        }
        continue
      }
      let target = try
        @graph.connectable_shape_to_node(Some(@graph.edge_targets(edge)[0]))
      catch {
        _ => continue
      } noraise {
        value => value
      }
      if @graph.node_parent(source) == @graph.node_parent(target) ||
        (hierarchy && dot_exporter_is_inside_graph(target, source_root)) {
        let edge_statement = dot_create_edge_statement()
        let attributes = edge_statement.get_attributes()

        let source_node = dot_create_node()
        if hierarchy && !@graph.node_children(source).is_empty() {
          source_node.set_name(
            Some(
              @graph.node_get_string_property(
                source, dot_exporter_cluster_dummy,
              ),
            ),
          )
          match dot_exporter_find_node_id(graph_elems, source) {
            Some(value) =>
              attributes.push(
                dot_exporter_create_attribute(dot_attr_ltail, value),
              )
            None => ()
          }
        } else {
          match dot_exporter_find_node_id(graph_elems, source) {
            Some(value) => source_node.set_name(Some(value))
            None => ()
          }
        }
        edge_statement.set_source_node(Some(source_node))

        let edge_target = dot_create_edge_target()
        let target_node = dot_create_node()
        if hierarchy && !@graph.node_children(target).is_empty() {
          target_node.set_name(
            Some(
              @graph.node_get_string_property(
                target, dot_exporter_cluster_dummy,
              ),
            ),
          )
          match dot_exporter_find_node_id(graph_elems, target) {
            Some(value) =>
              attributes.push(
                dot_exporter_create_attribute(dot_attr_lhead, value),
              )
            None => ()
          }
        } else {
          match dot_exporter_find_node_id(graph_elems, target) {
            Some(value) => target_node.set_name(Some(value))
            None => ()
          }
        }
        edge_target.set_targetnode(Some(target_node))
        edge_statement.get_edge_targets().push(edge_target)

        dot_exporter_set_edge_labels(edge, attributes, vertical)

        if trans_data.get_bool_property(dot_exporter_use_edge_ids) {
          let edge_id = dot_exporter_get_edge_id(edge, trans_data)
          attributes.push(
            dot_exporter_create_attribute(
              dot_attr_comment,
              "\"" + edge_id + "\"",
            ),
          )
        }

        let sections = @graph.edge_sections(edge)
        if transform_edge_layout && !sections.is_empty() {
          let section = sections[0]
          if @graph.edge_section_start_x(section) != 0.0 ||
            @graph.edge_section_start_y(section) != 0.0 ||
            @graph.edge_section_end_x(section) != 0.0 ||
            @graph.edge_section_end_y(section) != 0.0 {
            let start_point = dot_exporter_to_absolute(
              @core.new_kvector_xy(
                @graph.edge_section_start_x(section),
                @graph.edge_section_start_y(section),
              ),
              @graph.edge_containing_node(edge),
            )
            let end_point = dot_exporter_to_absolute(
              @core.new_kvector_xy(
                @graph.edge_section_end_x(section),
                @graph.edge_section_end_y(section),
              ),
              @graph.edge_containing_node(edge),
            )
            let pos_string = "\"" +
              start_point.x.to_string() +
              "," +
              start_point.y.to_string() +
              " " +
              end_point.x.to_string() +
              "," +
              end_point.y.to_string() +
              "\""
            attributes.push(
              dot_exporter_create_attribute(dot_attr_pos, pos_string),
            )
          }
        }

        statements.push(dot_statement_edge_statement(edge_statement))
      }
    }
    if hierarchy {
      for child in @graph.node_children(source) {
        nodes.push(child)
      }
    }
  }
}

///|
pub fn DotExporter::transfer_layout(
  self : DotExporter,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let source_graph = match trans_data.get_source_graph() {
    Some(graph) => graph
    None => return
  }
  let target_graphs = trans_data.get_target_graphs()
  if target_graphs.is_empty() {
    return
  }
  let dot_graphs = target_graphs[0].get_graphs()
  if dot_graphs.is_empty() {
    return
  }
  let graph = dot_graphs[0]
  let outer_padding = dot_exporter_parse_padding(source_graph)
  let base_offset = @core.new_kvector()
  self.apply_layout(
    source_graph,
    graph.get_statements(),
    base_offset,
    outer_padding,
    trans_data,
  )

  let statements = graph.get_statements().copy()
  let edge_offset = @core.new_kvector_copy(base_offset).add_xy(
    outer_padding.get_left(),
    outer_padding.get_top(),
  )
  let mut index = 0
  while index < statements.length() {
    let statement = statements[index]
    index += 1
    match statement {
      DotStatementEdgeStatement(edge_statement) =>
        self.apply_edge_layout(edge_statement, edge_offset, trans_data)
      DotStatementSubgraph(subgraph) =>
        for sub_statement in subgraph.get_statements() {
          statements.push(sub_statement)
        }
      _ => ()
    }
  }
}

///|
fn dot_exporter_is_number_char(c : Char) -> Bool {
  (c >= '0' && c <= '9') ||
  c == '-' ||
  c == '+' ||
  c == '.' ||
  c == 'e' ||
  c == 'E'
}

///|
fn dot_exporter_slice(text : String, start : Int, end_ : Int) -> String {
  text[start:end_].to_owned()
}

///|
fn dot_exporter_slice_from(text : String, start : Int) -> String {
  text[start:].to_owned()
}

///|
fn dot_exporter_parse_numbers(text : String) -> Array[Double] {
  let numbers : Array[Double] = []
  let mut token_start = -1
  let mut index = 0
  while index < text.length() {
    let current = dot_exporter_char_at(text, index)
    if dot_exporter_is_number_char(current) {
      if token_start < 0 {
        token_start = index
      }
    } else if token_start >= 0 {
      match
        dot_exporter_parse_double_token(
          dot_exporter_slice(text, token_start, index),
        ) {
        Some(value) => numbers.push(value)
        None => ()
      }
      token_start = -1
    }
    index += 1
  }
  if token_start >= 0 {
    match
      dot_exporter_parse_double_token(
        dot_exporter_slice_from(text, token_start),
      ) {
      Some(value) => numbers.push(value)
      None => ()
    }
  }
  numbers
}

///|
fn dot_exporter_parse_bbox(text : String) -> Array[Double]? {
  let numbers = dot_exporter_parse_numbers(text)
  if numbers.length() < 4 {
    None
  } else {
    Some([numbers[0], numbers[1], numbers[2], numbers[3]])
  }
}

///|
fn dot_exporter_parse_first_number(text : String) -> Double? {
  let numbers = dot_exporter_parse_numbers(text)
  if numbers.is_empty() {
    None
  } else {
    Some(numbers[0])
  }
}

///|
pub fn DotExporter::apply_layout(
  self : DotExporter,
  parent_node : @graph.ElkNode,
  statements : Array[DotStatement],
  base_offset : @core.KVector,
  outer_padding : @core.ElkPadding,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let _ = self
  let mut padding = @core.new_elk_padding_copy(outer_padding)
  let node_offset = @core.new_kvector()
  let source_graph = trans_data.get_source_graph()

  let mut found_bbox = false
  for statement in statements {
    if found_bbox {
      break
    }
    match statement {
      DotStatementAttributeStatement(attribute_statement) =>
        if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(dot_attribute_type_graph()) {
          for attribute in attribute_statement.get_attributes() {
            if attribute.get_name() == Some(dot_attr_boundingbox) {
              match attribute.get_value() {
                Some(value) =>
                  match dot_exporter_parse_bbox(value) {
                    Some(bbox) => {
                      let leftx = bbox[0]
                      let bottomy = bbox[1]
                      let rightx = bbox[2]
                      let topy = bbox[3]
                      let mut width = rightx - leftx
                      let mut height = bottomy - topy
                      if source_graph == Some(parent_node) {
                        width = width + padding.get_horizontal()
                        height = height + padding.get_vertical()
                        ignore(base_offset.add_xy(-leftx, -topy))
                        ignore(node_offset.add_xy(-leftx, -topy))
                      } else {
                        @graph.node_set_location(
                          parent_node,
                          base_offset.x + leftx + padding.get_left(),
                          base_offset.y + topy + padding.get_top(),
                        )
                        padding = @core.new_elk_padding()
                        ignore(
                          node_offset.set_xy(
                            -(base_offset.x + leftx),
                            -(base_offset.y + topy),
                          ),
                        )
                      }
                      @graph.node_set_dimensions(parent_node, width, height)
                      found_bbox = true
                    }
                    None => ()
                  }
                None => ()
              }
            }
          }
        }
      _ => ()
    }
  }

  for statement in statements {
    match statement {
      DotStatementNodeStatement(node_statement) =>
        self.apply_node_layout(node_statement, node_offset, padding, trans_data)
      DotStatementSubgraph(subgraph) =>
        match subgraph.get_name() {
          Some(name) =>
            match
              trans_data
              .get_graph_elem_map_property(dot_exporter_graph_elems)
              .get(name) {
              Some(graph_elem) =>
                match dot_graph_element_as_node(graph_elem) {
                  Some(elknode) => {
                    self.apply_layout(
                      elknode,
                      subgraph.get_statements(),
                      base_offset,
                      padding,
                      trans_data,
                    )
                    @graph.node_set_location(
                      elknode,
                      @graph.node_x(elknode) + node_offset.x,
                      @graph.node_y(elknode) + node_offset.y,
                    )
                  }
                  None => ()
                }
              None => ()
            }
          None => ()
        }
      _ => ()
    }
  }
}

///|
pub fn DotExporter::apply_node_layout(
  self : DotExporter,
  node_statement : DotNodeStatement,
  offset : @core.KVector,
  padding : @core.ElkPadding,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let _ = self
  let node_id = match node_statement.get_node() {
    Some(node) =>
      match node.get_name() {
        Some(name) => name
        None => return
      }
    None => return
  }
  let elknode = match
    trans_data
    .get_graph_elem_map_property(dot_exporter_graph_elems)
    .get(node_id) {
    Some(graph_elem) =>
      match dot_graph_element_as_node(graph_elem) {
        Some(node) => node
        None => return
      }
    None => return
  }

  let mut xpos = 0.0
  let mut ypos = 0.0
  let mut width = 0.0
  let mut height = 0.0
  for attribute in node_statement.get_attributes() {
    match attribute.get_name() {
      Some(name) =>
        if name == dot_attr_pos {
          match attribute.get_value() {
            Some(value) =>
              match dot_exporter_parse_point_token(value) {
                Some(pos) => {
                  xpos = pos.x + offset.x + padding.get_left()
                  ypos = pos.y + offset.y + padding.get_top()
                }
                None => ()
              }
            None => ()
          }
        } else if name == dot_attr_width {
          match attribute.get_value() {
            Some(value) =>
              match dot_exporter_parse_first_number(value) {
                Some(parsed) => width = parsed * dot_exporter_dpi.to_double()
                None => ()
              }
            None => ()
          }
        } else if name == dot_attr_height {
          match attribute.get_value() {
            Some(value) =>
              match dot_exporter_parse_first_number(value) {
                Some(parsed) => height = parsed * dot_exporter_dpi.to_double()
                None => ()
              }
            None => ()
          }
        }
      None => ()
    }
  }
  @graph.node_set_location(elknode, xpos - width / 2.0, ypos - height / 2.0)
}

///|
pub fn DotExporter::apply_edge_layout(
  self : DotExporter,
  edge_statement : DotEdgeStatement,
  edge_offset : @core.KVector,
  trans_data : DotTransformationData[@graph.ElkNode, DotGraphvizModel],
) -> Unit {
  let attribute_map = dot_exporter_create_attribute_map(
    edge_statement.get_attributes(),
  )
  let comment_value = match attribute_map.get(dot_attr_comment) {
    Some(value) => value
    None => return
  }
  let elkedge = match
    trans_data
    .get_graph_elem_map_property(dot_exporter_graph_elems)
    .get(comment_value) {
    Some(graph_elem) =>
      match dot_graph_element_as_edge(graph_elem) {
        Some(edge) => edge
        None => return
      }
    None => return
  }

  let edge_section = dot_exporter_first_or_create_edge_section(elkedge)
  let pos_string = match attribute_map.get(dot_attr_pos) {
    Some(value) => value
    None => ""
  }

  let mut reference_node = @graph.edge_containing_node(elkedge)
  let reference = @core.new_kvector()
  let source_graph = trans_data.get_source_graph()
  while reference_node is Some(node) {
    if Some(node) == source_graph {
      break
    }
    ignore(reference.add_xy(@graph.node_x(node), @graph.node_y(node)))
    reference_node = @graph.node_parent(node)
  }
  let offset = @core.new_kvector_copy(edge_offset).sub(reference)

  let splines : Array[@core.KVectorChain] = []
  let endpoints = dot_exporter_parse_spline_points(pos_string, splines, offset)
  let mut source_point = endpoints.get_first()
  let mut target_point = endpoints.get_second()
  if !splines.is_empty() {
    if source_point is None {
      let first_spline_points = splines[0].to_array()
      if !first_spline_points.is_empty() {
        source_point = Some(first_spline_points[0])
      } else {
        let source_node_opt = try
          @graph.connectable_shape_to_node(
            Some(@graph.edge_sources(elkedge)[0]),
          )
        catch {
          _ => None
        } noraise {
          value => Some(value)
        }
        match source_node_opt {
          Some(source_node) =>
            source_point = Some(
              @core.new_kvector_xy(
                @graph.node_x(source_node) +
                @graph.node_width(source_node) / 2.0,
                @graph.node_y(source_node) +
                @graph.node_height(source_node) / 2.0,
              ),
            )
          None => ()
        }
      }
    }
    if target_point is None {
      let last_spline_points = splines[splines.length() - 1].to_array()
      if !last_spline_points.is_empty() {
        target_point = Some(last_spline_points[last_spline_points.length() - 1])
      } else {
        let target_node_opt = try
          @graph.connectable_shape_to_node(
            Some(@graph.edge_targets(elkedge)[0]),
          )
        catch {
          _ => None
        } noraise {
          value => Some(value)
        }
        match target_node_opt {
          Some(target_node) =>
            target_point = Some(
              @core.new_kvector_xy(
                @graph.node_x(target_node) +
                @graph.node_width(target_node) / 2.0,
                @graph.node_y(target_node) +
                @graph.node_height(target_node) / 2.0,
              ),
            )
          None => ()
        }
      }
    }
    match (source_point, target_point) {
      (Some(source), Some(target)) => {
        @graph.edge_section_set_start(edge_section, source.x, source.y)
        @graph.edge_section_set_end(edge_section, target.x, target.y)
      }
      _ => ()
    }
  }

  if trans_data.get_bool_property(dot_exporter_use_splines) {
    @graph.edge_set_layout_option_string_by_id(
      elkedge, dot_exporter_option_edge_routing, "SPLINES",
    )
  }

  match attribute_map.get(dot_attr_labelpos) {
    Some(label_pos) =>
      self.apply_edge_label_pos(elkedge, label_pos, Centered, offset)
    None => ()
  }
  match attribute_map.get(dot_attr_headlp) {
    Some(label_pos) =>
      self.apply_edge_label_pos(elkedge, label_pos, Head, offset)
    None => ()
  }
  match attribute_map.get(dot_attr_taillp) {
    Some(label_pos) =>
      self.apply_edge_label_pos(elkedge, label_pos, Tail, offset)
    None => ()
  }
}

///|
pub fn DotExporter::apply_edge_label_pos(
  self : DotExporter,
  elkedge : @graph.ElkEdge,
  pos_string : String,
  placement : @core.EdgeLabelPlacement,
  offset : @core.KVector,
) -> Unit {
  let _ = self
  let mut combined_width = 0.0
  let mut combined_height = 0.0
  for label in @graph.edge_labels(elkedge) {
    let label_placement = dot_exporter_parse_edge_label_placement(
      @graph.label_layout_option_string_value(
        label, dot_exporter_option_edge_labels_placement,
      ),
    )
    if @core.edge_label_placement_to_string(label_placement) ==
      @core.edge_label_placement_to_string(placement) {
      combined_width = @cmp.maximum(combined_width, @graph.label_width(label))
      combined_height = combined_height + @graph.label_height(label)
    }
  }

  match dot_exporter_parse_point_token(pos_string) {
    Some(pos) => {
      let xpos = pos.x - combined_width / 2.0 + offset.x
      let mut ypos = pos.y - combined_height / 2.0 + offset.y
      for label in @graph.edge_labels(elkedge) {
        let label_placement = dot_exporter_parse_edge_label_placement(
          @graph.label_layout_option_string_value(
            label, dot_exporter_option_edge_labels_placement,
          ),
        )
        if @core.edge_label_placement_to_string(label_placement) ==
          @core.edge_label_placement_to_string(placement) {
          let xoffset = (combined_width - @graph.label_width(label)) / 2.0
          @graph.label_set_location(label, xpos + xoffset, ypos)
          ypos = ypos + @graph.label_height(label)
        }
      }
    }
    None => ()
  }
}

///|
pub fn dot_exporter_create_string(label : String) -> String {
  let escape_buffer = @buffer.new()
  escape_buffer.write_char('"')
  let mut index = 0
  while index < label.length() {
    let c = label[index].unsafe_to_char()
    if c == '"' || c == '\\' || c > dot_exporter_max_out_char {
      escape_buffer.write_char('_')
    } else if c == '\n' {
      escape_buffer.write_string("\\n")
    } else if c >= dot_exporter_min_out_char {
      escape_buffer.write_char(c)
    }
    index += 1
  }
  escape_buffer.write_char('"')
  escape_buffer.to_string()
}

///|
pub fn dot_exporter_create_attribute_map(
  attributes : Array[DotAttribute],
) -> Map[String, String] {
  let attribute_map : Map[String, String] = {}
  for attribute in attributes {
    match (attribute.get_name(), attribute.get_value()) {
      (Some(name), Some(value)) => attribute_map[name] = value
      _ => ()
    }
  }
  attribute_map
}

///|
fn dot_exporter_char_at(source : String, index : Int) -> Char {
  source[index].unsafe_to_char()
}

///|
fn dot_exporter_split_on_quote_and_semicolon(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut token_start = 0
  let mut index = 0
  while index < text.length() {
    let current = dot_exporter_char_at(text, index)
    if current == '"' || current == ';' {
      if token_start < index {
        let token = dot_exporter_slice(text, token_start, index)
          .trim()
          .to_owned()
        if !token.is_empty() {
          tokens.push(token)
        }
      }
      token_start = index + 1
    }
    index += 1
  }
  if token_start < text.length() {
    let token = dot_exporter_slice_from(text, token_start).trim().to_owned()
    if !token.is_empty() {
      tokens.push(token)
    }
  }
  tokens
}

///|
fn dot_exporter_split_on_whitespace(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut token_start = 0
  let mut index = 0
  while index < text.length() {
    let current = dot_exporter_char_at(text, index)
    if current == ' ' || current == '\t' || current == '\n' || current == '\r' {
      if token_start < index {
        tokens.push(dot_exporter_slice(text, token_start, index))
      }
      token_start = index + 1
    }
    index += 1
  }
  if token_start < text.length() {
    tokens.push(dot_exporter_slice_from(text, token_start))
  }
  tokens
}

///|
fn dot_exporter_parse_double_token(text : String) -> Double? {
  let normalized = text.trim().to_owned()
  if normalized.is_empty() {
    return None
  }
  let parsed : Result[Double, Error] = try? @string.parse_double(normalized)
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn dot_exporter_parse_point_token(token : String) -> @core.KVector? {
  let mut normalized = token.trim().to_owned()
  if normalized.length() >= 2 &&
    normalized.has_prefix("\"") &&
    normalized.has_suffix("\"") {
    normalized = dot_exporter_slice(normalized, 1, normalized.length() - 1)
  }
  if normalized.is_empty() {
    return None
  }
  let parts = normalized.split(",").to_array()
  if parts.length() != 2 {
    return None
  }
  match
    (
      dot_exporter_parse_double_token(parts[0].to_owned()),
      dot_exporter_parse_double_token(parts[1].to_owned()),
    ) {
    (Some(x), Some(y)) => Some(@core.new_kvector_xy(x, y))
    _ => None
  }
}

///|
fn dot_exporter_suffix_after_first_comma(token : String) -> String {
  let mut index = 0
  while index < token.length() {
    if dot_exporter_char_at(token, index) == ',' {
      return dot_exporter_slice_from(token, index + 1)
    }
    index += 1
  }
  token
}

///|
pub fn dot_exporter_parse_spline_points(
  pos_string : String,
  splines : Array[@core.KVectorChain],
  offset : @core.KVector,
) -> @core.Pair[@core.KVector, @core.KVector] {
  let mut source_point : @core.KVector? = None
  let mut target_point : @core.KVector? = None

  for spline_token in dot_exporter_split_on_quote_and_semicolon(pos_string) {
    let point_list = @core.new_kvector_chain()
    for token in dot_exporter_split_on_whitespace(spline_token) {
      if token.has_prefix("s") {
        if source_point is None {
          match
            dot_exporter_parse_point_token(
              dot_exporter_suffix_after_first_comma(token),
            ) {
            Some(point) => {
              ignore(point.add(offset))
              source_point = Some(point)
            }
            None => ()
          }
        }
      } else if token.has_prefix("e") {
        if target_point is None {
          match
            dot_exporter_parse_point_token(
              dot_exporter_suffix_after_first_comma(token),
            ) {
            Some(point) => {
              ignore(point.add(offset))
              target_point = Some(point)
            }
            None => ()
          }
        }
      } else {
        match dot_exporter_parse_point_token(token) {
          Some(point) => {
            ignore(point.add(offset))
            point_list.add_last_vector(point)
          }
          None => ()
        }
      }
    }
    splines.push(point_list)
  }

  let result : @core.Pair[@core.KVector, @core.KVector] = @core.pair_create()
  result.set_first(source_point)
  result.set_second(target_point)
  result
}
