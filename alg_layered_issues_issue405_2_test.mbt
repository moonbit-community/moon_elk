///|
fn issue405_2_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue405_2_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn issue405_2_fuzzy_equal(
  left : Double,
  right : Double,
  epsilon : Double,
) -> Bool {
  (left - right).abs() <= epsilon
}

///|
#skip
test "Issue405_2 permissive coordinate matching for asymmetric label placement" {
  reset_graph_model_for_test()
  issue405_2_test_setup_plain_java_layout()

  // Direct translation target: run on upstream asymmetric ticket-405 models
  // and compare either x or y depending on port side.
  let graph = create_graph()
  let node = create_node(Some(graph))
  let p1 = create_port(Some(node))
  let p2 = create_port(Some(node))

  let l1 = create_label(Some(make_port_label_parent(p1)))
  label_set_dimensions(l1, 20.0, 10.0)
  let l2 = create_label(Some(make_port_label_parent(p2)))
  label_set_dimensions(l2, 20.0, 10.0)

  issue405_2_test_layout(graph)

  let x_matches = issue405_2_fuzzy_equal(label_x(l1), label_x(l2), 0.001)
  let y_matches = issue405_2_fuzzy_equal(label_y(l1), label_y(l2), 0.001)
  assert_true(x_matches || y_matches)
}
