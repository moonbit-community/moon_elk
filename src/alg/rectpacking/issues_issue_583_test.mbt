///|
test "Rectpacking issue 583 decrease approximated width" {
  reset_graph_model_for_test()

  let parent = create_graph()
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))

  @graph.node_set_string_property(parent, @core.algorithm, rectpacking_algorithm_id)
  @graph.node_set_double_property(parent, rectpacking_aspect_ratio, 1.3)
  @graph.node_set_double_property(parent, rectpacking_spacing_node_node, 0.0)
  @graph.node_set_string_property(
    parent, rectpacking_padding, "[top=0,right=0,bottom=0,left=0]",
  )
  @graph.node_set_string_property(
    parent, rectpacking_width_approximation_strategy, "GREEDY",
  )
  @graph.node_set_string_property(
    parent, rectpacking_white_space_elimination_strategy, "NONE",
  )

  @graph.node_set_dimensions(n1, 30.0, 30.0)
  @graph.node_set_dimensions(n2, 10.0, 10.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 40.0, 10.0)

  @graph.node_set_string_property(parent, rectpacking_packing_strategy, "NONE")
  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())
  rectpacking_assert_close(@graph.node_width(parent), 60.0, 1.0)

  @graph.node_set_string_property(parent, rectpacking_packing_strategy, "COMPACTION")
  let provider2 = new_rectpacking_layout_provider()
  provider2.layout(parent, @core.new_basic_progress_monitor())
  rectpacking_assert_close(@graph.node_width(parent), 40.0, 1.0)
}
