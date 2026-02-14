///|
fn issue447_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue447_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "Issue447 edge endpoints connect to hierarchical port anchors" {
  reset_graph_model_for_test()
  issue447_test_setup_plain_java_layout()

  // Direct translation target: this test should validate that edge section
  // endpoints match hierarchical port anchors in upstream model
  // 447_hierarchicalPortAnchors.elkt.
  let graph = create_graph()
  let left = create_node(Some(graph))
  let right = create_node(Some(graph))

  let left_port = create_port(Some(left))
  port_set_dimensions(left_port, 10.0, 10.0)
  let right_port = create_port(Some(right))
  port_set_dimensions(right_port, 10.0, 10.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(left_port))
  edge_add_target(edge, make_port_shape(right_port))
  update_containment(Some(edge))

  issue447_test_layout(graph)

  assert_eq(node_contained_edges(graph).length(), 1)
}
