///|
fn greedy_port_test_port_handles(ports : Array[LPort]) -> Array[Int] {
  let handles = []
  for port in ports {
    handles.push(port.get_handle())
  }
  handles
}

///|
fn greedy_port_test_set_up_distributor(
  node_order : Array[Array[LNode]],
) -> GreedyPortDistributor {
  let port_dist = new_greedy_port_distributor()
  i_initializable_init([port_dist.as_initializable()], node_order)
  port_dist
}

///|
fn greedy_port_test_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
test "GreedyPortDistributor distribute_ports_given_cross_on_western_side_remove_crossing" {
  let creator = new_test_graph_creator()
  let left_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  let right_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_node)

  let expected_port_order = creator.copy_ports_in_index_order(right_node, [1, 0])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  let improved = port_dist.distribute_ports_while_sweeping(node_order, 1, true)

  assert_true(improved)
  @core_debug.assert_eq(
    greedy_port_test_port_handles(right_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor distribute_ports_given_no_ports_on_right_side_nothing_happens" {
  let creator = new_test_graph_creator()
  let left_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  let middle_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  ignore(creator.add_nodes_to_layer(2, creator.make_layer(creator.get_graph())))
  creator.east_west_edge_from_to_nodes(left_nodes[0], middle_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], middle_node)

  let expected_port_order = creator.copy_ports_in_index_order(middle_node, [
    0, 1,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 1, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(middle_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor distribute_ports_given_multiple_crossings_on_western_side_remove_crossing" {
  let creator = new_test_graph_creator()
  let left_nodes = creator.add_nodes_to_layer(
    3,
    creator.make_layer(creator.get_graph()),
  )
  let right_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_node)
  creator.east_west_edge_from_to_nodes(left_nodes[2], right_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_node)

  let expected_port_order = creator.copy_ports_in_index_order(right_node, [
    1, 2, 0,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 1, true))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(right_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor distribute_ports_given_crossings_on_eastern_side_remove_them" {
  let creator = new_test_graph_creator()
  let left_nodes = creator.add_nodes_to_layer(
    1,
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])

  let expected_port_order = creator.copy_ports_in_index_order(left_nodes[0], [
    1, 0,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_nodes[0].get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor distribute_ports_fixed_port_order_no_change" {
  let creator = new_test_graph_creator()
  let left_nodes = creator.add_nodes_to_layer(
    1,
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
  creator.set_fixed_order_constraint(left_nodes[0])

  let expected_port_order = creator.copy_ports_in_index_order(left_nodes[0], [
    0, 1,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_nodes[0].get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor given_double_cross_between_compound_and_non_compound_nodes_switches_ports" {
  let creator = new_test_graph_creator()
  let left_outer_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  let left_outer_ports = creator.add_ports_on_side(
    2,
    left_outer_node,
    greedy_port_test_east(),
  )
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_outer_ports[1], right_nodes[0])

  let left_inner_graph = creator.nested_graph(left_outer_node)
  let left_inner_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(left_inner_graph),
  )
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(left_inner_graph),
    left_outer_ports,
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[0],
    left_inner_dummy_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[1],
    left_inner_dummy_nodes[1],
  )
  creator.set_up_ids()

  let expected_port_order = creator.copy_ports_in_index_order(left_outer_node, [
    1, 0,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_outer_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor given_single_cross_between_compound_and_non_compound_nodes_does_not_switch_ports" {
  let creator = new_test_graph_creator()
  let left_outer_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(creator.get_graph()),
  )
  let left_outer_ports = creator.add_ports_on_side(
    2,
    left_outer_node,
    greedy_port_test_east(),
  )
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_outer_ports[1], right_nodes[0])

  let left_inner_graph = creator.nested_graph(left_outer_node)
  let left_inner_nodes = creator.add_nodes_to_layer(
    2,
    creator.make_layer(left_inner_graph),
  )
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(left_inner_graph),
    left_outer_ports,
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[0],
    left_inner_dummy_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[1],
    left_inner_dummy_nodes[1],
  )

  let expected_port_order = creator.copy_ports_in_index_order(left_outer_node, [
    0, 1,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_outer_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor given_more_hierarchical_nodes_does_not_switch_ports" {
  let creator = new_test_graph_creator()
  let left_outer_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    3,
    creator.make_layer(creator.get_graph()),
  )
  let left_outer_ports = creator.add_ports_on_side(
    3,
    left_outer_node,
    greedy_port_test_east(),
  )
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_outer_ports[1], right_nodes[0])
  creator.east_west_edge_from_to_port_node(left_outer_ports[2], right_nodes[2])

  let left_inner_graph = creator.nested_graph(left_outer_node)
  let left_inner_nodes = creator.add_nodes_to_layer(
    3,
    creator.make_layer(left_inner_graph),
  )
  let left_inner_dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(left_inner_graph),
    left_outer_ports,
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[0],
    left_inner_dummy_nodes[0],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[1],
    left_inner_dummy_nodes[1],
  )
  creator.east_west_edge_from_to_nodes(
    left_inner_nodes[2],
    left_inner_dummy_nodes[2],
  )

  let expected_port_order = creator.copy_ports_in_index_order(left_outer_node, [
    0, 1, 2,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_outer_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor given_more_hierarchical_nodes2_does_not_switch_ports" {
  let creator = new_test_graph_creator()
  let left_outer_node = creator.add_node_to_layer(
    creator.make_layer(creator.get_graph()),
  )
  let right_nodes = creator.add_nodes_to_layer(
    3,
    creator.make_layer(creator.get_graph()),
  )
  let left_outer_ports = creator.add_ports_on_side(
    3,
    left_outer_node,
    greedy_port_test_east(),
  )
  creator.east_west_edge_from_to_port_node(left_outer_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_outer_ports[1], right_nodes[0])
  creator.east_west_edge_from_to_port_node(left_outer_ports[2], right_nodes[2])

  let left_inner_graph = creator.nested_graph(left_outer_node)
  let left_inner_node = creator.add_node_to_layer(
    creator.make_layer(left_inner_graph),
  )
  let right_inner_nodes = creator.add_nodes_to_layer(
    3,
    creator.make_layer(left_inner_graph),
  )
  let dummy_nodes = creator.add_external_port_dummies_to_layer(
    creator.make_layer(left_inner_graph),
    left_outer_ports,
  )
  creator.east_west_edge_from_to_nodes(left_inner_node, right_inner_nodes[2])
  creator.east_west_edge_from_to_nodes(right_inner_nodes[0], dummy_nodes[0])
  creator.east_west_edge_from_to_nodes(right_inner_nodes[1], dummy_nodes[1])
  creator.east_west_edge_from_to_nodes(right_inner_nodes[2], dummy_nodes[2])

  let expected_port_order = creator.copy_ports_in_index_order(left_outer_node, [
    0, 1, 2,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_outer_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor distribute_ports_while_sweeping_given_two_hierarchical_nodes_in_one_layer" {
  let creator = new_test_graph_creator()
  let left_layer = creator.make_layer(creator.get_graph())
  let right_layer = creator.make_layer(creator.get_graph())

  for _ in 0..<2 {
    let left_nodes = creator.add_nodes_to_layer(1, left_layer)
    let right_nodes = creator.add_nodes_to_layer(2, right_layer)
    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
    creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
  }

  let left_outer_node = left_layer.get_nodes()[0]
  let expected_port_order = creator.copy_ports_in_index_order(left_outer_node, [
    1, 0,
  ])
  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  ignore(port_dist.distribute_ports_while_sweeping(node_order, 0, false))

  @core_debug.assert_eq(
    greedy_port_test_port_handles(left_outer_node.get_ports()),
    greedy_port_test_port_handles(expected_port_order),
  )
}

///|
test "GreedyPortDistributor no_change" {
  let creator = new_test_graph_creator()
  let left_layer = creator.make_layer(creator.get_graph())
  let right_layer = creator.make_layer(creator.get_graph())
  let left_nodes = creator.add_nodes_to_layer(1, left_layer)
  let right_nodes = creator.add_nodes_to_layer(2, right_layer)
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])

  let node_order = creator.get_current_order(creator.get_graph())
  let port_dist = greedy_port_test_set_up_distributor(node_order)
  let improved = port_dist.distribute_ports_while_sweeping(node_order, 0, false)

  assert_false(improved)
}
