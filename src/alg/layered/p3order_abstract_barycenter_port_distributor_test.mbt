///|
fn abstract_port_test_side_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn abstract_port_test_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn abstract_port_test_cross_min_type_barycenter() -> CrossMinType {
  cross_min_type_constants()[0]
}

///|
fn abstract_port_test_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn abstract_port_test_port_handles(ports : Array[LPort]) -> Array[Int] {
  let handles = []
  for port in ports {
    handles.push(port.get_handle())
  }
  handles
}

///|
fn abstract_port_test_distribute_ports_in_complete_graph(
  graph : LGraph,
) -> Unit {
  let graph_data = new_graph_info_holder_from_graph(
    graph,
    abstract_port_test_cross_min_type_barycenter(),
    [],
  )
  let nodes = abstract_port_test_order(graph)
  for i in 0..<nodes.length() {
    ignore(
      graph_data
      .port_distributor()
      .distribute_ports_while_sweeping(nodes, i, true),
    )
  }
  for i in 0..<nodes.length() {
    let index = nodes.length() - 1 - i
    ignore(
      graph_data
      .port_distributor()
      .distribute_ports_while_sweeping(nodes, index, false),
    )
  }
}

///|
test "AbstractBarycenterPortDistributor distributePortsOnSide_GivenCrossOnWesternSide_ShouldRemoveCrossing" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_node = creator.add_node_to_layer(creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_node)

  let expected_port_order = creator.copy_ports_in_index_order(right_node, [1, 0])
  abstract_port_test_distribute_ports_in_complete_graph(graph)

  @core_debug.assert_eq(
    abstract_port_test_port_handles(right_node.get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}

///|
test "AbstractBarycenterPortDistributor distributePortsOfGraph_GivenCrossOnBothSides_ShouldRemoveCrossing" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let middle_node = creator.add_node_to_layer(creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(middle_node, right_nodes[1])
  creator.east_west_edge_from_to_nodes(middle_node, right_nodes[0])
  creator.east_west_edge_from_to_nodes(left_nodes[0], middle_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], middle_node)
  creator.set_up_ids()

  let expected_port_order = creator.copy_ports_in_index_order(middle_node, [
    1, 0, 3, 2,
  ])
  abstract_port_test_distribute_ports_in_complete_graph(graph)

  @core_debug.assert_eq(
    abstract_port_test_port_handles(middle_node.get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}

///|
test "AbstractBarycenterPortDistributor distributePortsOfGraph_GivenCrossOnEasternSide_ShouldRemoveCrossing" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_node, right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_node, right_nodes[0])

  let expected_port_order = creator.copy_ports_in_index_order(left_node, [1, 0])
  abstract_port_test_distribute_ports_in_complete_graph(graph)

  @core_debug.assert_eq(
    abstract_port_test_port_handles(left_node.get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}

///|
test "AbstractBarycenterPortDistributor distributePortsOfGraph_GivenInLayerEdgePortOrderCrossing_ShouldRemoveIt" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  ignore(creator.add_node_to_layer(creator.make_layer(graph)))
  let nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  creator.add_in_layer_edge_nodes(
    nodes[0],
    nodes[2],
    abstract_port_test_side_east(),
  )
  creator.add_in_layer_edge_nodes(
    nodes[1],
    nodes[2],
    abstract_port_test_side_east(),
  )

  let expected_port_order = creator.copy_ports_in_index_order(nodes[2], [1, 0])
  abstract_port_test_distribute_ports_in_complete_graph(graph)

  @core_debug.assert_eq(
    abstract_port_test_port_handles(nodes[2].get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}

///|
test "AbstractBarycenterPortDistributor distributePortsOfGraph_GivenNorthSouthPortOrderCrossing_ShouldSwitchPortOrder" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.add_north_south_edge(
    abstract_port_test_side_north(),
    left_nodes[2],
    left_nodes[1],
    right_nodes[1],
    false,
  )
  creator.add_north_south_edge(
    abstract_port_test_side_north(),
    left_nodes[2],
    left_nodes[0],
    right_nodes[0],
    false,
  )

  let expected_port_order = creator.copy_ports_in_index_order(left_nodes[2], [
    1, 0,
  ])
  abstract_port_test_distribute_ports_in_complete_graph(graph)

  @core_debug.assert_eq(
    abstract_port_test_port_handles(left_nodes[2].get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}

///|
test "AbstractBarycenterPortDistributor distributePortsWhileSweeping_givenSimpleCross_ShouldRemoveCrossing" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let right_node = creator.add_node_to_layer(creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_node, right_node)
  creator.east_west_edge_from_to_nodes(left_node, right_node)

  let expected_port_order = creator.copy_ports_in_index_order(right_node, [1, 0])
  creator.set_up_ids()
  let node_order = abstract_port_test_order(graph)
  let port_dist = new_layer_total_port_distributor(node_order.length())
  i_initializable_init([port_dist.as_initializable()], node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 1, true))

  @core_debug.assert_eq(
    abstract_port_test_port_handles(right_node.get_ports()),
    abstract_port_test_port_handles(expected_port_order),
  )
}
