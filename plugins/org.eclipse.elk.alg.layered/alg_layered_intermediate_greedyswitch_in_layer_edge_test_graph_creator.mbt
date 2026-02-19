///|
pub struct GreedySwitchInLayerEdgeTestGraphCreator {
  base : GreedySwitchTestGraphCreator
}

///|
pub fn new_greedy_switch_in_layer_edge_test_graph_creator() -> GreedySwitchInLayerEdgeTestGraphCreator {
  { base: new_greedy_switch_test_graph_creator() }
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_graph(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  self.base.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_graph_with_crossings_to_between_layer_edge_with_fixed_port_order(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layers = self.base.make_layers(2)

  let left_node = self.base.add_node_to_layer(layers[0])
  let right_nodes = self.base.add_nodes_to_layer(2, layers[1])

  self.base.set_port_order_fixed(right_nodes[0])

  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[0])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[0])
  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[0])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_with_fixed_port_order_and_normal_edge_crossings(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layers(2)
  let left_node = self.base.add_node_to_layer(layer[0])
  let right_nodes = self.base.add_nodes_to_layer(3, layer[1])
  self.base.set_fixed_order_constraint(right_nodes[0])
  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[0])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[2],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[1])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_crossings_but_no_fixed_order(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layers(2)
  let left_nodes = self.base.add_nodes_to_layer(2, layer[0])
  let right_nodes = self.base.add_nodes_to_layer(2, layer[1])

  self.base.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[1])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_crossings_no_fixed_order_no_edge_between_upper_and_lower(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layers(2)
  let left_nodes = self.base.add_nodes_to_layer(2, layer[0])
  let right_nodes = self.base.add_nodes_to_layer(3, layer[1])

  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[1])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[2],
    PortSide::West,
  )
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[2],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[2])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_crossings_no_fixed_order_no_edge_between_upper_and_lower_upside_down(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layers(2)
  let left_nodes = self.base.add_nodes_to_layer(2, layer[0])
  let right_nodes = self.base.add_nodes_to_layer(4, layer[1])

  self.base.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    PortSide::West,
  )
  self.base.add_in_layer_edge_nodes(
    right_nodes[1],
    right_nodes[3],
    PortSide::West,
  )
  self.base.add_in_layer_edge_nodes(
    right_nodes[1],
    right_nodes[3],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[2])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_crossings_on_both_sides(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layers = self.base.make_layers(3)
  let left_node = self.base.add_node_to_layer(layers[0])
  let middle_nodes = self.base.add_nodes_to_layer(3, layers[1])
  let right_node = self.base.add_node_to_layer(layers[2])

  self.base.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[2],
    PortSide::East,
  )
  self.base.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[2],
    PortSide::West,
  )
  self.base.east_west_edge_from_to_nodes(middle_nodes[1], right_node)
  self.base.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_fixed_port_order_in_layer_and_in_between_layer_crossing(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layers = self.base.make_layers(2)
  let left_node = self.base.add_node_to_layer(layers[0])
  let right_nodes = self.base.add_nodes_to_layer(3, layers[1])

  self.base.set_fixed_order_constraint(right_nodes[1])
  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[1])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    PortSide::West,
  )
  self.base.add_in_layer_edge_nodes(
    right_nodes[1],
    right_nodes[2],
    PortSide::West,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_fixed_port_order_in_layer_crossing(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  self.base.set_fixed_order_constraint(nodes[1])
  self.base.add_in_layer_edge_nodes(nodes[0], nodes[1], PortSide::West)
  self.base.add_in_layer_edge_nodes(nodes[1], nodes[2], PortSide::West)
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_fixed_port_order_two_in_layer_edges_cross_each_other(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let nodes = self.base.add_nodes_to_layer(
    3,
    self.base.make_layer(self.base.get_graph()),
  )
  self.base.set_fixed_order_constraint(nodes[0])
  self.base.add_in_layer_edge_nodes(nodes[0], nodes[2], PortSide::West)
  self.base.add_in_layer_edge_nodes(nodes[0], nodes[1], PortSide::West)
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_downward_graph_no_fixed_order(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layers = self.base.make_layers(2)
  let left_node = self.base.add_node_to_layer(layers[0])
  let right_nodes = self.base.add_nodes_to_layer(3, layers[1])

  self.base.east_west_edge_from_to_nodes(left_node, right_nodes[1])
  self.base.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    PortSide::West,
  )
  self.base.add_in_layer_edge_nodes(
    right_nodes[1],
    right_nodes[2],
    PortSide::West,
  )
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_edges_multiple_edges_into_single_port(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer_two = self.base.make_layer(self.base.get_graph())
  let left_node = self.base.add_node_to_layer(layer_two)
  let layer_one = self.base.make_layer(self.base.get_graph())
  let right_nodes = self.base.add_nodes_to_layer(4, layer_one)

  self.base.add_in_layer_edge_nodes(
    right_nodes[1],
    right_nodes[3],
    PortSide::West,
  )

  let left_port = self.base.add_port_on_side(left_node, PortSide::East)
  let right_top_port = self.base.add_port_on_side(
    right_nodes[0],
    PortSide::West,
  )
  let right_middle_port = self.base.add_port_on_side(
    right_nodes[2],
    PortSide::West,
  )
  self.base.add_edge_between_ports(left_port, right_middle_port)
  self.base.add_edge_between_ports(right_top_port, right_middle_port)
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_one_layer_with_in_layer_crossings(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layer(self.base.get_graph())
  let nodes = self.base.add_nodes_to_layer(4, layer)
  self.base.add_in_layer_edge_nodes(nodes[0], nodes[2], PortSide::West)
  self.base.add_in_layer_edge_nodes(nodes[1], nodes[3], PortSide::West)
  self.get_graph()
}

///|
pub fn GreedySwitchInLayerEdgeTestGraphCreator::get_in_layer_one_layer_no_crossings(
  self : GreedySwitchInLayerEdgeTestGraphCreator,
) -> LGraph {
  let layer = self.base.make_layer(self.base.get_graph())
  let nodes = self.base.add_nodes_to_layer(4, layer)
  self.base.add_in_layer_edge_nodes(nodes[0], nodes[3], PortSide::West)
  self.base.add_in_layer_edge_nodes(nodes[1], nodes[2], PortSide::West)
  self.get_graph()
}
