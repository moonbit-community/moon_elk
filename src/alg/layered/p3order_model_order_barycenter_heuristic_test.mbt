///|
fn model_order_barycenter_test_node_ids(nodes : Array[LNode]) -> Array[Int] {
  let ids = []
  for node in nodes {
    ids.push(node.get_id())
  }
  ids
}

///|
fn model_order_barycenter_test_build_heuristic(
  node_order : Array[Array[LNode]],
  random : MockRandom,
) -> (ModelOrderBarycenterHeuristic, NodeRelativePortDistributor) {
  let port_distributor = new_node_relative_port_distributor(node_order.length())
  let constraint_resolver = new_forster_constraint_resolver(node_order)
  i_initializable_init(
    [
      port_distributor.as_initializable(),
      constraint_resolver.as_initializable(),
    ],
    node_order,
  )
  port_distributor.calculate_port_ranks(node_order[0], port_type_values()[2])
  let heuristic = new_model_order_barycenter_heuristic(
    constraint_resolver,
    random,
    port_distributor.as_abstract_barycenter_port_distributor(),
    node_order,
  )
  i_initializable_init(
    [heuristic.as_i_crossing_minimization_heuristic().as_initializable()],
    node_order,
  )
  (heuristic, port_distributor)
}

///|
fn model_order_barycenter_test_cross_graph(
  creator : TestGraphCreator,
) -> Array[Array[LNode]] {
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  creator.set_up_ids()
  creator.get_current_order(graph)
}

///|
test "ModelOrderBarycenterHeuristic preserves model order when forced" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()
  let node_order = model_order_barycenter_test_cross_graph(creator)
  let free_layer = node_order[1]

  free_layer[0].set_property_int(internal_properties_model_order, 0)
  free_layer[1].set_property_int(internal_properties_model_order, 1)
  free_layer[0].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    0,
  )
  free_layer[1].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    0,
  )
  graph.set_property_int(internal_properties_max_model_order_nodes, 16)
  graph.set_property_bool(
    layered_options_crossing_minimization_force_node_model_order, true,
  )

  let (heuristic, _) = model_order_barycenter_test_build_heuristic(
    node_order, random,
  )
  let expected = free_layer.copy()
  heuristic.minimize_crossings_layer(free_layer, false, false, true)

  assert_eq(
    model_order_barycenter_test_node_ids(free_layer),
    model_order_barycenter_test_node_ids(expected),
  )
}

///|
test "ModelOrderBarycenterHeuristic keeps model order across groups when forced" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()
  let node_order = model_order_barycenter_test_cross_graph(creator)
  let free_layer = node_order[1]

  free_layer[0].set_property_int(internal_properties_model_order, 0)
  free_layer[1].set_property_int(internal_properties_model_order, 1)
  free_layer[0].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    1,
  )
  free_layer[1].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    2,
  )
  graph.set_property_int(internal_properties_max_model_order_nodes, 16)
  graph.set_property_bool(
    layered_options_crossing_minimization_force_node_model_order, true,
  )
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    "ONLY_WITHIN_GROUP",
  )

  let (heuristic, _) = model_order_barycenter_test_build_heuristic(
    node_order, random,
  )
  let expected = free_layer.copy()
  heuristic.minimize_crossings_layer(free_layer, false, false, true)

  assert_eq(
    model_order_barycenter_test_node_ids(free_layer),
    model_order_barycenter_test_node_ids(expected),
  )
}

///|
test "ModelOrderBarycenterHeuristic ignores separate-layer constraint when forced" {
  let creator = new_test_graph_creator()
  let random = new_mock_random()
  let graph = creator.get_graph()
  let node_order = model_order_barycenter_test_cross_graph(creator)
  let free_layer = node_order[1]

  free_layer[0].set_property_int(internal_properties_model_order, 1)
  free_layer[1].set_property_int(internal_properties_model_order, 0)
  free_layer[0].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    0,
  )
  free_layer[1].set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    0,
  )
  free_layer[0].set_property_string(
    layered_options_layering_layer_constraint, "FIRST_SEPARATE",
  )

  graph.set_property_int(internal_properties_max_model_order_nodes, 16)
  graph.set_property_bool(
    layered_options_crossing_minimization_force_node_model_order, true,
  )

  let (heuristic, _) = model_order_barycenter_test_build_heuristic(
    node_order, random,
  )
  let expected = creator.switch_order_in_array(0, 1, free_layer)
  heuristic.minimize_crossings_layer(free_layer, false, false, true)

  assert_eq(
    model_order_barycenter_test_node_ids(free_layer),
    model_order_barycenter_test_node_ids(expected),
  )
}
