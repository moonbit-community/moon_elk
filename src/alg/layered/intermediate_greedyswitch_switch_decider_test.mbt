///|
fn switch_decider_bb_node_type_normal() -> NodeType {
  node_type_values()[0]
}

///|
fn switch_decider_bb_node_type_north_south_port() -> NodeType {
  node_type_values()[3]
}

///|
fn switch_decider_bb_port_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn switch_decider_bb_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn switch_decider_bb_greedy_one_sided() -> GreedySwitchType {
  greedy_switch_type_values()[0]
}

///|
fn switch_decider_bb_greedy_two_sided() -> GreedySwitchType {
  greedy_switch_type_values()[1]
}

///|
fn switch_decider_bb_crossing_west() -> CrossingCountSide {
  crossing_count_side_values()[0]
}

///|
fn switch_decider_bb_crossing_east() -> CrossingCountSide {
  crossing_count_side_values()[1]
}

///|
fn switch_decider_bb_new_node(
  layer : Layer,
  id : Int,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn switch_decider_bb_new_port(
  node : LNode,
  side : @core.PortSide,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port.set_id(id)
  port
}

///|
fn switch_decider_bb_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
fn switch_decider_bb_port_count(node_order : Array[Array[LNode]]) -> Int {
  let mut count = 0
  for layer in node_order {
    for node in layer {
      count = count + node.get_ports().length()
    }
  }
  count
}

///|
fn switch_decider_bb_cross_types() -> Array[GreedySwitchType] {
  [switch_decider_bb_greedy_one_sided(), switch_decider_bb_greedy_two_sided()]
}

///|
fn switch_decider_bb_is_one_sided(switch_type : GreedySwitchType) -> Bool {
  match switch_type {
    GreedySwitchType::OneSided => true
    _ => false
  }
}

///|
fn switch_decider_bb_current_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn switch_decider_bb_new_decider_for_layer(
  graph : LGraph,
  switch_type : GreedySwitchType,
  free_layer_index : Int,
  side : CrossingCountSide,
) -> (SwitchDecider, Array[Array[LNode]]) {
  let node_order = switch_decider_bb_current_order(graph)
  let filler = new_crossing_matrix_filler(
    switch_type, node_order, free_layer_index, side,
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    free_layer_index,
    node_order,
    filler,
    Array::make(switch_decider_bb_port_count(node_order), 0),
    graph_data,
    switch_decider_bb_is_one_sided(switch_type),
  )
  (decider, node_order)
}

///|
fn switch_decider_bb_swap_nodes(
  node_order : Array[Array[LNode]],
  layer_index : Int,
  upper_node_index : Int,
  lower_node_index : Int,
) -> Unit {
  let layer = node_order[layer_index]
  let upper = layer[upper_node_index]
  layer[upper_node_index] = layer[lower_node_index]
  layer[lower_node_index] = upper
}

///|
fn switch_decider_bb_cross_graph() -> (Array[Array[LNode]], LNode, LNode) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_upper = switch_decider_bb_new_node(
    left_layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let left_lower = switch_decider_bb_new_node(
    left_layer,
    1,
    switch_decider_bb_node_type_normal(),
  )
  let right_upper = switch_decider_bb_new_node(
    right_layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let right_lower = switch_decider_bb_new_node(
    right_layer,
    1,
    switch_decider_bb_node_type_normal(),
  )

  let left_upper_port = switch_decider_bb_new_port(
    left_upper,
    switch_decider_bb_port_side_east(),
    0,
  )
  let left_lower_port = switch_decider_bb_new_port(
    left_lower,
    switch_decider_bb_port_side_east(),
    1,
  )
  let right_upper_port = switch_decider_bb_new_port(
    right_upper,
    switch_decider_bb_port_side_west(),
    2,
  )
  let right_lower_port = switch_decider_bb_new_port(
    right_lower,
    switch_decider_bb_port_side_west(),
    3,
  )

  switch_decider_bb_connect(left_upper_port, right_lower_port)
  switch_decider_bb_connect(left_lower_port, right_upper_port)

  (
    [[left_upper, left_lower], [right_upper, right_lower]],
    right_upper,
    right_lower,
  )
}

///|
fn switch_decider_bb_switch_and_recount_counter_bug_graph() -> LGraph {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(4, creator.make_layer(graph))

  let left_top_port = creator.add_port_on_side(
    left_nodes[0],
    switch_decider_bb_port_side_east(),
  )
  let left_lower_port = creator.add_port_on_side(
    left_nodes[1],
    switch_decider_bb_port_side_east(),
  )
  let right_top_port = creator.add_port_on_side(
    right_nodes[0],
    switch_decider_bb_port_side_west(),
  )

  creator.add_edge_between_ports(left_lower_port, right_top_port)
  creator.east_west_edge_from_to_port_node(left_lower_port, right_nodes[2])

  creator.add_edge_between_ports(left_top_port, right_top_port)
  creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_top_port, right_nodes[3])

  creator.set_up_ids()
  graph
}

///|
test "SwitchDecider cross formed graph is switchable from both sides" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_cross_formed_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(west_decider.does_switch_reduce_crossings(0, 1))

    let (east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_true(east_decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider one node graph has no beneficial switch" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_one_node_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_west(),
    )
    assert_false(west_decider.does_switch_reduce_crossings(0, 0))

    let (east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_false(east_decider.does_switch_reduce_crossings(0, 0))
  }
}

///|
test "SwitchDecider in-layer switchable graph reduces crossings" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_in_layer_edges_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(west_decider.does_switch_reduce_crossings(0, 1))

    let (east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_east(),
    )
    assert_true(east_decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider handles multiple edges between same nodes" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_multiple_edges_between_same_nodes_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(west_decider.does_switch_reduce_crossings(0, 1))

    let (east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_true(east_decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider handles self loops in crossed graph" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_cross_with_many_self_loops_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(west_decider.does_switch_reduce_crossings(0, 1))

    let (east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_true(east_decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider more complex graph matches expected switch decisions" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_more_complex_three_layer_graph()

    let (layer1_west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_false(layer1_west_decider.does_switch_reduce_crossings(0, 1))

    let (layer2_west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      2,
      switch_decider_bb_crossing_west(),
    )
    assert_true(layer2_west_decider.does_switch_reduce_crossings(0, 1))
    assert_false(layer2_west_decider.does_switch_reduce_crossings(1, 2))

    let (layer1_east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_east(),
    )
    assert_false(layer1_east_decider.does_switch_reduce_crossings(0, 1))

    let (layer0_east_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_false(layer0_east_decider.does_switch_reduce_crossings(0, 1))
    assert_true(layer0_east_decider.does_switch_reduce_crossings(1, 2))
  }
}

///|
test "SwitchDecider switch-only graph is true only for one-sided west counting" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_switch_only_one_sided()

    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_eq(
      decider.does_switch_reduce_crossings(0, 1),
      switch_decider_bb_is_one_sided(switch_type),
    )
  }
}

///|
test "SwitchDecider switch-only graph is true only for one-sided east counting" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_switch_only_east_one_sided()

    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_east(),
    )
    assert_eq(
      decider.does_switch_reduce_crossings(0, 1),
      switch_decider_bb_is_one_sided(switch_type),
    )
  }
}

///|
test "SwitchDecider constraints in second layer prevent switch" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_cross_formed_graph_with_constraints_in_second_layer()

    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_false(decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider north-south crossing is beneficial only for one-sided mode" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let graph = creator.get_three_layer_north_south_crossing_graph()
    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_eq(
      decider.does_switch_reduce_crossings(1, 2),
      switch_decider_bb_is_one_sided(switch_type),
    )
  }
}

///|
test "SwitchDecider in-layer layout-unit constraints prevent switch" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let graph = creator.get_graph_where_layout_unit_prevents_switch()
    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_west(),
    )
    assert_false(decider.does_switch_reduce_crossings(1, 2))
  }
}

///|
test "SwitchDecider switch-and-recount counter bug scenario stays consistent" {
  for switch_type in switch_decider_bb_cross_types() {
    let graph = switch_decider_bb_switch_and_recount_counter_bug_graph()
    let (decider, node_order) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(decider.does_switch_reduce_crossings(0, 1))
    assert_false(decider.does_switch_reduce_crossings(1, 2))
    assert_true(decider.does_switch_reduce_crossings(2, 3))

    decider.notify_of_switch(node_order[1][0], node_order[1][1])
    switch_decider_bb_swap_nodes(node_order, 1, 0, 1)
    assert_false(decider.does_switch_reduce_crossings(0, 1))
    assert_false(decider.does_switch_reduce_crossings(1, 2))
    assert_true(decider.does_switch_reduce_crossings(2, 3))

    decider.notify_of_switch(node_order[1][2], node_order[1][3])
    switch_decider_bb_swap_nodes(node_order, 1, 2, 3)
    assert_false(decider.does_switch_reduce_crossings(0, 1))
    assert_true(decider.does_switch_reduce_crossings(1, 2))
    assert_false(decider.does_switch_reduce_crossings(2, 3))

    decider.notify_of_switch(node_order[1][1], node_order[1][2])
    switch_decider_bb_swap_nodes(node_order, 1, 1, 2)
    assert_false(decider.does_switch_reduce_crossings(0, 1))
    assert_false(decider.does_switch_reduce_crossings(1, 2))
    assert_false(decider.does_switch_reduce_crossings(2, 3))
  }
}

///|
test "SwitchDecider switched-problem graph has no beneficial adjacent switch" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_switched_problem_graph()
    let (decider, node_order) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    let middle_layer_count = node_order[1].length()
    for i in 0..<(middle_layer_count - 1) {
      assert_false(decider.does_switch_reduce_crossings(i, i + 1))
    }
  }
}

///|
test "SwitchDecider handles long-edge dummy north-south crossings" {
  for switch_type in switch_decider_bb_cross_types() {
    let northern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let northern_graph = northern_creator.get_northern_north_south_dummy_edge_crossing_graph()
    let (northern_decider, _) = switch_decider_bb_new_decider_for_layer(
      northern_graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(northern_decider.does_switch_reduce_crossings(1, 2))
    if switch_decider_bb_is_one_sided(switch_type) {
      assert_true(northern_decider.does_switch_reduce_crossings(0, 1))
    }

    let southern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let southern_graph = southern_creator.get_southern_north_south_dummy_edge_crossing_graph()
    let (southern_decider, _) = switch_decider_bb_new_decider_for_layer(
      southern_graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(southern_decider.does_switch_reduce_crossings(0, 1))
    if switch_decider_bb_is_one_sided(switch_type) {
      assert_true(southern_decider.does_switch_reduce_crossings(1, 2))
    }
  }
}

///|
test "SwitchDecider layout-unit constraints block northern-port swap" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let graph = creator.get_graph_layout_unit_prevents_switch_with_node_with_node_with_northern_edges()
    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_false(decider.does_switch_reduce_crossings(1, 2))
  }
}

///|
test "SwitchDecider layout-unit constraints block southern-port swap" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let graph = creator.get_graph_layout_unit_prevents_switch_with_node_with_node_with_southern_edges()
    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_false(decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider layout-unit constraints allow swap with long-edge dummy" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_north_south_edge_test_graph_creator()
    let graph = creator.get_graph_layout_unit_does_not_prevent_switch_with_long_edge_dummy()
    let (decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_east(),
    )
    assert_true(decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider switching external-port dummies updates parent port crossings" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_graph()
    let left_node = creator.add_node_to_layer(creator.make_layer(graph))
    let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
    let left_ports = creator.add_ports_on_side(
      2,
      left_node,
      switch_decider_bb_port_side_east(),
    )
    let nested_graph = creator.nested_graph(left_node)
    let nested_layer = creator.make_layer(nested_graph)
    let dummies = creator.add_external_port_dummies_to_layer(
      nested_layer, left_ports,
    )
    creator.east_west_edge_from_to_port_node(left_ports[0], right_nodes[1])
    creator.east_west_edge_from_to_port_node(left_ports[1], right_nodes[0])
    creator.set_up_ids()

    let parent_node_order = switch_decider_bb_current_order(graph)
    let nested_node_order = switch_decider_bb_current_order(nested_graph)
    let filler = new_crossing_matrix_filler(
      switch_type,
      nested_node_order,
      0,
      switch_decider_bb_crossing_east(),
    )
    let parent_graph_data = new_graph_info_holder(
      parent_node_order,
      l_graph=Some(graph),
    )
    let nested_graph_data = new_graph_info_holder(
      nested_node_order,
      parent=Some(left_node),
      parent_graph_data=Some(parent_graph_data),
      l_graph=Some(nested_graph),
    )
    let decider = new_switch_decider(
      0,
      nested_node_order,
      filler,
      Array::make(switch_decider_bb_port_count(nested_node_order), 0),
      nested_graph_data,
      false,
    )

    if !switch_decider_bb_is_one_sided(switch_type) {
      assert_true(decider.does_switch_reduce_crossings(0, 1))
      decider.notify_of_switch(dummies[0], dummies[1])
      assert_false(decider.does_switch_reduce_crossings(0, 1))
    }
  }
}

///|
test "SwitchDecider notify_of_switch updates crossing decision in crossed graph" {
  for switch_type in switch_decider_bb_cross_types() {
    let creator = new_greedy_switch_test_graph_creator()
    let graph = creator.get_cross_formed_graph()

    let (west_decider, _) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      1,
      switch_decider_bb_crossing_west(),
    )
    assert_true(west_decider.does_switch_reduce_crossings(0, 1))

    let (east_decider, east_order) = switch_decider_bb_new_decider_for_layer(
      graph,
      switch_type,
      0,
      switch_decider_bb_crossing_east(),
    )
    assert_true(east_decider.does_switch_reduce_crossings(0, 1))

    east_decider.notify_of_switch(east_order[0][0], east_order[0][1])
    switch_decider_bb_swap_nodes(east_order, 0, 0, 1)
    assert_false(east_decider.does_switch_reduce_crossings(0, 1))
  }
}

///|
test "SwitchDecider reports switch reduces crossings on crossed layer" {
  let (node_order, right_upper, right_lower) = switch_decider_bb_cross_graph()
  ignore((right_upper, right_lower))
  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    1,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    1,
    node_order,
    filler,
    Array::make(switch_decider_bb_port_count(node_order), 0),
    graph_data,
    true,
  )

  assert_true(decider.does_switch_reduce_crossings(0, 1))
}

///|
test "SwitchDecider successor constraint prevents switching" {
  let (node_order, right_upper, right_lower) = switch_decider_bb_cross_graph()
  right_upper.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
    [right_lower],
  )

  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    1,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    1,
    node_order,
    filler,
    Array::make(switch_decider_bb_port_count(node_order), 0),
    graph_data,
    true,
  )

  assert_false(decider.does_switch_reduce_crossings(0, 1))
}

///|
test "SwitchDecider blocks normal and north-south dummy swaps" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = switch_decider_bb_new_node(
    layer,
    0,
    switch_decider_bb_node_type_normal(),
  )
  let ns_dummy = switch_decider_bb_new_node(
    layer,
    1,
    switch_decider_bb_node_type_north_south_port(),
  )

  let node_order = [[normal, ns_dummy]]
  let filler = new_crossing_matrix_filler(
    switch_decider_bb_greedy_one_sided(),
    node_order,
    0,
    switch_decider_bb_crossing_west(),
  )
  let graph_data = new_graph_info_holder(node_order)
  let decider = new_switch_decider(
    0,
    node_order,
    filler,
    Array::make(0, 0),
    graph_data,
    true,
  )

  assert_false(decider.does_switch_reduce_crossings(0, 1))
}
