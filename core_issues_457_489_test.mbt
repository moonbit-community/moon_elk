///|
fn setup_core_issue_tests_registry() -> Unit {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
}

///|
test "Issue457 node minimum size respected for box layout" {
  reset_graph_model_for_test()
  setup_core_issue_tests_registry()
  let root = create_graph()
  node_set_string_property(root, algorithm, "org.eclipse.elk.box")
  for _ in 0..<2 {
    let node = create_node(Some(root))
    node_set_string_property(node, algorithm, "org.eclipse.elk.box")
    let child = create_node(Some(node))
    node_set_dimensions(child, 5.0, 5.0)
    node_set_string_set_property(node, node_size_constraints, ["MINIMUM_SIZE"])
    node_set_string_property(
      node,
      node_size_minimum,
      new_kvector_xy(60.0, 60.0).to_string(),
    )
  }

  let engine = new_recursive_graph_layout_engine()
  engine.layout(root, new_basic_progress_monitor())

  for node in node_children(root) {
    assert_true((node_width(node) - 60.0).abs() <= 1.0)
    assert_true((node_height(node) - 60.0).abs() <= 1.0)
  }
}

///|
test "Issue489 child placement respects node padding" {
  reset_graph_model_for_test()
  setup_core_issue_tests_registry()
  let root = create_graph()
  node_set_string_property(root, algorithm, "org.eclipse.elk.box")
  let configured = [
    (new_kvector_xy(8.0, 8.0), new_kvector_xy(2.0, 2.0)),
    (new_kvector_xy(200.0, 140.0), new_kvector_xy(80.0, 45.0)),
  ]
  for pair in configured {
    let node = create_node(Some(root))
    node_set_string_property(node, algorithm, "org.eclipse.elk.box")
    node_set_dimensions(node, pair.0.x, pair.0.y)
    node_set_string_property(
      node,
      padding,
      new_elk_padding_any(5.0).to_string(),
    )
    let child = create_node(Some(node))
    node_set_dimensions(child, pair.1.x, pair.1.y)
  }

  let engine = new_recursive_graph_layout_engine()
  engine.layout(root, new_basic_progress_monitor())

  for node in node_children(root) {
    assert_eq(node_children(node).length(), 1)
    let child = node_children(node)[0]
    assert_true((node_x(child) - 5.0).abs() <= 0.1)
    assert_true((node_y(child) - 5.0).abs() <= 0.1)
    assert_true((node_width(child) - (node_width(node) - 10.0)).abs() <= 0.1)
    assert_true((node_height(child) - (node_height(node) - 10.0)).abs() <= 0.1)
  }
}
