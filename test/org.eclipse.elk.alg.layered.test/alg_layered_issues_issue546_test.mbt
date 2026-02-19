///|
fn issue546_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue546_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue546_node_absolute_x(node : ElkNode) -> Double {
  match node_parent(node) {
    Some(parent) => issue546_node_absolute_x(parent) + node_x(node)
    None => node_x(node)
  }
}

///|
fn issue546_node_absolute_y(node : ElkNode) -> Double {
  match node_parent(node) {
    Some(parent) => issue546_node_absolute_y(parent) + node_y(node)
    None => node_y(node)
  }
}

///|
fn issue546_port_rect_contains_start_point(
  port : ElkPort,
  section : ElkEdgeSection,
) -> Bool {
  let tolerance = 0.5
  match port_parent(port) {
    Some(parent) => {
      let abs_x = issue546_node_absolute_x(parent) + port_x(port)
      let abs_y = issue546_node_absolute_y(parent) + port_y(port)
      let start_x = edge_section_start_x(section)
      let start_y = edge_section_start_y(section)
      start_x >= abs_x - tolerance &&
      start_x <= abs_x + port_width(port) + tolerance &&
      start_y >= abs_y - tolerance &&
      start_y <= abs_y + port_height(port) + tolerance
    }
    None => false
  }
}

///|
test "Issue546 routed edge starts on source port rectangle" {
  reset_graph_model_for_test()
  issue546_test_setup_plain_java_layout()

  let graph = create_graph()

  let n1 = create_node(Some(graph))
  node_set_dimensions(n1, 60.0, 40.0)
  let n2 = create_node(Some(graph))
  node_set_dimensions(n2, 60.0, 40.0)

  let src_port = create_port(Some(n1))
  port_set_dimensions(src_port, 10.0, 10.0)
  let dst_port = create_port(Some(n2))
  port_set_dimensions(dst_port, 10.0, 10.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(src_port))
  edge_add_target(edge, make_port_shape(dst_port))
  update_containment(Some(edge))

  issue546_test_layout(graph)

  for section in edge_sections(edge) {
    assert_true(issue546_port_rect_contains_start_point(src_port, section))
  }
}
