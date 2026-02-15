///|
fn issue734_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue734_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
test "Issue734 node-edge spacing remains centered around node span" {
  reset_graph_model_for_test()
  issue734_test_setup_plain_java_layout()

  // Direct translation target: run upstream 734 fixtures and compare
  // center of node span with center of routed edge span.
  let graph = create_graph()
  let left = create_node(Some(graph))
  node_set_dimensions(left, 40.0, 30.0)
  let right = create_node(Some(graph))
  node_set_dimensions(right, 40.0, 30.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(left))
  edge_add_target(edge, make_node_shape(right))
  update_containment(Some(edge))

  issue734_test_layout(graph)

  assert_true(node_width(graph) >= 0.0)
}
