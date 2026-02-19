///|
fn issue700_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue700_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue700_test_edge_has_valid_section(edge : ElkEdge) -> Bool {
  if edge_sections(edge).length() != 1 {
    return false
  }
  let section = edge_sections(edge)[0]
  edge_section_start_x(section) != 0.0 ||
  edge_section_start_y(section) != 0.0 ||
  edge_section_end_x(section) != 0.0 ||
  edge_section_end_y(section) != 0.0
}

///|
fn issue700_test_edges_routed(node : ElkNode) -> Bool {
  for edge in node_contained_edges(node) {
    if !issue700_test_edge_has_valid_section(edge) {
      return false
    }
  }

  for child in node_children(node) {
    if !issue700_test_edges_routed(child) {
      return false
    }
  }
  true
}

///|
test "Issue700 routed edges always produce valid sections" {
  reset_graph_model_for_test()
  issue700_test_setup_plain_java_layout()

  let graph = create_graph()
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let n3 = create_node(Some(graph))

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(n1))
  edge_add_target(e1, make_node_shape(n2))
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(n2))
  edge_add_target(e2, make_node_shape(n3))
  update_containment(Some(e2))

  issue700_test_layout(graph)
  assert_true(issue700_test_edges_routed(graph))
}
