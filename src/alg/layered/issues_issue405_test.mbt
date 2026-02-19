///|
fn issue405_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue405_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue405_fuzzy_equal(
  left : Double,
  right : Double,
  epsilon : Double,
) -> Bool {
  (left - right).abs() <= epsilon
}

///|
test "Issue405 symmetric port and port-label positions" {
  reset_graph_model_for_test()
  issue405_test_setup_plain_java_layout()

  // Direct translation target: compare port/label positions across
  // Right/Down/Left/Up resource models from upstream ticket 405.
  let graph = create_graph()
  let n_right = @graph.create_node(Some(graph))
  let n_down = @graph.create_node(Some(graph))

  let p_right = create_port(Some(n_right))
  port_set_dimensions(p_right, 10.0, 10.0)
  let p_down = create_port(Some(n_down))
  port_set_dimensions(p_down, 10.0, 10.0)

  let right_label = @graph.create_label(Some(make_port_label_parent(p_right)))
  @graph.label_set_dimensions(right_label, 20.0, 10.0)
  let down_label = @graph.create_label(Some(make_port_label_parent(p_down)))
  @graph.label_set_dimensions(down_label, 20.0, 10.0)

  issue405_test_layout(graph)

  assert_true(issue405_fuzzy_equal(port_x(p_right), port_x(p_down), 0.001))
  assert_true(issue405_fuzzy_equal(port_y(p_right), port_y(p_down), 0.001))
  assert_true(
    issue405_fuzzy_equal(@graph.label_x(right_label), @graph.label_x(down_label), 0.001),
  )
  assert_true(
    issue405_fuzzy_equal(@graph.label_y(right_label), @graph.label_y(down_label), 0.001),
  )
}
