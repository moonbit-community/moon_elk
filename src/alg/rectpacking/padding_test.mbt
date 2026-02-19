///|
fn rectpacking_assert_close(
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
fn rectpacking_set_padding_case_options(
  parent : @graph.ElkNode,
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
) -> Unit {
  @graph.node_set_string_property(parent, @core.algorithm, rectpacking_algorithm_id)
  @graph.node_set_double_property(parent, rectpacking_aspect_ratio, 1.3)
  @graph.node_set_double_property(parent, rectpacking_spacing_node_node, 10.0)
  @graph.node_set_string_property(
    parent,
    rectpacking_padding,
    "[top=\{top},right=\{right},bottom=\{bottom},left=\{left}]",
  )
  @graph.node_set_string_property(
    parent, rectpacking_width_approximation_strategy, "GREEDY",
  )
  @graph.node_set_string_property(parent, rectpacking_packing_strategy, "COMPACTION")
  @graph.node_set_string_property(
    parent, rectpacking_white_space_elimination_strategy, "NONE",
  )
}

///|
fn rectpacking_create_four_30_nodes(
  parent : @graph.ElkNode,
) -> (@graph.ElkNode, @graph.ElkNode, @graph.ElkNode, @graph.ElkNode) {
  let n1 = @graph.create_node(Some(parent))
  let n2 = @graph.create_node(Some(parent))
  let n3 = @graph.create_node(Some(parent))
  let n4 = @graph.create_node(Some(parent))
  @graph.node_set_dimensions(n1, 30.0, 30.0)
  @graph.node_set_dimensions(n2, 30.0, 30.0)
  @graph.node_set_dimensions(n3, 30.0, 30.0)
  @graph.node_set_dimensions(n4, 30.0, 30.0)
  (n1, n2, n3, n4)
}

///|
test "Rectpacking @core.padding top" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 1000.0, 0.0, 0.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  rectpacking_assert_close(@graph.node_width(parent), 150.0, 1.0)
  rectpacking_assert_close(@graph.node_height(parent), 1030.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n1), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n2), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n3), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n4), 120.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n4), 1000.0, 1.0)
}

///|
test "Rectpacking @core.padding left" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 0.0, 0.0, 1000.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  rectpacking_assert_close(@graph.node_width(parent), 1030.0, 1.0)
  rectpacking_assert_close(@graph.node_height(parent), 150.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n1), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n2), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n2), 40.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n3), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n3), 80.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n4), 1000.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n4), 120.0, 1.0)
}

///|
test "Rectpacking @core.padding bottom" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 0.0, 1000.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  rectpacking_assert_close(@graph.node_width(parent), 150.0, 1.0)
  rectpacking_assert_close(@graph.node_height(parent), 1030.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n2), 40.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n2), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n3), 80.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n3), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n4), 120.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n4), 0.0, 1.0)
}

///|
test "Rectpacking @core.padding right" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 1000.0, 0.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, @core.new_basic_progress_monitor())

  rectpacking_assert_close(@graph.node_width(parent), 1030.0, 1.0)
  rectpacking_assert_close(@graph.node_height(parent), 150.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n2), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n2), 40.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n3), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n3), 80.0, 1.0)
  rectpacking_assert_close(@graph.node_x(n4), 0.0, 1.0)
  rectpacking_assert_close(@graph.node_y(n4), 120.0, 1.0)
}
