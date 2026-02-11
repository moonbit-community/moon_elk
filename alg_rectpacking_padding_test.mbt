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
  parent : ElkNode,
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
) -> Unit {
  node_set_string_property(parent, algorithm, rectpacking_algorithm_id)
  node_set_double_property(parent, rectpacking_aspect_ratio, 1.3)
  node_set_double_property(parent, rectpacking_spacing_node_node, 10.0)
  node_set_string_property(
    parent,
    rectpacking_padding,
    "[top=\{top},right=\{right},bottom=\{bottom},left=\{left}]",
  )
  node_set_string_property(
    parent, rectpacking_width_approximation_strategy, "GREEDY",
  )
  node_set_string_property(parent, rectpacking_packing_strategy, "COMPACTION")
  node_set_string_property(
    parent, rectpacking_white_space_elimination_strategy, "NONE",
  )
}

///|
fn rectpacking_create_four_30_nodes(
  parent : ElkNode,
) -> (ElkNode, ElkNode, ElkNode, ElkNode) {
  let n1 = create_node(Some(parent))
  let n2 = create_node(Some(parent))
  let n3 = create_node(Some(parent))
  let n4 = create_node(Some(parent))
  node_set_dimensions(n1, 30.0, 30.0)
  node_set_dimensions(n2, 30.0, 30.0)
  node_set_dimensions(n3, 30.0, 30.0)
  node_set_dimensions(n4, 30.0, 30.0)
  (n1, n2, n3, n4)
}

///|
test "Rectpacking padding top" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 1000.0, 0.0, 0.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  rectpacking_assert_close(node_width(parent), 150.0, 1.0)
  rectpacking_assert_close(node_height(parent), 1030.0, 1.0)
  rectpacking_assert_close(node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(node_y(n1), 1000.0, 1.0)
  rectpacking_assert_close(node_x(n2), 40.0, 1.0)
  rectpacking_assert_close(node_y(n2), 1000.0, 1.0)
  rectpacking_assert_close(node_x(n3), 80.0, 1.0)
  rectpacking_assert_close(node_y(n3), 1000.0, 1.0)
  rectpacking_assert_close(node_x(n4), 120.0, 1.0)
  rectpacking_assert_close(node_y(n4), 1000.0, 1.0)
}

///|
test "Rectpacking padding left" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 0.0, 0.0, 1000.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  rectpacking_assert_close(node_width(parent), 1030.0, 1.0)
  rectpacking_assert_close(node_height(parent), 150.0, 1.0)
  rectpacking_assert_close(node_x(n1), 1000.0, 1.0)
  rectpacking_assert_close(node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(node_x(n2), 1000.0, 1.0)
  rectpacking_assert_close(node_y(n2), 40.0, 1.0)
  rectpacking_assert_close(node_x(n3), 1000.0, 1.0)
  rectpacking_assert_close(node_y(n3), 80.0, 1.0)
  rectpacking_assert_close(node_x(n4), 1000.0, 1.0)
  rectpacking_assert_close(node_y(n4), 120.0, 1.0)
}

///|
test "Rectpacking padding bottom" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 0.0, 1000.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  rectpacking_assert_close(node_width(parent), 150.0, 1.0)
  rectpacking_assert_close(node_height(parent), 1030.0, 1.0)
  rectpacking_assert_close(node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(node_x(n2), 40.0, 1.0)
  rectpacking_assert_close(node_y(n2), 0.0, 1.0)
  rectpacking_assert_close(node_x(n3), 80.0, 1.0)
  rectpacking_assert_close(node_y(n3), 0.0, 1.0)
  rectpacking_assert_close(node_x(n4), 120.0, 1.0)
  rectpacking_assert_close(node_y(n4), 0.0, 1.0)
}

///|
test "Rectpacking padding right" {
  reset_graph_model_for_test()
  let parent = create_graph()
  let (n1, n2, n3, n4) = rectpacking_create_four_30_nodes(parent)
  rectpacking_set_padding_case_options(parent, 0.0, 1000.0, 0.0, 0.0)

  let provider = new_rectpacking_layout_provider()
  provider.layout(parent, new_basic_progress_monitor())

  rectpacking_assert_close(node_width(parent), 1030.0, 1.0)
  rectpacking_assert_close(node_height(parent), 150.0, 1.0)
  rectpacking_assert_close(node_x(n1), 0.0, 1.0)
  rectpacking_assert_close(node_y(n1), 0.0, 1.0)
  rectpacking_assert_close(node_x(n2), 0.0, 1.0)
  rectpacking_assert_close(node_y(n2), 40.0, 1.0)
  rectpacking_assert_close(node_x(n3), 0.0, 1.0)
  rectpacking_assert_close(node_y(n3), 80.0, 1.0)
  rectpacking_assert_close(node_x(n4), 0.0, 1.0)
  rectpacking_assert_close(node_y(n4), 120.0, 1.0)
}
