///|
fn layer_sweep_test_cross_types() -> Array[CrossMinType] {
  let values = cross_min_type_constants()
  [values[0], values[1]]
}

///|
fn layer_sweep_test_node_handles(nodes : Array[LNode]) -> Array[Int] {
  let handles = []
  for node in nodes {
    handles.push(node.get_handle())
  }
  handles
}

///|
fn layer_sweep_test_run(
  creator : TestGraphCreator,
  cross_min_type : CrossMinType,
) -> Unit {
  let cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
  cross_min.process(
    creator.get_graph(),
    progress_monitor=Some(new_basic_progress_monitor()),
  )
}

///|
test "LayerSweep handles empty and one-node graphs" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let empty_creator = new_test_graph_creator()
    let empty_graph = empty_creator.get_empty_graph()
    let empty_cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    empty_cross_min.process(
      empty_graph,
      progress_monitor=Some(new_basic_progress_monitor()),
    )

    let single_creator = new_test_graph_creator()
    let one_node_graph = single_creator.get_one_node_graph()
    let single_cross_min = new_layer_sweep_crossing_minimizer(cross_min_type)
    single_cross_min.process(
      one_node_graph,
      progress_monitor=Some(new_basic_progress_monitor()),
    )
  }
}

///|
test "LayerSweep removes simple crossing in two-layer graph" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let graph = creator.get_cross_formed_graph()
    let expected_right_order = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      graph.get_layers()[1],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(graph.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_right_order),
    )
  }
}

///|
test "LayerSweep removes crossing inside single hierarchical node" {
  for cross_min_type in layer_sweep_test_cross_types() {
    let creator = new_test_graph_creator()
    let node = creator.add_node_to_layer(
      creator.make_layer(creator.get_graph()),
    )
    let inner_graph = creator.nested_graph(node)
    let left_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    let right_nodes = creator.add_nodes_to_layer(
      2,
      creator.make_layer(inner_graph),
    )
    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])

    let expected_right_order = creator.switch_order_of_nodes_in_layer(
      0,
      1,
      inner_graph.get_layers()[1],
    )

    layer_sweep_test_run(creator, cross_min_type)

    assert_eq(
      layer_sweep_test_node_handles(inner_graph.get_layers()[1].get_nodes()),
      layer_sweep_test_node_handles(expected_right_order),
    )
  }
}
