///|
test "GraphTestUtils createSimpleGraph builds two nodes with one edge" {
  reset_graph_model_for_test()
  let graph = graph_test_utils_create_simple_graph()
  let children = node_children(graph)
  assert_eq(children.length(), 2)
  assert_eq(node_ports(children[0]).length(), 1)
  assert_eq(node_ports(children[1]).length(), 1)
  assert_eq(node_contained_edges(graph).length(), 1)
}

///|
test "GraphTestUtils allNodes includes or excludes graph as requested" {
  reset_graph_model_for_test()
  let graph = graph_test_utils_create_hierarchical_graph()
  let with_graph = graph_test_utils_all_nodes(graph, true)
  let without_graph = graph_test_utils_all_nodes(graph, false)
  assert_true(with_graph.length() == without_graph.length() + 1)
  assert_eq(with_graph[0], graph)
}

///|
test "GraphTestUtils haveOverlaps detects rectangle intersections" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first = create_node(Some(root))
  node_set_location(first, 0.0, 0.0)
  node_set_dimensions(first, 20.0, 20.0)

  let second = create_node(Some(root))
  node_set_location(second, 10.0, 10.0)
  node_set_dimensions(second, 20.0, 20.0)

  let third = create_node(Some(root))
  node_set_location(third, 100.0, 100.0)
  node_set_dimensions(third, 20.0, 20.0)

  assert_true(
    graph_test_utils_have_overlaps([
      graph_test_shape_node(first),
      graph_test_shape_node(second),
    ]),
  )
  assert_false(
    graph_test_utils_have_overlaps([
      graph_test_shape_node(first),
      graph_test_shape_node(third),
    ]),
  )
}
