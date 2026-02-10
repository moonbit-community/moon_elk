///|
pub struct RecursiveGraphLayoutEngine {
  marker : Int
}

///|
pub fn new_recursive_graph_layout_engine() -> RecursiveGraphLayoutEngine {
  { marker: 0 }
}

///|
fn max_positive(value : Double, fallback : Double) -> Double {
  if value > 0.0 {
    value
  } else {
    fallback
  }
}

///|
fn parse_node_padding(node : ElkNode) -> ElkPadding {
  let parsed = new_elk_padding()
  parsed.parse(node_get_string_property(node, padding))
  parsed
}

///|
fn parse_node_minimum_size(node : ElkNode) -> KVector {
  let parsed = new_kvector()
  parsed.parse(node_get_string_property(node, node_size_minimum))
  parsed
}

///|
fn has_minimum_size_constraint(node : ElkNode) -> Bool {
  for value in node_get_string_set_property(node, node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn node_layout_option_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_layout_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn node_individual_spacing_value_by_candidates(
  node : ElkNode,
  candidates : Array[String],
) -> String? {
  for candidate in candidates {
    match node_individual_spacing_option_string_value(node, candidate) {
      Some(value) => return Some(value)
      None => ()
    }
  }
  None
}

///|
fn placement_tokens(value : String) -> Array[String] {
  let normalized = value
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
  let tokens = []
  for token_view in normalized.split(",") {
    let token = token_view.trim().to_string()
    if !token.is_empty() {
      tokens.push(token)
    }
  }
  tokens
}

///|
fn has_placement_token(tokens : Array[String], expected : String) -> Bool {
  for token in tokens {
    if token == expected {
      return true
    }
  }
  false
}

///|
fn node_label_padding_top(node : ElkNode) -> Double {
  let keys = [
    "nodeLabels.padding", "elk.nodeLabels.padding", "org.eclipse.elk.nodeLabels.padding",
  ]
  let padding_text = match
    node_individual_spacing_value_by_candidates(node, keys) {
    Some(value) => value
    None =>
      match node_layout_option_value_by_candidates(node, keys) {
        Some(value) => value
        None => return 0.0
      }
  }
  let parsed = new_elk_padding()
  parsed.parse(padding_text)
  parsed.top
}

///|
fn recursive_layout_node_labels(node : ElkNode) -> Unit {
  let keys = [
    "nodeLabels.placement", "elk.nodeLabels.placement", "org.eclipse.elk.nodeLabels.placement",
  ]
  let tokens = match node_layout_option_value_by_candidates(node, keys) {
    Some(value) => placement_tokens(value)
    None =>
      if node_has_string_set_property(node, node_labels_placement) {
        node_get_string_set_property(node, node_labels_placement)
      } else {
        return
      }
  }
  if !(has_placement_token(tokens, "INSIDE") &&
    has_placement_token(tokens, "V_TOP")) {
    return
  }
  let top = node_label_padding_top(node)
  for label in node_labels(node) {
    label_set_location(label, label_x(label), top)
  }
}

///|
fn ensure_edge_section_for_edge(edge : ElkEdge) -> Unit {
  if !edge_sections(edge).is_empty() {
    return
  }
  if edge_sources(edge).length() != 1 || edge_targets(edge).length() != 1 {
    return
  }
  let source_shape = edge_sources(edge)[0]
  let target_shape = edge_targets(edge)[0]
  match source_shape {
    NodeShape(source_node) =>
      match target_shape {
        NodeShape(target_node) => {
          let section = create_edge_section(edge)
          let start_x = node_x(source_node) +
            max_positive(node_width(source_node), 10.0)
          let start_y = node_y(source_node) +
            max_positive(node_height(source_node), 10.0) / 2.0
          let end_x = node_x(target_node)
          let end_y = node_y(target_node) +
            max_positive(node_height(target_node), 10.0) / 2.0
          edge_section_set_start(section, start_x, start_y)
          edge_section_set_end(section, end_x, end_y)
          edge_section_set_incoming_shape(section, Some(source_shape))
          edge_section_set_outgoing_shape(section, Some(target_shape))
        }
        _ => ()
      }
    _ => ()
  }
}

///|
fn layout_node_recursively(
  node : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if node_get_bool_property(node, no_layout) {
    return
  }
  let children = node_children(node)
  for child in children {
    layout_node_recursively(child, progress_monitor)
  }
  if children.is_empty() {
    recursive_layout_node_labels(node)
    return
  }
  let resolved = node_get_string_property(node, resolved_algorithm)
  if resolved.is_empty() {
    abort("Resolved algorithm is not set")
  }
  if layout_meta_data_service_get_algorithm_data_by_suffix(resolved) is None {
    abort("Resolved algorithm is unknown")
  }
  if resolved == mrtree_algorithm_id {
    let provider = new_mrtree_tree_layout_provider()
    provider.layout(node, progress_monitor)
    return
  }
  let mut rightmost = 0.0
  let mut max_height = 0.0
  let mut cursor_x = 12.0
  for child in children {
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    node_set_dimensions(child, child_width, child_height)
    node_set_location(child, cursor_x, 12.0)
    let child_right = cursor_x + child_width
    if child_right > rightmost {
      rightmost = child_right
    }
    cursor_x = child_right + 20.0
    if child_height > max_height {
      max_height = child_height
    }
  }
  for edge in node_contained_edges(node) {
    ensure_edge_section_for_edge(edge)
  }
  let padding_value = parse_node_padding(node)
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(node_width(child), 10.0)
    let child_height = max_positive(node_height(child), 10.0)
    let requested_width = child_width + padding_value.left + padding_value.right
    let requested_height = child_height +
      padding_value.top +
      padding_value.bottom
    if requested_width > rightmost + 12.0 {
      rightmost = requested_width - 12.0
    }
    if requested_height > max_height + 24.0 {
      max_height = requested_height - 24.0
    }
  }
  let mut width = max_positive(rightmost + 12.0, 10.0)
  let mut height = max_positive(max_height + 24.0, 10.0)
  if has_minimum_size_constraint(node) {
    let min_size = parse_node_minimum_size(node)
    if width < min_size.x {
      width = min_size.x
    }
    if height < min_size.y {
      height = min_size.y
    }
  }
  node_set_dimensions(node, width, height)
  if children.length() == 1 {
    let child = children[0]
    let child_width = max_positive(
      node_width(node) - padding_value.left - padding_value.right,
      0.0,
    )
    let child_height = max_positive(
      node_height(node) - padding_value.top - padding_value.bottom,
      0.0,
    )
    node_set_location(child, padding_value.left, padding_value.top)
    node_set_dimensions(child, child_width, child_height)
  }
  recursive_layout_node_labels(node)
}

///|
pub fn RecursiveGraphLayoutEngine::layout(
  self : RecursiveGraphLayoutEngine,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(self)
  ignore(progress_monitor.begin("Recursive Graph Layout", 1.0))
  if node_get_string_property(layout_graph, resolved_algorithm).is_empty() {
    let resolver = new_layout_algorithm_resolver()
    apply_visitors(layout_graph, [resolver.to_visitor()])
  }
  layout_node_recursively(layout_graph, progress_monitor)
  progress_monitor.done()
}
