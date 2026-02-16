///|
fn north_south_bb_port_side_north() -> PortSide {
  port_side_values()[1]
}

///|
fn north_south_bb_port_side_east() -> PortSide {
  port_side_values()[2]
}

///|
fn north_south_bb_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn north_south_bb_layer(graph : LGraph, layer_index : Int) -> Array[LNode] {
  graph.get_layers()[layer_index].get_nodes()
}

///|
fn north_south_bb_new_counter(
  layer : Array[LNode],
) -> NorthSouthEdgeNeighbouringNodeCrossingsCounter {
  new_north_south_edge_neighbouring_node_crossings_counter(layer)
}

///|
fn north_south_bb_swap_nodes(
  layer : Array[LNode],
  upper_index : Int,
  lower_index : Int,
) -> Unit {
  let upper_node = layer[upper_index]
  layer[upper_index] = layer[lower_index]
  layer[lower_index] = upper_node
}

///|
fn north_south_bb_assert_counts(
  counter : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  layer : Array[LNode],
  upper_index : Int,
  lower_index : Int,
  expected_upper_lower : Int,
  expected_lower_upper : Int,
) -> Unit raise {
  counter.count_crossings(layer[upper_index], layer[lower_index])
  assert_eq(counter.get_upper_lower_crossings(), expected_upper_lower)
  assert_eq(counter.get_lower_upper_crossings(), expected_lower_upper)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter has zero without north-south nodes" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_cross_formed_graph()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter counts southern north-south crossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_downward_crossing_graph()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter counts northern north-south crossing" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_upward_crossing_graph()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter handles long-edge dummy southern case" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_dummy_edge_crossing_graph()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 0)
  north_south_bb_swap_nodes(layer, 1, 2)
  north_south_bb_assert_counts(counter, layer, 1, 2, 0, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter handles long-edge dummy northern case" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_northern_north_south_dummy_edge_crossing_graph()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
  north_south_bb_swap_nodes(layer, 0, 1)
  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter ignores normal-node pair" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_downward_crossing_graph()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter north-south edges from both sides do not cross" {
  let southern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let southern_graph = southern_creator.get_southern_north_south_graph_edges_from_east_and_west_no_crossings()
  let southern_layer = north_south_bb_layer(southern_graph, 1)
  let southern_counter = north_south_bb_new_counter(southern_layer)
  north_south_bb_assert_counts(southern_counter, southern_layer, 1, 2, 0, 0)

  let northern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let northern_graph = northern_creator.get_northern_north_south_graph_edges_from_east_and_west_no_crossings()
  let northern_layer = north_south_bb_layer(northern_graph, 1)
  let northern_counter = north_south_bb_new_counter(northern_layer)
  north_south_bb_assert_counts(northern_counter, northern_layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter southern north-south edges both to east" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_southern_north_south_edges_both_to_east()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 0, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter ignores different layout-unit origins" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_graph_where_layout_unit_prevents_switch()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter north-south edges from both sides can cross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_edges_from_east_and_west_and_cross()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter switch nodes and recount" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_upward_crossing_graph()
  let layer = north_south_bb_layer(graph, 0)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
  north_south_bb_swap_nodes(layer, 0, 1)
  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter south port below long-edge dummy" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_south_port_on_normal_node_below_long_edge_dummy()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 1)
  north_south_bb_swap_nodes(layer, 0, 1)
  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter north port above long-edge dummy" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_port_ond_normal_node_above_long_edge_dummy()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 0, 1)
  north_south_bb_swap_nodes(layer, 1, 2)
  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter southern two western edges" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_southern_two_western_edges()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 0)
  north_south_bb_swap_nodes(layer, 1, 2)
  north_south_bb_assert_counts(counter, layer, 1, 2, 0, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter southern west-to-east and east-to-west" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_southern_western_port_to_east_and_eastern_port_to_west()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 1)
  north_south_bb_swap_nodes(layer, 1, 2)
  north_south_bb_assert_counts(counter, layer, 1, 2, 1, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter northern both edges western" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_northern_western_edges()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 1)
  north_south_bb_swap_nodes(layer, 0, 1)
  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter northern east-to-west and west-to-east" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_north_south_northern_eastern_port_to_west_western_port_to_east()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 1)
  north_south_bb_swap_nodes(layer, 0, 1)
  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter normal-node N/S edges cross long-edge dummies" {
  let northern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let northern_graph = northern_creator.get_northern_north_south_dummy_edge_crossing_graph()
  let northern_layer = north_south_bb_layer(northern_graph, 1)
  let northern_counter = north_south_bb_new_counter(northern_layer)

  north_south_bb_assert_counts(northern_counter, northern_layer, 0, 1, 1, 0)
  north_south_bb_assert_counts(northern_counter, northern_layer, 1, 2, 1, 0)

  let southern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let southern_graph = southern_creator.get_southern_north_south_dummy_edge_crossing_graph()
  let southern_layer = north_south_bb_layer(southern_graph, 1)
  let southern_counter = north_south_bb_new_counter(southern_layer)

  north_south_bb_assert_counts(southern_counter, southern_layer, 0, 1, 1, 0)
  north_south_bb_assert_counts(southern_counter, southern_layer, 1, 2, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter long-edge dummies on both sides" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_multiple_north_south_and_long_edge_dummies_on_both_sides()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 2, 3, 2, 2)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter ignores unconnected ports" {
  let southern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let southern_graph = southern_creator.get_long_edge_dummy_and_normal_node_with_unused_ports_on_southern_side()
  let southern_layer = north_south_bb_layer(southern_graph, 1)
  let southern_counter = north_south_bb_new_counter(southern_layer)

  north_south_bb_assert_counts(southern_counter, southern_layer, 0, 1, 0, 0)

  let northern_creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let northern_graph = northern_creator.get_long_edge_dummy_and_normal_node_with_unused_ports_on_northern_side()
  let northern_layer = north_south_bb_layer(northern_graph, 1)
  let northern_counter = north_south_bb_new_counter(northern_layer)

  north_south_bb_assert_counts(northern_counter, northern_layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter one west and one east edge do not cross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_northern_north_south_graph_edges_from_east_and_west_no_crossings()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter one east and one west edge do not cross" {
  let creator = new_greedy_switch_north_south_edge_test_graph_creator()
  let graph = creator.get_northern_north_south_graph_edges_from_east_and_west_no_crossings_upper_edge_east()
  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)

  north_south_bb_assert_counts(counter, layer, 0, 1, 0, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter polyline multiple edges into NS node" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let middle_nodes = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.set_fixed_order_constraint(middle_nodes[2])
  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_nodes[2],
    middle_nodes[1],
    right_nodes[0],
    false,
  )
  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_nodes[2],
    middle_nodes[0],
    left_node,
    true,
  )

  let middle_node_port = middle_nodes[1].get_ports()[0]
  creator.east_west_edge_from_to_port_node(middle_node_port, right_nodes[1])
  graph.set_property_string(edge_routing, "POLYLINE")
  creator.set_up_ids()

  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)
  north_south_bb_assert_counts(counter, layer, 0, 1, 2, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter multiple edges in one NS dummy" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_node = creator.add_node_to_layer(creator.make_layer(graph))
  let middle_layer = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_layer = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.set_fixed_order_constraint(middle_layer[2])
  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[1],
    left_node,
    true,
  )

  let normal_node_port = creator.add_port_on_side(
    right_layer[1],
    north_south_bb_port_side_west(),
  )
  let dummy_node_port = creator.add_port_on_side(
    middle_layer[1],
    north_south_bb_port_side_east(),
  )
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  let origin_port = middle_layer[2].get_ports()[0]
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[0],
    right_layer[0],
    false,
  )
  creator.set_up_ids()

  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)
  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter edges in both directions" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let middle_layer = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_layer = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.set_fixed_order_constraint(middle_layer[2])
  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[1],
    left_layer[1],
    true,
  )

  let mut normal_node_port = creator.add_port_on_side(
    right_layer[1],
    north_south_bb_port_side_west(),
  )
  let mut dummy_node_port = creator.add_port_on_side(
    middle_layer[1],
    north_south_bb_port_side_east(),
  )
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  let mut origin_port = middle_layer[2].get_ports()[0]
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[0],
    left_layer[0],
    true,
  )

  normal_node_port = creator.add_port_on_side(
    right_layer[0],
    north_south_bb_port_side_west(),
  )
  dummy_node_port = creator.add_port_on_side(
    middle_layer[0],
    north_south_bb_port_side_east(),
  )
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  origin_port = middle_layer[2].get_ports()[1]
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )
  creator.set_up_ids()

  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)
  north_south_bb_assert_counts(counter, layer, 0, 1, 1, 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter multiple edges in both directions" {
  let creator = new_greedy_switch_test_graph_creator()
  let graph = creator.get_graph()
  let left_layer = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let middle_layer = creator.add_nodes_to_layer(3, creator.make_layer(graph))
  let right_layer = creator.add_nodes_to_layer(2, creator.make_layer(graph))

  creator.set_fixed_order_constraint(middle_layer[2])
  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[1],
    left_layer[1],
    true,
  )

  let mut normal_node_port = creator.add_port_on_side(
    right_layer[1],
    north_south_bb_port_side_west(),
  )
  let mut dummy_node_port = creator.add_port_on_side(
    middle_layer[1],
    north_south_bb_port_side_east(),
  )
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  let mut origin_port = middle_layer[2].get_ports()[0]
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  creator.add_north_south_edge(
    north_south_bb_port_side_north(),
    middle_layer[2],
    middle_layer[0],
    right_layer[0],
    false,
  )

  normal_node_port = creator.add_port_on_side(
    right_layer[0],
    north_south_bb_port_side_east(),
  )
  dummy_node_port = creator.add_port_on_side(
    middle_layer[0],
    north_south_bb_port_side_west(),
  )
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  creator.add_edge_between_ports(dummy_node_port, normal_node_port)
  origin_port = middle_layer[2].get_ports()[1]
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )
  creator.set_up_ids()

  let layer = north_south_bb_layer(graph, 1)
  let counter = north_south_bb_new_counter(layer)
  north_south_bb_assert_counts(counter, layer, 0, 1, 2, 2)
}
