///|
fn crossings_bb_set_up_ids(graph : LGraph) -> Unit {
  let mut layer_id = 0
  let mut port_id = 0
  for layer in graph.get_layers() {
    layer.set_id(layer_id)
    layer_id = layer_id + 1

    let mut node_id = 0
    for node in layer.get_nodes() {
      node.set_id(node_id)
      node_id = node_id + 1

      for port in node.get_ports() {
        port.set_id(port_id)
        port_id = port_id + 1
      }
    }
  }
}

///|
fn crossings_bb_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn crossings_bb_port_side_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn crossings_bb_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn crossings_bb_cross_min_type_barycenter() -> CrossMinType {
  cross_min_type_constants()[0]
}

///|
fn crossings_bb_pair_value(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => 0
  }
}

///|
fn crossings_bb_num_ports(current_order : Array[Array[LNode]]) -> Int {
  let mut num_ports = 0
  for layer in current_order {
    for node in layer {
      num_ports = num_ports + node.get_ports().length()
    }
  }
  num_ports
}

///|
fn crossings_bb_counter_for(graph : LGraph) -> CrossingsCounter {
  let order = crossings_bb_order(graph)
  new_crossings_counter(Array::make(crossings_bb_num_ports(order), 0))
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_fixedPortOrderCrossingOnTwoNodes" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left = creator.add_node_to_layer(creator.make_layer(graph))
  let right = creator.add_node_to_layer(creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left, right)
  creator.east_west_edge_from_to_nodes(left, right)

  crossings_bb_set_up_ids(graph)
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 1)
}

///|
test "CrossingsCounter longInLayerCrossings" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let nodes = creator.add_nodes_to_layer(5, creator.make_layer(graph))
  creator.add_in_layer_edge_nodes(
    nodes[0],
    nodes[1],
    crossings_bb_port_side_east(),
  )
  creator.add_in_layer_edge_nodes(
    nodes[1],
    nodes[3],
    crossings_bb_port_side_east(),
  )
  creator.add_in_layer_edge_nodes(
    nodes[2],
    nodes[4],
    crossings_bb_port_side_east(),
  )

  crossings_bb_set_up_ids(graph)
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(
    counter.count_in_layer_crossings_on_side(
      order[0],
      crossings_bb_port_side_east(),
    ),
    1,
  )
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_crossFormed" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 1)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_crossFormedMultipleEdgesBetweenSameNodes" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  let top_left_top_port = creator.add_port_on_side(
    top_left,
    crossings_bb_port_side_east(),
  )
  let top_left_bottom_port = creator.add_port_on_side(
    top_left,
    crossings_bb_port_side_east(),
  )
  let bottom_right_bottom_port = creator.add_port_on_side(
    bottom_right,
    crossings_bb_port_side_west(),
  )
  let bottom_right_top_port = creator.add_port_on_side(
    bottom_right,
    crossings_bb_port_side_west(),
  )
  creator.add_edge_between_ports(top_left_top_port, bottom_right_top_port)
  creator.add_edge_between_ports(top_left_bottom_port, bottom_right_bottom_port)

  let bottom_left_top_port = creator.add_port_on_side(
    bottom_left,
    crossings_bb_port_side_east(),
  )
  let bottom_left_bottom_port = creator.add_port_on_side(
    bottom_left,
    crossings_bb_port_side_east(),
  )
  let top_right_bottom_port = creator.add_port_on_side(
    top_right,
    crossings_bb_port_side_west(),
  )
  let top_right_top_port = creator.add_port_on_side(
    top_right,
    crossings_bb_port_side_west(),
  )
  creator.add_edge_between_ports(bottom_left_top_port, top_right_top_port)
  creator.add_edge_between_ports(bottom_left_bottom_port, top_right_bottom_port)

  crossings_bb_set_up_ids(graph)
  let order = crossings_bb_order(graph)
  let graph_data = new_graph_info_holder_from_graph(
    graph,
    crossings_bb_cross_min_type_barycenter(),
    [],
  )
  ignore(
    graph_data.port_distributor().distribute_ports_while_sweeping(
      order,
      1,
      true,
    ),
  )

  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 4)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_crossWithExtraEdgeInBetween" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_with_extra_edge_in_between_graph()
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 3)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_ignoreSelfLoops" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_with_many_self_loops_graph()
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 1)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_moreComplexThreeLayerGraph" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_more_complex_three_layer_graph()

  crossings_bb_set_up_ids(graph)
  let order = crossings_bb_order(graph)
  let graph_data = new_graph_info_holder_from_graph(
    graph,
    crossings_bb_cross_min_type_barycenter(),
    [],
  )
  ignore(
    graph_data.port_distributor().distribute_ports_while_sweeping(
      order,
      1,
      true,
    ),
  )

  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 1)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_fixedPortOrder" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_fixed_port_order_graph()
  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 1)
}

///|
test "CrossingsCounter countCrossingsBetweenLayers_intoSamePort" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  creator.east_west_edge_from_to_nodes(top_left, bottom_right)
  let bottom_left_first_port = creator.add_port_on_side(
    bottom_left,
    crossings_bb_port_side_east(),
  )
  let bottom_left_second_port = creator.add_port_on_side(
    bottom_left,
    crossings_bb_port_side_east(),
  )
  let top_right_first_port = creator.add_port_on_side(
    top_right,
    crossings_bb_port_side_west(),
  )

  creator.add_edge_between_ports(bottom_left_first_port, top_right_first_port)
  creator.add_edge_between_ports(bottom_left_second_port, top_right_first_port)
  creator.set_up_ids()

  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  assert_eq(counter.count_crossings_between_layers(order[0], order[1]), 2)
}

///|
test "CrossingsCounter countCrossingsBetweenPorts_givenWesternCrossings_OnlyCountsForGivenPorts" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])

  crossings_bb_set_up_ids(graph)
  let counter = crossings_bb_counter_for(graph)
  counter.init_for_counting_between(left_nodes, right_nodes)
  assert_eq(
    crossings_bb_pair_value(
      counter
      .count_crossings_between_ports_in_both_orders(
        right_nodes[1].get_ports()[1],
        right_nodes[1].get_ports()[0],
      )
      .get_first(),
    ),
    1,
  )
}

///|
test "CrossingsCounter countCrossingsBetweenPorts_GivenCrossingsOnEasternSide" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(1, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])

  crossings_bb_set_up_ids(graph)
  let counter = crossings_bb_counter_for(graph)
  counter.init_for_counting_between(left_nodes, right_nodes)
  assert_eq(
    crossings_bb_pair_value(
      counter
      .count_crossings_between_ports_in_both_orders(
        left_nodes[0].get_ports()[0],
        left_nodes[0].get_ports()[1],
      )
      .get_first(),
    ),
    1,
  )
}

///|
test "CrossingsCounter countingTwoDifferentGraphs_DoesNotInterfereWithEachOther" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))

  let left_node = left_nodes[1]
  let left_ports = creator.add_ports_on_side(
    2,
    left_node,
    crossings_bb_port_side_east(),
  )
  creator.east_west_edge_from_to_nodes(left_nodes[2], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_ports[0], right_nodes[1])
  creator.east_west_edge_from_to_port_node(left_ports[1], right_nodes[0])
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])

  crossings_bb_set_up_ids(graph)
  let counter = crossings_bb_counter_for(graph)
  counter.init_for_counting_between(left_nodes, right_nodes)
  assert_eq(
    crossings_bb_pair_value(
      counter
      .count_crossings_between_ports_in_both_orders(
        left_node.get_ports()[0],
        left_node.get_ports()[1],
      )
      .get_first(),
    ),
    1,
  )

  counter.switch_ports(left_ports[0], left_ports[1])
  left_node.get_ports()[0] = left_ports[1]
  left_node.get_ports()[1] = left_ports[0]
  assert_eq(
    crossings_bb_pair_value(
      counter
      .count_crossings_between_ports_in_both_orders(
        left_node.get_ports()[0],
        left_node.get_ports()[1],
      )
      .get_first(),
    ),
    0,
  )
}

///|
test "CrossingsCounter countCrossingsBetweenPorts_twoEdgesIntoSamePort" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.make_layer(graph)
  let right_layer = creator.make_layer(graph)

  let top_left = creator.add_node_to_layer(left_layer)
  let bottom_left = creator.add_node_to_layer(left_layer)
  let _top_right = creator.add_node_to_layer(right_layer)
  let bottom_right = creator.add_node_to_layer(right_layer)

  creator.east_west_edge_from_to_nodes(top_left, bottom_right)
  let bottom_left_port = creator.add_port_on_side(
    bottom_left,
    crossings_bb_port_side_east(),
  )
  let top_right_port = creator.add_port_on_side(
    _top_right,
    crossings_bb_port_side_west(),
  )

  creator.add_edge_between_ports(bottom_left_port, top_right_port)
  creator.add_edge_between_ports(bottom_left_port, top_right_port)
  creator.set_up_ids()

  let order = crossings_bb_order(graph)
  let counter = crossings_bb_counter_for(graph)
  counter.init_for_counting_between(order[0], order[1])
  assert_eq(
    crossings_bb_pair_value(
      counter
      .count_crossings_between_ports_in_both_orders(
        bottom_left_port,
        top_left.get_ports()[0],
      )
      .get_first(),
    ),
    2,
  )
}
