///|
fn topdownpacking_assert_close(
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
fn topdownpacking_set_required_options(
  graph : ElkNode,
  spacing_value : Double,
  padding_value : String,
  hierarchical_width : Double,
  hierarchical_aspect_ratio : Double,
) -> Unit {
  node_set_double_property(
    graph, topdownpacking_spacing_node_node, spacing_value,
  )
  node_set_string_property(graph, topdownpacking_padding, padding_value)
  node_set_double_property(
    graph, topdownpacking_hierarchical_node_width, hierarchical_width,
  )
  node_set_double_property(
    graph, topdownpacking_hierarchical_node_aspect_ratio, hierarchical_aspect_ratio,
  )
}

///|
test "Topdownpacking predicted size from children count" {
  reset_graph_model_for_test()
  let graph = create_graph()
  ignore(create_node(Some(graph)))
  ignore(create_node(Some(graph)))
  ignore(create_node(Some(graph)))
  topdownpacking_set_required_options(
    graph, 5.0, "[left=10, top=20, right=30, bottom=40]", 100.0, 2.0,
  )
  let provider = new_topdownpacking_layout_provider()
  let predicted = provider.get_predicted_graph_size(graph)
  topdownpacking_assert_close(predicted.x, 245.0, 0.0001)
  topdownpacking_assert_close(predicted.y, 165.0, 0.0001)
}

///|
test "Topdownpacking layout places nodes on grid" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let n0 = create_node(Some(graph))
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let n3 = create_node(Some(graph))
  topdownpacking_set_required_options(
    graph, 0.0, "[left=0, top=0, right=0, bottom=0]", 10.0, 1.0,
  )
  let provider = new_topdownpacking_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  topdownpacking_assert_close(node_width(graph), 20.0, 0.0001)
  topdownpacking_assert_close(node_height(graph), 20.0, 0.0001)

  topdownpacking_assert_close(node_x(n0), 0.0, 0.0001)
  topdownpacking_assert_close(node_y(n0), 0.0, 0.0001)
  topdownpacking_assert_close(node_x(n1), 10.0, 0.0001)
  topdownpacking_assert_close(node_y(n1), 0.0, 0.0001)
  topdownpacking_assert_close(node_x(n2), 0.0, 0.0001)
  topdownpacking_assert_close(node_y(n2), 10.0, 0.0001)
  topdownpacking_assert_close(node_x(n3), 10.0, 0.0001)
  topdownpacking_assert_close(node_y(n3), 10.0, 0.0001)
}

///|
test "Topdownpacking whitespace elimination expands rows and columns" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_dimensions(graph, 30.0, 30.0)
  let n0 = create_node(Some(graph))
  let n1 = create_node(Some(graph))
  topdownpacking_set_required_options(
    graph, 0.0, "[left=0, top=0, right=0, bottom=0]", 10.0, 1.0,
  )
  let provider = new_topdownpacking_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  topdownpacking_assert_close(node_width(graph), 30.0, 0.0001)
  topdownpacking_assert_close(node_height(graph), 30.0, 0.0001)

  topdownpacking_assert_close(node_x(n0), 0.0, 0.0001)
  topdownpacking_assert_close(node_y(n0), 0.0, 0.0001)
  topdownpacking_assert_close(node_width(n0), 15.0, 0.0001)
  topdownpacking_assert_close(node_height(n0), 20.0, 0.0001)

  topdownpacking_assert_close(node_x(n1), 15.0, 0.0001)
  topdownpacking_assert_close(node_y(n1), 10.0, 0.0001)
  topdownpacking_assert_close(node_width(n1), 15.0, 0.0001)
  topdownpacking_assert_close(node_height(n1), 20.0, 0.0001)
}
