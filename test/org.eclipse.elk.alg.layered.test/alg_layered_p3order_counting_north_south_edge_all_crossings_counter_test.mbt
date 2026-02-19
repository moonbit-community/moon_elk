///|
fn ns_all_crossings_bb_set_up_ids(graph : LGraph) -> Unit {
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
fn ns_all_crossings_bb_order(graph : LGraph) -> Array[Array[LNode]] {
  let order = []
  for layer in graph.get_layers() {
    order.push(layer.get_nodes())
  }
  order
}

///|
fn ns_all_crossings_bb_port_side_north() -> PortSide {
  port_side_values()[1]
}

///|
fn ns_all_crossings_bb_num_ports(graph : LGraph) -> Int {
  let mut num_ports = 0
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      num_ports = num_ports + node.get_ports().length()
    }
  }
  num_ports
}

///|
fn ns_all_crossings_bb_count_in_layer(graph : LGraph, layer_index : Int) -> Int {
  ns_all_crossings_bb_set_up_ids(graph)
  let counter = new_crossings_counter(
    Array::make(ns_all_crossings_bb_num_ports(graph), 0),
  )
  counter.count_north_south_port_crossings_in_layer(
    ns_all_crossings_bb_order(graph)[layer_index],
  )
}

///|
test "NorthSouthEdgeAllCrossingsCounter northernNorthSouthNodeSingleCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_upward_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter northernNorthSouthNodeMultipleCrossings" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_upward_multiple_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 3)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernTowEdgeEastCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_downward_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernNorthSouthMultipleNodeCrossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_downward_multiple_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 3)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernTwoWesternEdges" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_southern_two_western_edges()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernThreeWesternEdges" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_southern_three_western_edges()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 3)
}

///|
test "NorthSouthEdgeAllCrossingsCounter northSouthEdgesComeFromBothSidesDontCross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_graph_edges_from_east_and_west_no_crossings()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 0)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernNorthSouthEdgesBothToEastDontCross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_edges_both_to_east()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 0)
}

///|
test "NorthSouthEdgeAllCrossingsCounter northSouthEdgesComeFromBothSidesDoCross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_edges_from_east_and_west_and_cross()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter northernBothEdgesWestern" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_northern_western_edges()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 0)
}

///|
test "NorthSouthEdgeAllCrossingsCounter northernEasternPortToWestWesternPortToEast" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_northern_eastern_port_to_west_western_port_to_east()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter allSidesMultipleCrossings" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_all_sides_multiple_crossings()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 4)
}

///|
test "NorthSouthEdgeAllCrossingsCounter oneEdgeDummyIsCrossedByOneSouthernNorthSouthPortEdge" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_dummy_edge_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 1)
}

///|
test "NorthSouthEdgeAllCrossingsCounter oneEdgeDummyIsCrossedByTwoSouthernNorthSouthPortEdges" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_dummy_edge_two_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 2)
}

///|
test "NorthSouthEdgeAllCrossingsCounter southernTwoDummyEdgeAndTwoNorthSouthShouldCrossFourTimes" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_two_dummy_edge_and_north_south_crossing_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 4)
}

///|
test "NorthSouthEdgeAllCrossingsCounter normalNodesNorthSouthEdgesHaveCrossingsToLongEdgeDummyOnBothSides" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_multiple_north_south_and_long_edge_dummies_on_both_sides()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 4)
}

///|
test "NorthSouthEdgeAllCrossingsCounter ignoresUnconnectedPortsForNormalNodeAndLongEdgeDummies" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_long_edge_dummy_and_normal_node_with_unused_ports_on_southern_side()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 0)
}

///|
test "NorthSouthEdgeAllCrossingsCounter noNorthSouthNode" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()
  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 0), 0)
}

///|
test "NorthSouthEdgeAllCrossingsCounter moreThanOneEdgeIntoNSNode_countsTheseToo" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()

  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.set_fixed_order_constraint(middle_nodes[2])
  creator.add_north_south_edge(
    ns_all_crossings_bb_port_side_north(),
    middle_nodes[2],
    middle_nodes[1],
    right_nodes[0],
    false,
  )
  creator.add_north_south_edge(
    ns_all_crossings_bb_port_side_north(),
    middle_nodes[2],
    middle_nodes[0],
    left_node,
    true,
  )

  let middle_node_port = middle_nodes[1].get_ports()[0]
  creator.east_west_edge_from_to_port_node(middle_node_port, right_nodes[1])

  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 2)
}

///|
test "NorthSouthEdgeAllCrossingsCounter theOneThatFailedWithTheOldCounting" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()

  let left_nodes = creator.add_nodes_to_layer(4, creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(5, creator.make_layer(graph))
  creator.set_fixed_order_constraint(middle_nodes[4])

  for i in 0..<4 {
    let index = 3 - i
    creator.add_north_south_edge(
      ns_all_crossings_bb_port_side_north(),
      middle_nodes[4],
      middle_nodes[index],
      left_nodes[index],
      false,
    )
  }

  assert_eq(ns_all_crossings_bb_count_in_layer(graph, 1), 0)
}
