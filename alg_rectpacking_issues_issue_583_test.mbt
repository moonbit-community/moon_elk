///|
test "Rectpacking issue 583 decrease approximated width" {
  reset_graph_model_for_test()

  let parent = create_graph()
  let n1 = create_node(Some(parent))
  let n2 = create_node(Some(parent))
  let n3 = create_node(Some(parent))
  let n4 = create_node(Some(parent))

  node_set_string_property(parent, algorithm, rectpacking_algorithm_id)
  node_set_double_property(parent, rectpacking_aspect_ratio, 1.3)
  node_set_double_property(parent, rectpacking_spacing_node_node, 0.0)
  node_set_string_property(
    parent, rectpacking_padding, "[top=0,right=0,bottom=0,left=0]",
  )
  node_set_string_property(
    parent, rectpacking_width_approximation_strategy, "GREEDY",
  )
  node_set_string_property(
    parent, rectpacking_white_space_elimination_strategy, "NONE",
  )

  node_set_dimensions(n1, 30.0, 30.0)
  node_set_dimensions(n2, 10.0, 10.0)
  node_set_dimensions(n3, 30.0, 30.0)
  node_set_dimensions(n4, 40.0, 10.0)

  node_set_string_property(parent, rectpacking_packing_strategy, "NONE")
  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())
  rectpacking_assert_close(node_width(parent), 60.0, 1.0)

  node_set_string_property(parent, rectpacking_packing_strategy, "COMPACTION")
  let provider2 = new_rectpacking_layout_provider()
  provider2.layout(parent, new_basic_progress_monitor())
  rectpacking_assert_close(node_width(parent), 40.0, 1.0)
}
