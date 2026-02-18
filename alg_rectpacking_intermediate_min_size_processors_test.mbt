///|
test "Rectpacking min size pre processor stores minimum width and height" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_string_set_property(graph, node_size_constraints, ["MINIMUM_SIZE"])
  node_set_string_property(graph, node_size_minimum, "(120.0, 80.0)")

  new_rectpacking_min_size_pre_processor_layout_processor().process(graph, None)

  inspect(
    node_get_double_property(graph, rectpacking_internal_min_width),
    content="120",
  )
  inspect(
    node_get_double_property(graph, rectpacking_internal_min_height),
    content="80",
  )
}

///|
test "Rectpacking min size pre processor stores zero when no minimum size constraint exists" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_string_set_property(graph, node_size_constraints, [])
  node_set_string_property(graph, node_size_minimum, "(120.0, 80.0)")

  new_rectpacking_min_size_pre_processor_layout_processor().process(graph, None)

  inspect(
    node_get_double_property(graph, rectpacking_internal_min_width),
    content="0",
  )
  inspect(
    node_get_double_property(graph, rectpacking_internal_min_height),
    content="0",
  )
}

///|
test "Rectpacking min size post processor keeps target width at least minimum width" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_double_property(graph, rectpacking_internal_min_width, 120.0)
  node_set_double_property(graph, rectpacking_internal_target_width, 60.0)

  new_rectpacking_min_size_post_processor_layout_processor().process(
    graph,
    None,
  )

  inspect(
    node_get_double_property(graph, rectpacking_internal_target_width),
    content="120",
  )
}
