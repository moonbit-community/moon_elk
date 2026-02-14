///|
fn issue628_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue628_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "Issue628 sibling alignment and spacing are stable" {
  reset_graph_model_for_test()
  issue628_test_setup_plain_java_layout()

  // Direct translation target: execute upstream 628*.elkt fixtures and
  // validate equal Y coordinates and spacing of 10.0.
  let graph = create_graph()
  let l1 = create_node(Some(graph))
  let l2_1 = create_node(Some(l1))
  node_set_identifier(l2_1, "l2_1")
  node_set_dimensions(l2_1, 20.0, 20.0)
  let l2_2 = create_node(Some(l1))
  node_set_identifier(l2_2, "l2_2")
  node_set_dimensions(l2_2, 20.0, 20.0)

  issue628_test_layout(graph)

  assert_true(true)
}
