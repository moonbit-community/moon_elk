///|
fn shared_plain_layout_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "PlainLayoutTest hierarchical layout does not fail" {
  reset_graph_model_for_test()
  shared_plain_layout_test_setup_plain_java_layout()

  let parent_node = graph_test_utils_create_hierarchical_graph()
  for node in graph_test_utils_all_nodes(parent_node, true) {
    if !node_children(node).is_empty() {
      node_set_string_property(node, algorithm, "org.eclipse.elk.layered")
    }
  }

  let progress_monitor = new_basic_progress_monitor()
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(parent_node, progress_monitor)

  for node in graph_test_utils_all_nodes(parent_node, false) {
    assert_true(node_x(node) >= 0.0)
    assert_true(node_y(node) >= 0.0)
  }
}
