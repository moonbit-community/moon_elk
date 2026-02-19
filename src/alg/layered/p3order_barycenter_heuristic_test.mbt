///|
fn barycenter_test_node_ids(nodes : Array[LNode]) -> Array[Int] {
  let ids = []
  for node in nodes {
    ids.push(node.get_id())
  }
  ids
}

///|
fn barycenter_test_minimize_crossings(
  cross_min : BarycenterHeuristic,
  nodes : Array[LNode],
  pre_ordered : Bool,
  randomized : Bool,
  forward : Bool,
) -> Unit {
  cross_min.minimize_crossings_layer(nodes, pre_ordered, randomized, forward)
}

///|
fn barycenter_test_port_type_input() -> PortType {
  port_type_values()[1]
}

///|
fn barycenter_test_port_type_output() -> PortType {
  port_type_values()[2]
}

///|
fn barycenter_test_side_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn barycenter_test_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn barycenter_test_new_port_dist_and_resolver(
  nodes : Array[Array[LNode]],
) -> (NodeRelativePortDistributor, ForsterConstraintResolver) {
  let port_dist = new_node_relative_port_distributor(nodes.length())
  let constraint_resolver = new_forster_constraint_resolver(nodes)
  (port_dist, constraint_resolver)
}

///|
test "BarycenterHeuristic removes crossing in simple cross" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )

  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )

  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_output())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )
  let expected_order = creator.switch_order_in_array(0, 1, nodes[1])

  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)

  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order),
  )
}

///|
test "BarycenterHeuristic mock randomize first layer" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_output())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )

  let expected_order = nodes[0].copy()
  let expected_switched_order = creator.switch_order_in_array(0, 1, nodes[0])

  barycenter_test_minimize_crossings(cross_min, nodes[0], false, true, true)
  assert_eq(
    barycenter_test_node_ids(nodes[0]),
    barycenter_test_node_ids(expected_order),
  )

  random.set_change_by(-0.01)
  barycenter_test_minimize_crossings(cross_min, nodes[0], false, true, true)
  assert_eq(
    barycenter_test_node_ids(nodes[0]),
    barycenter_test_node_ids(expected_switched_order),
  )
}

///|
test "BarycenterHeuristic fills unknown barycenters" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  creator.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let expected_switched_order = creator.switch_order_in_array(0, 1, nodes[2])
  let expected_order_second_layer = nodes[1].copy()

  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_output())
  barycenter_test_minimize_crossings(cross_min, nodes[0], false, true, true)

  port_dist.calculate_port_ranks(nodes[1], barycenter_test_port_type_output())
  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)
  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order_second_layer),
  )

  barycenter_test_minimize_crossings(cross_min, nodes[2], false, false, true)
  assert_eq(
    barycenter_test_node_ids(nodes[2]),
    barycenter_test_node_ids(expected_switched_order),
  )
}

///|
test "BarycenterHeuristic fixed port order removes crossing independent of random" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)
  let left_node = creator.add_node_to_layer(left_layer)
  let right_top_node = creator.add_node_to_layer(right_layer)
  let right_bottom_node = creator.add_node_to_layer(right_layer)

  creator.east_west_edge_from_to_nodes(left_node, right_bottom_node)
  creator.east_west_edge_from_to_nodes(left_node, right_top_node)
  creator.set_fixed_order_constraint(left_node)
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_output())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )

  let expected_order = creator.switch_order_in_array(0, 1, nodes[1])
  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)
  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order),
  )

  random.set_change_by(-0.1)
  random.set_next_boolean(false)
  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)
  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order),
  )
}

///|
test "BarycenterHeuristic fixed port order removes crossing backwards" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_node = creator.add_node_to_layer(creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_node)
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_node)
  creator.set_fixed_order_constraint(right_node)
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[1], barycenter_test_port_type_input())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )

  let expected_order = creator.switch_order_in_array(0, 1, nodes[0])
  barycenter_test_minimize_crossings(cross_min, nodes[0], false, false, false)

  assert_eq(
    barycenter_test_node_ids(nodes[0]),
    barycenter_test_node_ids(expected_order),
  )
}

///|
test "BarycenterHeuristic handles in-layer edges" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  creator.set_fixed_order_constraint(right_nodes[0])
  creator.east_west_edge_from_to_nodes(left_node, right_nodes[0])
  creator.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[2],
    barycenter_test_side_west(),
  )
  creator.east_west_edge_from_to_nodes(left_node, right_nodes[1])
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_input())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )

  let expected_order = creator.get_list_copy_in_index_order(nodes[1], [2, 0, 1])
  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)

  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order),
  )
}

///|
test "BarycenterHeuristic handles north south edges" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(1, creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(4, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[2])
  creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[2])
  creator.set_as_long_edge_dummy(middle_nodes[2])
  creator.add_north_south_edge(
    barycenter_test_side_north(),
    middle_nodes[3],
    middle_nodes[0],
    right_nodes[0],
    false,
  )
  creator.add_north_south_edge(
    barycenter_test_side_north(),
    middle_nodes[3],
    middle_nodes[1],
    right_nodes[1],
    false,
  )
  creator.set_up_ids()

  let nodes = creator.get_current_order(graph)
  let (port_dist, constraint_resolver) = barycenter_test_new_port_dist_and_resolver(
    nodes,
  )
  i_initializable_init(
    [port_dist.as_initializable(), constraint_resolver.as_initializable()],
    nodes,
  )
  port_dist.calculate_port_ranks(nodes[0], barycenter_test_port_type_input())
  let cross_min = new_barycenter_heuristic(
    constraint_resolver,
    random,
    port_dist.as_abstract_barycenter_port_distributor(),
    nodes,
  )
  i_initializable_init(
    [cross_min.as_i_crossing_minimization_heuristic().as_initializable()],
    nodes,
  )

  let expected_order = creator.get_list_copy_in_index_order(nodes[1], [
    1, 0, 3, 2,
  ])
  random.set_change_by(-0.01)
  barycenter_test_minimize_crossings(cross_min, nodes[1], false, false, true)

  assert_eq(
    barycenter_test_node_ids(nodes[1]),
    barycenter_test_node_ids(expected_order),
  )
}
