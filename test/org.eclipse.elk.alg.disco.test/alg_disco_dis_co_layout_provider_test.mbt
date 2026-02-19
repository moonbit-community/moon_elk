///|
test "DisCoLayoutProvider runs polyomino compaction end-to-end" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_dimensions(root, 120.0, 60.0)

  let left = create_node(Some(root))
  node_set_location(left, 0.0, 0.0)
  node_set_dimensions(left, 20.0, 10.0)

  let right = create_node(Some(root))
  node_set_location(right, 80.0, 0.0)
  node_set_dimensions(right, 20.0, 10.0)

  node_set_double_property(root, disco_spacing_component_component, 12.0)
  node_set_bool_property(root, disco_polyomino_fill, false)
  node_set_string_property(
    root, disco_component_compaction_strategy, "POLYOMINO",
  )
  node_set_string_property(
    root, disco_padding, "[left=4,top=4,right=4,bottom=4]",
  )

  let before_left_x = node_x(left)
  let before_right_x = node_x(right)

  let provider = new_dis_co_layout_provider()
  let monitor = new_elk_progress_monitor()
  provider.layout(root, monitor)

  assert_eq(monitor.is_running(), false)
  assert_true(node_width(root) > 0.0)
  assert_true(node_height(root) > 0.0)
  assert_true(node_x(left) != before_left_x || node_x(right) != before_right_x)
}
