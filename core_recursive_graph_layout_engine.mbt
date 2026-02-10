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
  node_set_dimensions(
    node,
    max_positive(rightmost + 12.0, 10.0),
    max_positive(max_height + 24.0, 10.0),
  )
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
