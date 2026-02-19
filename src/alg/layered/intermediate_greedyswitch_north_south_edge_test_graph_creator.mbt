///|
pub struct GreedySwitchNorthSouthEdgeTestGraphCreator {
  base : GreedySwitchTestGraphCreator
}

///|
pub fn new_greedy_switch_north_south_edge_test_graph_creator() -> GreedySwitchNorthSouthEdgeTestGraphCreator {
  { base: new_greedy_switch_test_graph_creator() }
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  self.base.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_upward_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[2],
    left_nodes[1],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[2],
    left_nodes[0],
    right_nodes[0],
    false,
  )

  self.base.set_fixed_order_constraint(left_nodes[2])
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_upward_multiple_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[3],
    left_nodes[2],
    right_nodes[2],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[3],
    left_nodes[1],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[3],
    left_nodes[0],
    right_nodes[0],
    false,
  )

  self.base.set_fixed_order_constraint(left_nodes[3])
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_three_layer_north_south_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])
  self.base.set_fixed_order_constraint(right_node)

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_node,
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    right_node,
    false,
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_three_layer_north_south_crossing_should_switch_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  ignore(
    self.base.add_node_to_layer(self.base.make_layer(self.base.get_graph())),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.set_as_north_south_node(middle_nodes[1])
  self.base.set_as_north_south_node(middle_nodes[2])
  middle_nodes[2].set_property_l_node(
    internal_properties_origin_l_node,
    Some(middle_nodes[0]),
  )
  middle_nodes[1].set_property_l_node(
    internal_properties_origin_l_node,
    Some(middle_nodes[0]),
  )

  let left_bottom_node_right_port = self.base.add_port_on_side(
    middle_nodes[2],
    @core.PortSide::East,
  )
  let right_node_bottom_port = self.base.add_port_on_side(
    right_nodes[1],
    @core.PortSide::West,
  )
  self.base.add_edge_between_ports(
    left_bottom_node_right_port, right_node_bottom_port,
  )
  let left_top_node_right_port = self.base.add_port_on_side(
    middle_nodes[0],
    @core.PortSide::South,
  )
  left_bottom_node_right_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(left_top_node_right_port),
  )

  let left_middle_node_right_port = self.base.add_port_on_side(
    middle_nodes[1],
    @core.PortSide::East,
  )
  let right_node_top_port = self.base.add_port_on_side(
    right_nodes[0],
    @core.PortSide::West,
  )
  self.base.add_edge_between_ports(
    left_middle_node_right_port, right_node_top_port,
  )
  let left_top_node_left_port = self.base.add_port_on_side(
    middle_nodes[0],
    @core.PortSide::South,
  )
  left_middle_node_right_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(left_top_node_left_port),
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_southern_north_south_dummy_edge_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.base.set_as_long_edge_dummy(middle_nodes[1])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_nodes[1],
    true,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_southern_north_south_dummy_edge_two_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.base.set_as_long_edge_dummy(middle_nodes[1])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_nodes[1],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[3],
    right_nodes[2],
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_southern_two_dummy_edge_and_north_south_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    5,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.base.set_as_long_edge_dummy(middle_nodes[1])

  self.base.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[3])
  self.base.east_west_edge_from_to_nodes(middle_nodes[3], right_nodes[2])
  self.base.set_as_long_edge_dummy(middle_nodes[3])

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[4],
    right_nodes[3],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_nodes[1],
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_northern_north_south_dummy_edge_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[1])
  self.base.set_as_long_edge_dummy(middle_nodes[1])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[0],
    right_nodes[0],
    true,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_south_port_on_normal_node_below_long_edge_dummy(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
  self.base.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[0])
  middle_nodes[0].set_type(NodeType::LongEdge)

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[1],
    middle_nodes[2],
    right_nodes[1],
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_port_ond_normal_node_above_long_edge_dummy(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[2])
  self.base.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[1])
  middle_nodes[2].set_type(NodeType::LongEdge)

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[1],
    middle_nodes[0],
    right_nodes[0],
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_long_edge_dummy_and_normal_node_with_unused_ports_on_southern_side(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_node)
  self.base.set_as_long_edge_dummy(middle_nodes[1])

  ignore(self.base.add_port_on_side(middle_nodes[0], @core.PortSide::South))
  ignore(self.base.add_port_on_side(middle_nodes[0], @core.PortSide::South))
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_long_edge_dummy_and_normal_node_with_unused_ports_on_northern_side(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
  self.base.east_west_edge_from_to_nodes(middle_nodes[0], right_node)
  middle_nodes[0].set_type(NodeType::LongEdge)

  ignore(self.base.add_port_on_side(middle_nodes[1], @core.PortSide::North))
  ignore(self.base.add_port_on_side(middle_nodes[1], @core.PortSide::North))
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_multiple_north_south_and_long_edge_dummies_on_both_sides(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    7,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    6,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[2])
  self.base.east_west_edge_from_to_nodes(middle_nodes[2], right_nodes[2])
  self.base.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[4])
  self.base.east_west_edge_from_to_nodes(middle_nodes[4], right_nodes[4])

  self.base.set_as_long_edge_dummy(middle_nodes[2])
  self.base.set_as_long_edge_dummy(middle_nodes[4])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[3],
    middle_nodes[0],
    right_nodes[0],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[3],
    middle_nodes[1],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[3],
    middle_nodes[5],
    right_nodes[4],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[3],
    middle_nodes[6],
    right_nodes[5],
    false,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_downward_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[2],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[1],
    right_nodes[0],
    false,
  )

  self.base.set_fixed_order_constraint(left_nodes[0])
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_downward_multiple_crossing_graph(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[3],
    right_nodes[2],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[2],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[1],
    right_nodes[0],
    false,
  )

  self.base.set_fixed_order_constraint(left_nodes[0])
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_southern_north_south_graph_edges_from_east_and_west_no_crossings(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    right_node,
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    left_node,
    true,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_northern_north_south_graph_edges_from_east_and_west_no_crossings(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[2])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[0],
    left_node,
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[1],
    right_node,
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_northern_north_south_graph_edges_from_east_and_west_no_crossings_upper_edge_east(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[2])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[1],
    left_node,
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[0],
    right_node,
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_edges_from_east_and_west_and_cross(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    left_node,
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_node,
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_southern_north_south_edges_both_to_east(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    right_nodes[0],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    right_nodes[1],
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_southern_two_western_edges(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    left_nodes[0],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    left_nodes[1],
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_southern_three_western_edges(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    left_nodes[0],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    left_nodes[1],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[3],
    left_nodes[2],
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_northern_western_edges(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[2])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[1],
    left_nodes[1],
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[0],
    left_nodes[0],
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_northern_eastern_port_to_west_western_port_to_east(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[2])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[1],
    right_node,
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[2],
    middle_nodes[0],
    left_node,
    true,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_all_sides_multiple_crossings(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    7,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    5,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[3])

  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[3],
    middle_nodes[1],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[3],
    middle_nodes[2],
    left_node,
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    middle_nodes[3],
    middle_nodes[0],
    right_nodes[0],
    false,
  )

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[3],
    middle_nodes[6],
    right_nodes[4],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[3],
    middle_nodes[4],
    right_nodes[2],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[3],
    middle_nodes[5],
    right_nodes[3],
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_north_south_southern_western_port_to_east_and_eastern_port_to_west(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(middle_nodes[0])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[2],
    left_node,
    true,
  )
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[0],
    middle_nodes[1],
    right_node,
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_graph_where_layout_unit_prevents_switch(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    2,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_fixed_order_constraint(left_nodes[0])
  self.base.set_fixed_order_constraint(left_nodes[3])

  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[0],
    left_nodes[1],
    right_nodes[1],
    false,
  )
  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[3],
    left_nodes[2],
    right_nodes[0],
    false,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_graph_layout_unit_prevents_switch_with_node_with_node_with_northern_edges(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.add_north_south_edge(
    @core.PortSide::North,
    left_nodes[1],
    left_nodes[0],
    right_nodes[0],
    false,
  )
  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[2])
  self.base.east_west_edge_from_to_nodes(left_nodes[2], right_nodes[1])

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_graph_layout_unit_prevents_switch_with_node_with_node_with_southern_edges(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  self.base.add_north_south_edge(
    @core.PortSide::South,
    left_nodes[1],
    left_nodes[2],
    right_nodes[2],
    false,
  )

  self.get_graph()
}

///|
pub fn GreedySwitchNorthSouthEdgeTestGraphCreator::get_graph_layout_unit_does_not_prevent_switch_with_long_edge_dummy(
  self : GreedySwitchNorthSouthEdgeTestGraphCreator,
) -> LGraph {
  let left_node = self.base.add_node_to_layer(
    self.base.make_layer(self.base.get_graph()),
  )
  let middle_nodes = self.base.add_nodes_to_layer(
    4,
    self.base.make_layer(self.base.get_graph()),
  )
  let right_nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )

  self.base.set_as_long_edge_dummy(middle_nodes[0])
  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[0])
  self.base.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[1])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.base.add_north_south_edge(
    @core.PortSide::South,
    middle_nodes[1],
    middle_nodes[2],
    right_nodes[2],
    false,
  )

  self.get_graph()
}
