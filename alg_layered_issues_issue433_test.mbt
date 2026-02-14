///|
fn issue433_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue433 self-loop label stays inside graph bounds" {
  reset_graph_model_for_test()
  issue433_test_setup_plain_java_layout()

  let graph = create_graph()
  let node = create_node(Some(graph))
  node_set_dimensions(node, 80.0, 50.0)

  let loop_edge = create_edge(None)
  edge_add_source(loop_edge, make_node_shape(node))
  edge_add_target(loop_edge, make_node_shape(node))
  update_containment(Some(loop_edge))

  let label = create_label(Some(make_edge_label_parent(loop_edge)))
  label_set_text(label, "self-loop")
  label_set_dimensions(label, 30.0, 10.0)

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())

  assert_true(label_x(label) >= 0.0)
  assert_true(label_y(label) >= 0.0)
  assert_true(label_x(label) + label_width(label) <= node_width(graph))
  assert_true(label_y(label) + label_height(label) <= node_height(graph))
}
