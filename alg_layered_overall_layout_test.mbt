///|
fn overall_layout_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn overall_layout_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
test "Overall layered layout assigns positive coordinates and size" {
  reset_graph_model_for_test()
  overall_layout_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")

  let n1 = create_node(Some(graph))
  node_set_dimensions(n1, 30.0, 30.0)
  let n2 = create_node(Some(graph))
  node_set_dimensions(n2, 30.0, 30.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))

  overall_layout_test_layout(graph)

  for node in node_children(graph) {
    assert_true(node_x(node) > 0.0)
    assert_true(node_y(node) > 0.0)
  }

  for routed_edge in node_contained_edges(graph) {
    for section in edge_sections(routed_edge) {
      assert_true(edge_section_start_x(section) > 0.0)
      assert_true(edge_section_start_y(section) > 0.0)
      assert_true(edge_section_end_x(section) > 0.0)
      assert_true(edge_section_end_y(section) > 0.0)
      assert_true(
        edge_section_start_x(section) == edge_section_end_x(section) ||
        edge_section_start_y(section) == edge_section_end_y(section),
      )
    }
  }

  assert_true(node_width(graph) > 0.0)
  assert_true(node_height(graph) > 0.0)
}
