///|
fn rectpacking_compaction_assert_close(
  actual : Double,
  expected : Double,
  eps : Double,
) -> Unit {
  let diff = (actual - expected).abs()
  if diff > eps {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn rectpacking_compaction_setup_parent(
  target_width : Double,
  spacing : Double,
) -> @graph.ElkNode {
  let parent = create_graph()
  @graph.node_set_string_property(parent, @core.algorithm, rectpacking_algorithm_id)
  @graph.node_set_double_property(parent, rectpacking_aspect_ratio, 1.3)
  @graph.node_set_double_property(
    parent, rectpacking_width_approximation_target_width, target_width,
  )
  @graph.node_set_string_property(
    parent, rectpacking_width_approximation_strategy, "TARGET_WIDTH",
  )
  @graph.node_set_double_property(parent, rectpacking_spacing_node_node, spacing)
  @graph.node_set_string_property(
    parent, rectpacking_padding, "[top=0,right=0,bottom=0,left=0]",
  )
  @graph.node_set_string_property(parent, rectpacking_packing_strategy, "COMPACTION")
  @graph.node_set_string_property(
    parent, rectpacking_white_space_elimination_strategy, "NONE",
  )
  parent
}

///|
fn rectpacking_compaction_layout(parent : @graph.ElkNode) -> Unit {
  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())
}

///|
test "Rectpacking compaction place block from next row on top" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(110.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  let n6 = @graph.create_node(Some(parent))
  ignore(@graph.create_node(Some(parent)))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 10.0)
  @graph.node_set_dimensions(n3, 30.0, 10.0)
  @graph.node_set_dimensions(n4, 30.0, 50.0)
  @graph.node_set_dimensions(n5, 30.0, 50.0)
  @graph.node_set_dimensions(n6, 100.0, 10.0)
  @graph.node_set_dimensions(@graph.node_children(parent)[6], 100.0, 10.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 20.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 20.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n6), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n6), 80.0, 1.0)
}

///|
test "Rectpacking compaction place block from next row on top does not work" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(110.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  ignore(@graph.create_node(Some(parent)))
  ignore(@graph.create_node(Some(parent)))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 40.0, 10.0)
  @graph.node_set_dimensions(n3, 30.0, 10.0)
  @graph.node_set_dimensions(n4, 30.0, 50.0)
  @graph.node_set_dimensions(n5, 30.0, 50.0)
  @graph.node_set_dimensions(@graph.node_children(parent)[5], 100.0, 10.0)
  @graph.node_set_dimensions(@graph.node_children(parent)[6], 100.0, 10.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 100.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 170.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 20.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 80.0, 1.0)
}

///|
test "Rectpacking compaction absorb block" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(110.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  let n6 = @graph.create_node(Some(parent))
  ignore(@graph.create_node(Some(parent)))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  @graph.node_set_dimensions(n5, 30.0, 30.0)
  @graph.node_set_dimensions(n6, 100.0, 10.0)
  @graph.node_set_dimensions(@graph.node_children(parent)[6], 100.0, 10.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n6), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n6), 80.0, 1.0)
}

///|
test "Rectpacking compaction absorb block in stack" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(330.0, 1.0)

  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  let n6 = @graph.create_node(Some(parent))
  let n7 = @graph.create_node(Some(parent))
  let n8 = @graph.create_node(Some(parent))
  let n9 = @graph.create_node(Some(parent))
  let n10 = @graph.create_node(Some(parent))
  let n11 = @graph.create_node(Some(parent))
  let n12 = @graph.create_node(Some(parent))
  let n13 = @graph.create_node(Some(parent))
  let n14 = @graph.create_node(Some(parent))
  let n15 = @graph.create_node(Some(parent))
  let n16 = @graph.create_node(Some(parent))
  let n17 = @graph.create_node(Some(parent))
  let n18 = @graph.create_node(Some(parent))
  let n19 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 178.0, 162.0)
  @graph.node_set_dimensions(n2, 75.0, 23.0)
  @graph.node_set_dimensions(n3, 75.0, 23.0)
  @graph.node_set_dimensions(n4, 75.0, 23.0)
  @graph.node_set_dimensions(n5, 75.0, 23.0)
  @graph.node_set_dimensions(n6, 75.0, 23.0)
  @graph.node_set_dimensions(n7, 75.0, 23.0)
  @graph.node_set_dimensions(n8, 75.0, 23.0)
  @graph.node_set_dimensions(n9, 75.0, 23.0)
  @graph.node_set_dimensions(n10, 47.0, 23.0)
  @graph.node_set_dimensions(n11, 47.0, 23.0)
  @graph.node_set_dimensions(n12, 47.0, 23.0)
  @graph.node_set_dimensions(n13, 47.0, 23.0)
  @graph.node_set_dimensions(n14, 47.0, 23.0)
  @graph.node_set_dimensions(n15, 47.0, 23.0)
  @graph.node_set_dimensions(n16, 47.0, 23.0)
  @graph.node_set_dimensions(n17, 47.0, 23.0)
  @graph.node_set_dimensions(n18, 47.0, 23.0)
  @graph.node_set_dimensions(n19, 47.0, 23.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(
    @graph.node_width(parent),
    178.0 + 2.0 + 2.0 * 75.0,
    1.0,
  )
  rectpacking_compaction_assert_close(
    @graph.node_height(parent),
    162.0 + 1.0 + 23.0,
    1.0,
  )
}

///|
test "Rectpacking compaction compact block" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(190.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  @graph.node_set_dimensions(n5, 30.0, 30.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 40.0, 1.0)
}

///|
test "Rectpacking compaction split block" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(110.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  let n6 = @graph.create_node(Some(parent))
  let n7 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  @graph.node_set_dimensions(n5, 30.0, 30.0)
  @graph.node_set_dimensions(n6, 30.0, 30.0)
  @graph.node_set_dimensions(n7, 100.0, 10.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 130.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n6), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n6), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n7), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n7), 120.0, 1.0)
}

///|
test "Rectpacking compaction place block from next row right" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(110.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 20.0, 20.0)
  @graph.node_set_dimensions(n4, 30.0, 70.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 0.0, 1.0)
}

///|
test "Rectpacking compaction place block from current row right" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(150.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 20.0, 20.0)
  @graph.node_set_dimensions(n4, 30.0, 70.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 0.0, 1.0)
}

///|
test "Rectpacking compaction place block from current row on top" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(150.0, 10.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 70.0)
  @graph.node_set_dimensions(n2, 30.0, 10.0)
  @graph.node_set_dimensions(n3, 30.0, 10.0)
  @graph.node_set_dimensions(n4, 30.0, 50.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 110.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 40.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 20.0, 1.0)
}

///|
test "Rectpacking compaction place stack next to multiple block stack" {
  reset_graph_model_for_test()

  let parent = rectpacking_compaction_setup_parent(135.0, 5.0)
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  let n5 = @graph.create_node(Some(parent))
  let n6 = @graph.create_node(Some(parent))

  @graph.node_set_dimensions(n1, 30.0, 100.0)
  @graph.node_set_dimensions(n2, 30.0, 10.0)
  @graph.node_set_dimensions(n3, 30.0, 10.0)
  @graph.node_set_dimensions(n4, 30.0, 85.0)
  @graph.node_set_dimensions(n5, 30.0, 85.0)
  @graph.node_set_dimensions(n6, 30.0, 30.0)

  rectpacking_compaction_layout(parent)

  rectpacking_compaction_assert_close(@graph.node_width(parent), 135.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_height(parent), 100.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n2), 35.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n3), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n4), 35.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n4), 15.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n5), 70.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n5), 15.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_x(n6), 105.0, 1.0)
  rectpacking_compaction_assert_close(@graph.node_y(n6), 0.0, 1.0)
}
