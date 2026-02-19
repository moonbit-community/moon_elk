///|
pub struct ElkGraphImporter {
  _dummy : Unit
}

///|
pub fn new_elk_graph_importer() -> ElkGraphImporter {
  { _dummy: () }
}

///|
fn first_node_label_text(node : ElkNode) -> String {
  let labels = node_labels(node)
  if labels.is_empty() {
    ""
  } else {
    label_text(labels[0])
  }
}

///|
fn first_or_create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  let sections = edge_sections(edge)
  let section = if sections.is_empty() {
    create_edge_section(edge)
  } else {
    sections[0]
  }
  if edge_section_incoming_shape(section) is None {
    let sources = edge_sources(edge)
    if sources.length() == 1 {
      edge_section_set_incoming_shape(section, Some(sources[0]))
    }
  }
  if edge_section_outgoing_shape(section) is None {
    let targets = edge_targets(edge)
    if targets.length() == 1 {
      edge_section_set_outgoing_shape(section, Some(targets[0]))
    }
  }
  section
}

///|
fn parse_bool_layout_value(value : String) -> Bool? {
  let normalized = value.trim().to_string().to_lower()
  if normalized.is_empty() {
    None
  } else if normalized == "true" || normalized == "1" {
    Some(true)
  } else if normalized == "false" || normalized == "0" {
    Some(false)
  } else {
    None
  }
}

///|
fn parse_int_layout_value(value : String) -> Int? {
  let normalized = value.trim().to_string()
  if normalized.is_empty() {
    return None
  }
  let parsed_int : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
    normalized,
  )
  match parsed_int {
    Ok(parsed) => Some(parsed)
    Err(_) =>
      match parse_double_layout_value(normalized) {
        Some(parsed) => Some(parsed.to_int())
        None => None
      }
  }
}

///|
fn parse_double_layout_value(value : String) -> Double? {
  let normalized = value.trim().to_string()
  if normalized.is_empty() {
    return None
  }
  let parsed_double : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    normalized,
  )
  match parsed_double {
    Ok(parsed) => Some(parsed)
    Err(_) =>
      if normalized.has_suffix("f") ||
        normalized.has_suffix("F") ||
        normalized.has_suffix("d") ||
        normalized.has_suffix("D") {
        let without_suffix = normalized.substring(
          start=0,
          end=normalized.length() - 1,
        )
        if without_suffix.is_empty() {
          return None
        }
        let parsed_without_suffix : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
          without_suffix,
        )
        match parsed_without_suffix {
          Ok(parsed) => Some(parsed)
          Err(_) => None
        }
      } else {
        None
      }
  }
}

///|
fn parse_padding_layout_value(value : String) -> ElkPadding? {
  let normalized = value.trim().to_string()
  if normalized.is_empty() {
    return None
  }
  match parse_double_layout_value(normalized) {
    Some(single_value) => return Some(new_elk_padding_any(single_value))
    None => ()
  }
  let body = normalized.trim(chars="([{\"' )]} \t\r\n").to_string()
  if body.is_empty() {
    return None
  }
  let mut top : Double? = None
  let mut right : Double? = None
  let mut bottom : Double? = None
  let mut left : Double? = None
  let mut matched = false
  let tokens = body.replace_all(old=";", new=",")
  for token_view in tokens.split(",") {
    let token = token_view.trim().to_string()
    if token.is_empty() {
      continue
    }
    let token_parts = token.replace_all(old=":", new="=").split("=").to_array()
    if token_parts.length() != 2 {
      return None
    }
    let key = token_parts[0].trim().to_string().to_lower()
    let value_part = token_parts[1].trim().to_string()
    let parsed_value = match parse_double_layout_value(value_part) {
      Some(parsed) => parsed
      None => return None
    }
    if key == "top" {
      top = Some(parsed_value)
      matched = true
    } else if key == "right" {
      right = Some(parsed_value)
      matched = true
    } else if key == "bottom" {
      bottom = Some(parsed_value)
      matched = true
    } else if key == "left" {
      left = Some(parsed_value)
      matched = true
    }
  }
  if !matched {
    return None
  }
  let padding = new_elk_padding()
  match top {
    Some(value) => padding.set_top(value)
    None => ()
  }
  match right {
    Some(value) => padding.set_right(value)
    None => ()
  }
  match bottom {
    Some(value) => padding.set_bottom(value)
    None => ()
  }
  match left {
    Some(value) => padding.set_left(value)
    None => ()
  }
  Some(padding)
}

///|
fn parse_force_model_layout_value(value : String) -> ForceModelStrategy? {
  let normalized = value.trim().to_string().to_upper()
  if normalized.is_empty() {
    None
  } else if normalized == "EADES" || normalized.has_suffix(".EADES") {
    Some(Eades)
  } else if normalized == "FRUCHTERMAN_REINGOLD" ||
    normalized.has_suffix(".FRUCHTERMAN_REINGOLD") {
    Some(FruchtermanReingold)
  } else {
    None
  }
}

///|
fn parse_stress_dimension_layout_value(value : String) -> Int? {
  let normalized = value.trim().to_string().to_upper()
  if normalized.is_empty() {
    return None
  }
  if normalized == "XY" || normalized.has_suffix(".XY") {
    return Some(0)
  }
  if normalized == "X" || normalized.has_suffix(".X") {
    return Some(1)
  }
  if normalized == "Y" || normalized.has_suffix(".Y") {
    return Some(2)
  }
  parse_int_layout_value(normalized)
}

///|
fn bool_option_with_default(raw_value : String?, default_value : Bool) -> Bool {
  match raw_value {
    Some(value) =>
      match parse_bool_layout_value(value) {
        Some(parsed) => parsed
        None => default_value
      }
    None => default_value
  }
}

///|
fn int_option_with_default(raw_value : String?, default_value : Int) -> Int {
  match raw_value {
    Some(value) =>
      match parse_int_layout_value(value) {
        Some(parsed) => parsed
        None => default_value
      }
    None => default_value
  }
}

///|
fn double_option_with_default(
  raw_value : String?,
  default_value : Double,
) -> Double {
  match raw_value {
    Some(value) =>
      match parse_double_layout_value(value) {
        Some(parsed) => parsed
        None => default_value
      }
    None => default_value
  }
}

///|
fn force_copy_graph_properties(graph : ElkNode, fgraph : FGraph) -> Bool {
  fgraph.set_property(
    force_separate_connected_components,
    bool_option_with_default(
      node_layout_option_string_value(
        graph,
        force_separate_connected_components.get_id(),
      ),
      force_separate_connected_components.get_default(),
    ),
  )
  fgraph.set_property(
    force_interactive,
    bool_option_with_default(
      node_layout_option_string_value(graph, force_interactive.get_id()),
      force_interactive.get_default(),
    ),
  )
  fgraph.set_property(
    force_omit_node_micro_layout,
    bool_option_with_default(
      node_layout_option_string_value(
        graph,
        force_omit_node_micro_layout.get_id(),
      ),
      force_omit_node_micro_layout.get_default(),
    ),
  )
  let graph_edge_labels_inline = bool_option_with_default(
    node_layout_option_string_value(graph, force_edge_labels_inline.get_id()),
    force_edge_labels_inline.get_default(),
  )
  fgraph.set_property(force_edge_labels_inline, graph_edge_labels_inline)
  fgraph.set_int_property(
    force_iterations,
    int_option_with_default(
      node_layout_option_string_value(graph, force_iterations.get_id()),
      force_iterations.get_default(),
    ),
  )
  fgraph.set_int_property(
    force_random_seed,
    int_option_with_default(
      node_layout_option_string_value(graph, force_random_seed.get_id()),
      force_random_seed.get_default(),
    ),
  )
  fgraph.set_int_property(
    stress_dimension,
    match node_layout_option_string_value(graph, stress_dimension.get_id()) {
      Some(value) =>
        match parse_stress_dimension_layout_value(value) {
          Some(parsed) => parsed
          None => stress_dimension.get_default()
        }
      None => stress_dimension.get_default()
    },
  )
  fgraph.set_int_property(
    stress_iteration_limit,
    int_option_with_default(
      node_layout_option_string_value(graph, stress_iteration_limit.get_id()),
      stress_iteration_limit.get_default(),
    ),
  )
  fgraph.set_double_property(
    force_temperature,
    double_option_with_default(
      node_layout_option_string_value(graph, force_temperature.get_id()),
      force_temperature.get_default(),
    ),
  )
  fgraph.set_double_property(
    force_repulsion,
    double_option_with_default(
      node_layout_option_string_value(graph, force_repulsion.get_id()),
      force_repulsion.get_default(),
    ),
  )
  fgraph.set_double_property(
    force_spacing_node_node,
    double_option_with_default(
      node_layout_option_string_value(graph, force_spacing_node_node.get_id()),
      node_get_double_property(graph, spacing_node_node),
    ),
  )
  fgraph.set_double_property(
    force_spacing_edge_label,
    double_option_with_default(
      node_layout_option_string_value(graph, force_spacing_edge_label.get_id()),
      force_spacing_edge_label.get_default(),
    ),
  )
  fgraph.set_double_property(
    force_aspect_ratio,
    double_option_with_default(
      node_layout_option_string_value(graph, force_aspect_ratio.get_id()),
      node_get_double_property(graph, aspect_ratio),
    ),
  )
  fgraph.set_double_property(
    stress_desired_edge_length,
    double_option_with_default(
      node_layout_option_string_value(
        graph,
        stress_desired_edge_length.get_id(),
      ),
      stress_desired_edge_length.get_default(),
    ),
  )
  fgraph.set_double_property(
    stress_epsilon,
    double_option_with_default(
      node_layout_option_string_value(graph, stress_epsilon.get_id()),
      stress_epsilon.get_default(),
    ),
  )
  fgraph.set_model_property(
    force_model,
    match node_layout_option_string_value(graph, force_model.get_id()) {
      Some(value) =>
        match parse_force_model_layout_value(value) {
          Some(model) => model
          None => force_model.get_default()
        }
      None => force_model.get_default()
    },
  )
  fgraph.set_padding_property(
    force_padding,
    match node_layout_option_string_value(graph, force_padding.get_id()) {
      Some(value) =>
        match parse_padding_layout_value(value) {
          Some(padding) => padding
          None => force_padding.get_default()
        }
      None => force_padding.get_default()
    },
  )
  graph_edge_labels_inline
}

///|
fn force_transform_nodes(
  parent_node : ElkNode,
  fgraph : FGraph,
  elem_map : Map[ElkNode, FNode],
) -> Unit {
  let mut index = 0
  for node in node_children(parent_node) {
    let new_node = new_fnode(label=first_node_label_text(node))
    fnode_set_origin(new_node, node)
    fnode_set_id(new_node, index)
    fnode_position(new_node).x = node_x(node) + node_width(node) / 2.0
    fnode_position(new_node).y = node_y(node) + node_height(node) / 2.0
    fnode_size(new_node).x = force_max(node_width(node), 1.0)
    fnode_size(new_node).y = force_max(node_height(node), 1.0)
    let priority_value = int_option_with_default(
      node_layout_option_string_value(node, force_priority.get_id()),
      node_get_double_property(node, priority).to_int(),
    )
    fnode_set_int_property(new_node, force_priority, priority_value)
    fnode_set_bool_property(
      new_node,
      stress_fixed,
      bool_option_with_default(
        node_layout_option_string_value(node, stress_fixed.get_id()),
        stress_fixed.get_default(),
      ),
    )
    index += 1
    elem_map[node] = new_node
    fgraph.add_node(new_node)
  }
}

///|
fn force_transform_edges(
  parent_node : ElkNode,
  fgraph : FGraph,
  elem_map : Map[ElkNode, FNode],
  graph_edge_labels_inline : Bool,
) -> Unit {
  for edge in node_contained_edges(parent_node) {
    let sources = edge_sources(edge)
    let targets = edge_targets(edge)
    if sources.length() != 1 || targets.length() != 1 {
      abort("Graph must not contain hyperedges.")
    }
    let source_node = connectable_shape_to_node(Some(sources[0]))
    let target_node = connectable_shape_to_node(Some(targets[0]))
    if source_node == target_node {
      continue
    }
    match (elem_map.get(source_node), elem_map.get(target_node)) {
      (Some(source), Some(target)) => {
        let new_edge = new_fedge()
        fedge_set_origin(new_edge, edge)
        fedge_set_source(new_edge, source)
        fedge_set_target(new_edge, target)
        fedge_set_int_property(
          new_edge,
          force_priority,
          int_option_with_default(
            edge_layout_option_string_value(edge, force_priority.get_id()),
            force_priority.get_default(),
          ),
        )
        fedge_set_int_property(
          new_edge,
          force_repulsive_power,
          int_option_with_default(
            edge_layout_option_string_value(
              edge,
              force_repulsive_power.get_id(),
            ),
            force_repulsive_power.get_default(),
          ),
        )
        match
          edge_layout_option_string_value(
            edge,
            stress_desired_edge_length.get_id(),
          ) {
          Some(value) =>
            match parse_double_layout_value(value) {
              Some(parsed) =>
                fedge_set_double_property(
                  new_edge, stress_desired_edge_length, parsed,
                )
              None => ()
            }
          None => ()
        }
        fgraph.add_edge(new_edge)
        let edge_labels_inline = bool_option_with_default(
          edge_layout_option_string_value(
            edge,
            force_edge_labels_inline.get_id(),
          ),
          graph_edge_labels_inline,
        )
        for edge_label in edge_labels(edge) {
          let new_label = new_flabel(new_edge, text=label_text(edge_label))
          flabel_set_origin(new_label, edge_label)
          flabel_size(new_label).x = force_max(label_width(edge_label), 1.0)
          flabel_size(new_label).y = force_max(label_height(edge_label), 1.0)
          flabel_set_bool_property(
            new_label,
            force_edge_labels_inline,
            bool_option_with_default(
              label_layout_option_string_value(
                edge_label,
                force_edge_labels_inline.get_id(),
              ),
              edge_labels_inline,
            ),
          )
          flabel_refresh_position(new_label)
          fgraph.add_label(new_label)
        }
      }
      _ => ()
    }
  }
}

///|
pub fn ElkGraphImporter::import_graph(
  self : ElkGraphImporter,
  graph : ElkNode,
) -> FGraph {
  ignore(self)
  let fgraph = new_fgraph()
  let graph_edge_labels_inline = force_copy_graph_properties(graph, fgraph)
  fgraph.set_internal_node_property(force_internal_origin, graph)
  let elem_map : Map[ElkNode, FNode] = {}
  force_transform_nodes(graph, fgraph, elem_map)
  force_transform_edges(graph, fgraph, elem_map, graph_edge_labels_inline)
  fgraph
}

///|
pub fn ElkGraphImporter::apply_layout(
  self : ElkGraphImporter,
  force_graph : FGraph,
) -> Unit {
  ignore(self)
  let graph = match
    force_graph.get_internal_node_property(force_internal_origin) {
    Some(graph) => graph
    None => return
  }
  let mut min_x = 1.0e20
  let mut min_y = 1.0e20
  let mut max_x = -1.0e20
  let mut max_y = -1.0e20
  for node in force_graph.get_nodes() {
    let position = fnode_position(node)
    let size = fnode_size(node)
    min_x = force_min(min_x, position.x - size.x / 2.0)
    min_y = force_min(min_y, position.y - size.y / 2.0)
    max_x = force_max(max_x, position.x + size.x / 2.0)
    max_y = force_max(max_y, position.y + size.y / 2.0)
  }
  for bendpoint in force_graph.get_bendpoints() {
    let position = fbendpoint_position(bendpoint)
    let size = fbendpoint_size(bendpoint)
    min_x = force_min(min_x, position.x - size.x / 2.0)
    min_y = force_min(min_y, position.y - size.y / 2.0)
    max_x = force_max(max_x, position.x + size.x / 2.0)
    max_y = force_max(max_y, position.y + size.y / 2.0)
  }
  let padding = force_graph.get_padding_property(force_padding)
  let offset = new_kvector_xy(
    padding.get_left() - min_x,
    padding.get_top() - min_y,
  )
  for node in force_graph.get_nodes() {
    match fnode_origin(node) {
      Some(origin_node) => {
        let node_position = fnode_position(node).clone().add(offset)
        node_set_location(
          origin_node,
          node_position.x - node_width(origin_node) / 2.0,
          node_position.y - node_height(origin_node) / 2.0,
        )
      }
      None => ()
    }
  }
  for edge in force_graph.get_edges() {
    match fedge_origin(edge) {
      Some(origin_edge) => {
        let start_position = fedge_source_point(edge).clone().add(offset)
        let end_position = fedge_target_point(edge).clone().add(offset)
        let first_section = first_or_create_edge_section(origin_edge)
        if fedge_bendpoints(edge).is_empty() {
          edge_section_set_start(
            first_section,
            start_position.x,
            start_position.y,
          )
          edge_section_set_end(first_section, end_position.x, end_position.y)
        } else {
          edge_section_set_start(
            first_section,
            start_position.x,
            start_position.y,
          )
          edge_section_set_outgoing_shape(first_section, None)
          let mut previous_section = first_section
          for bendpoint in fedge_bendpoints(edge) {
            let bendpoint_position = fbendpoint_position(bendpoint)
              .clone()
              .add(offset)
            edge_section_set_end(
              previous_section,
              bendpoint_position.x,
              bendpoint_position.y,
            )
            let next_section = create_edge_section(origin_edge)
            edge_section_set_start(
              next_section,
              bendpoint_position.x,
              bendpoint_position.y,
            )
            edge_section_set_incoming_shape(next_section, None)
            edge_section_set_outgoing_shape(next_section, None)
            edge_section_add_outgoing_section(previous_section, next_section)
            edge_section_add_incoming_section(next_section, previous_section)
            previous_section = next_section
          }
          edge_section_set_end(previous_section, end_position.x, end_position.y)
          let targets = edge_targets(origin_edge)
          if targets.length() == 1 {
            edge_section_set_outgoing_shape(previous_section, Some(targets[0]))
          }
        }
      }
      None => ()
    }
  }
  for label in force_graph.get_labels() {
    match flabel_origin(label) {
      Some(origin_label) => {
        let label_position = flabel_position(label).clone().add(offset)
        label_set_location(origin_label, label_position.x, label_position.y)
      }
      None => ()
    }
  }
  let width = max_x - min_x + padding.get_horizontal()
  let height = max_y - min_y + padding.get_vertical()
  if !node_get_bool_property(graph, node_size_fixed_graph_size) {
    node_set_dimensions(graph, width, height)
  }
  node_set_double_property(
    graph,
    child_area_width,
    width - padding.get_horizontal(),
  )
  node_set_double_property(
    graph,
    child_area_height,
    height - padding.get_vertical(),
  )
}

///|
pub fn elk_graph_importer_as_igraph_importer(
  importer : ElkGraphImporter,
) -> IGraphImporter[ElkNode] {
  new_igraph_importer(graph => importer.import_graph(graph), force_graph => {
    importer.apply_layout(force_graph)
  })
}
