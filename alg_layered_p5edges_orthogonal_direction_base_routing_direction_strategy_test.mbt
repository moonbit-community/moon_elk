///|
fn p5edges_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("Unknown PortSide name")
}

///|
fn p5edges_test_new_port(
  node : LNode,
  side : PortSide,
  anchor_x : Double,
  anchor_y : Double,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  ignore(port.get_anchor().set_xy(anchor_x, anchor_y))
  port
}

///|
fn p5edges_test_new_segment_with_single_edge(
  strategy : BaseRoutingDirectionStrategy,
  source_y : Double,
  target_y : Double,
) -> (HyperEdgeSegment, LEdge) {
  let graph = new_l_graph()
  let source_node = new_l_node(graph=Some(graph))
  let target_node = new_l_node(graph=Some(graph))
  ignore(source_node.get_position().set_xy(0.0, source_y))
  ignore(target_node.get_position().set_xy(0.0, target_y))

  let source_port = p5edges_test_new_port(
    source_node,
    p5edges_test_port_side("EAST"),
    0.0,
    0.0,
  )
  let target_port = p5edges_test_new_port(
    target_node,
    p5edges_test_port_side("WEST"),
    0.0,
    0.0,
  )

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))

  let segment = new_hyper_edge_segment(strategy)
  segment.get_ports().push(source_port)
  segment.get_incoming_connection_coordinates().push(source_y)
  segment.get_outgoing_connection_coordinates().push(target_y)
  segment.recompute_extent()
  (segment, edge)
}

///|
fn p5edges_test_assert_bendpoint(
  edge : LEdge,
  index : Int,
  x : Double,
  y : Double,
) -> Unit raise {
  let point = edge.get_bend_points().get(index)
  assert_eq(point.x, x)
  assert_eq(point.y, y)
}

///|
test "BaseRoutingDirectionStrategy picks correct source and target sides" {
  let directions = routing_direction_values()
  let west_to_east = base_routing_direction_strategy_for_routing_direction(
    directions[0],
  )
  assert_eq(port_side_to_string(west_to_east.get_source_port_side()), "EAST")
  assert_eq(port_side_to_string(west_to_east.get_target_port_side()), "WEST")

  let north_to_south = base_routing_direction_strategy_for_routing_direction(
    directions[1],
  )
  assert_eq(port_side_to_string(north_to_south.get_source_port_side()), "SOUTH")
  assert_eq(port_side_to_string(north_to_south.get_target_port_side()), "NORTH")

  let south_to_north = base_routing_direction_strategy_for_routing_direction(
    directions[2],
  )
  assert_eq(port_side_to_string(south_to_north.get_source_port_side()), "NORTH")
  assert_eq(port_side_to_string(south_to_north.get_target_port_side()), "SOUTH")
}

///|
test "WestToEastRoutingStrategy adds two bend points for a regular segment" {
  let strategy = new_west_to_east_routing_strategy()
  let (segment, edge) = p5edges_test_new_segment_with_single_edge(
    strategy, 0.0, 10.0,
  )
  segment.set_routing_slot(1)
  strategy.calculate_bend_points(segment, 100.0, 10.0)

  assert_eq(edge.get_bend_points().size(), 2)
  p5edges_test_assert_bendpoint(edge, 0, 110.0, 0.0)
  p5edges_test_assert_bendpoint(edge, 1, 110.0, 10.0)
}

///|
test "WestToEastRoutingStrategy handles split partner with additional bend points" {
  let strategy = new_west_to_east_routing_strategy()
  let (segment, edge) = p5edges_test_new_segment_with_single_edge(
    strategy, 0.0, 20.0,
  )
  segment.set_routing_slot(1)

  let split_partner = new_hyper_edge_segment(strategy)
  split_partner.get_incoming_connection_coordinates().push(8.0)
  split_partner.get_outgoing_connection_coordinates().push(20.0)
  split_partner.recompute_extent()
  split_partner.set_routing_slot(3)
  segment.set_split_partner(Some(split_partner))
  segment.set_split_by(Some(new_hyper_edge_segment(strategy)))

  strategy.calculate_bend_points(segment, 100.0, 10.0)

  assert_eq(edge.get_bend_points().size(), 4)
  p5edges_test_assert_bendpoint(edge, 0, 110.0, 0.0)
  p5edges_test_assert_bendpoint(edge, 1, 110.0, 8.0)
  p5edges_test_assert_bendpoint(edge, 2, 130.0, 8.0)
  p5edges_test_assert_bendpoint(edge, 3, 130.0, 20.0)
}

///|
test "NorthToSouthRoutingStrategy uses x axis for port positions" {
  let strategy = new_north_to_south_routing_strategy()
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  ignore(node.get_position().set_xy(7.0, 0.0))
  let port = p5edges_test_new_port(
    node,
    p5edges_test_port_side("SOUTH"),
    2.0,
    9.0,
  )
  ignore(port.get_position().set_xy(2.0, 0.0))
  ignore(port.get_anchor().set_xy(3.0, 9.0))
  assert_eq(strategy.get_port_position_on_hyper_node(port), 12.0)
}
