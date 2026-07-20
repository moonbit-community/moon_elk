///|
fn all_crossings_bb_set_up_ids(graph : LGraph) -> Unit {
  let mut port_id = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      for port in node.get_ports() {
        port.set_id(port_id)
        port_id = port_id + 1
      }
    }
  }
}

///|
fn all_crossings_bb_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn all_crossings_bb_port_side_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn all_crossings_bb_port_side_north() -> @core.PortSide {
  @core.port_side_values()[1]
}

///|
fn all_crossings_bb_port_side_south() -> @core.PortSide {
  @core.port_side_values()[3]
}

///|
fn all_crossings_bb_count_all_crossings(graph : LGraph) -> Int {
  all_crossings_bb_set_up_ids(graph)
  let order = all_crossings_bb_order(graph)
  let graph_data = new_graph_info_holder_from_graph(
    graph,
    cross_min_type_constants()[0],
    [],
  )
  graph_data.cross_counter().count_all_crossings(order)
}

///|
fn all_crossings_bb_switch_nodes_in_layer(
  graph : LGraph,
  upper_node_index : Int,
  lower_node_index : Int,
  layer_index : Int,
) -> Unit {
  let layer = graph.get_layers()[layer_index]
  let nodes = layer.get_nodes()
  let upper = nodes[upper_node_index]
  nodes[upper_node_index] = nodes[lower_node_index]
  nodes[lower_node_index] = upper
}

///|
test "AllCrossingsCounter countOneCrossing" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter countInLayerCrossing" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter countInLayerCrossingAndSwitch" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_in_layer_edges_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter countNorthSouthCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_downward_crossing_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter countNorthernNorthSouthCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_upward_crossing_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter northSouthDummyEdgeCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_dummy_edge_crossing_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter switchAndCountTwice" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()

  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)

  all_crossings_bb_switch_nodes_in_layer(graph, 0, 1, 1)
  assert_eq(all_crossings_bb_count_all_crossings(graph), 0)
}

///|
test "AllCrossingsCounter tooManyInLayerCrossingsWithTheOldMethod" {
  let creator = new_greedy_switch_in_layer_edge_test_graph_creator()
  let graph = creator.get_in_layer_one_layer_no_crossings()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 0)
}

///|
test "AllCrossingsCounter countCrossingsWithMultipleEdgesBetweenSameNodes" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()

  let left = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  let right_lower_ports = creator.add_ports_on_side(
    2,
    right[1],
    all_crossings_bb_port_side_west(),
  )
  creator.east_west_edge_from_to_node_port(left[0], right_lower_ports[1])
  creator.east_west_edge_from_to_node_port(left[0], right_lower_ports[0])

  let right_upper_ports = creator.add_ports_on_side(
    2,
    right[0],
    all_crossings_bb_port_side_west(),
  )
  creator.east_west_edge_from_to_node_port(left[1], right_upper_ports[1])
  creator.east_west_edge_from_to_node_port(left[1], right_upper_ports[0])

  assert_eq(all_crossings_bb_count_all_crossings(graph), 4)
}

///|
test "AllCrossingsCounter countCrossingsInEmptyGraph" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_empty_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 0)
}

///|
test "AllCrossingsCounter oneNodeIsLongEdgeDummy" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_dummy_edge_crossing_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter oneNodeIsLongEdgeDummyNorthern" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_northern_north_south_dummy_edge_crossing_graph()
  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}

///|
test "AllCrossingsCounter multipleNorthSouthAndLongEdgeDummiesOnBothSides" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(7, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(6, creator.make_layer(graph))

  creator.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[2])
  creator.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[2])
  creator.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[4])
  creator.east_west_edge_from_to_nodes(middle_nodes[4], right_nodes[3])

  creator.set_as_long_edge_dummy(middle_nodes[2])
  creator.set_as_long_edge_dummy(middle_nodes[4])

  creator.add_north_south_edge(
    all_crossings_bb_port_side_north(),
    middle_nodes[3],
    middle_nodes[0],
    right_nodes[0],
    false,
  )
  creator.add_north_south_edge(
    all_crossings_bb_port_side_north(),
    middle_nodes[3],
    middle_nodes[1],
    right_nodes[1],
    false,
  )
  creator.add_north_south_edge(
    all_crossings_bb_port_side_south(),
    middle_nodes[3],
    middle_nodes[5],
    right_nodes[4],
    false,
  )
  creator.add_north_south_edge(
    all_crossings_bb_port_side_south(),
    middle_nodes[3],
    middle_nodes[6],
    right_nodes[5],
    false,
  )

  assert_eq(all_crossings_bb_count_all_crossings(graph), 4)
}

///|
test "AllCrossingsCounter inLayerCrossingsOnFarLeft" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))

  creator.set_fixed_order_constraint(nodes[1])
  creator.add_in_layer_edge_nodes(
    nodes[0],
    nodes[1],
    all_crossings_bb_port_side_west(),
  )
  creator.add_in_layer_edge_nodes(
    nodes[1],
    nodes[2],
    all_crossings_bb_port_side_west(),
  )

  assert_eq(all_crossings_bb_count_all_crossings(graph), 1)
}
