///|
fn box_layout_provider_test_close(
  actual : Double,
  expected : Double,
  tolerance : Double,
) -> Bool {
  (actual - expected).abs() <= tolerance
}

///|
test "box layout provider simple mode honors priority order" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_double_property(graph, spacing_node_node, 10.0)
  node_set_double_property(graph, aspect_ratio, 10.0)
  node_set_string_property(graph, padding, "[left=5, top=5, right=5, bottom=5]")

  let first = create_node(Some(graph))
  node_set_dimensions(first, 10.0, 10.0)
  node_set_double_property(first, priority, 2.0)

  let second = create_node(Some(graph))
  node_set_dimensions(second, 10.0, 10.0)
  node_set_double_property(second, priority, 1.0)

  let third = create_node(Some(graph))
  node_set_dimensions(third, 10.0, 10.0)
  node_set_double_property(third, priority, 0.0)

  let provider = new_box_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(
    box_layout_provider_test_close(node_x(first), 5.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_x(second), 25.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_x(third), 45.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_y(first), 5.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_width(graph), 60.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_height(graph), 20.0, 0.001),
    content="true",
  )
}

///|
test "box layout provider expand nodes fills row and honors minimum size" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_double_property(graph, spacing_node_node, 10.0)
  node_set_double_property(graph, aspect_ratio, 2.0)
  node_set_bool_property(graph, expand_nodes, true)
  node_set_string_property(graph, padding, "[left=5, top=5, right=5, bottom=5]")
  node_set_string_set_property(graph, node_size_constraints, ["MINIMUM_SIZE"])
  node_set_string_property(graph, node_size_minimum, "(100.0, 40.0)")

  let child = create_node(Some(graph))
  node_set_dimensions(child, 20.0, 10.0)

  let provider = new_box_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(
    box_layout_provider_test_close(node_width(graph), 100.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_height(graph), 40.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_x(child), 5.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_y(child), 5.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_width(child), 90.0, 0.001),
    content="true",
  )
  inspect(
    box_layout_provider_test_close(node_height(child), 30.0, 0.001),
    content="true",
  )
}

///|
test "box layout provider grouped mode places all nodes" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_string_property(graph, box_packing_mode, "GROUP_DEC")
  node_set_double_property(graph, spacing_node_node, 8.0)
  node_set_double_property(graph, aspect_ratio, 1.5)
  node_set_string_property(graph, padding, "[left=6, top=4, right=6, bottom=4]")

  let dims = [
    new_kvector_xy(30.0, 20.0),
    new_kvector_xy(12.0, 10.0),
    new_kvector_xy(14.0, 9.0),
    new_kvector_xy(18.0, 16.0),
    new_kvector_xy(10.0, 8.0),
  ]
  for dim in dims {
    let child = create_node(Some(graph))
    node_set_dimensions(child, dim.x, dim.y)
  }

  let provider = new_box_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(node_width(graph) > 0.0, content="true")
  inspect(node_height(graph) > 0.0, content="true")
  inspect(node_children(graph).length(), content="5")

  for child in node_children(graph) {
    inspect(node_x(child) >= 0.0, content="true")
    inspect(node_y(child) >= 0.0, content="true")
  }
}
