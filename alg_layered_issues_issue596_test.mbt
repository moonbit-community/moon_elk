///|
fn issue596_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue596_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "Issue596 single child stays centered in outer node" {
  reset_graph_model_for_test()
  issue596_test_setup_plain_java_layout()

  let graph = create_graph()
  let outer = create_node(Some(graph))
  node_set_dimensions(outer, 120.0, 80.0)

  let inner = create_node(Some(outer))
  node_set_dimensions(inner, 120.0, 40.0)
  node_set_location(inner, 0.0, 20.0)

  issue596_test_layout(graph)

  let expected_x = (node_width(outer) - node_width(inner)) / 2.0
  assert_true((node_x(inner) - expected_x).abs() <= 0.5)
}
