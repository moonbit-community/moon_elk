///|
fn north_south_is_side(port : LPort, side : PortSide) -> Bool {
  match (port.get_side(), side) {
    (PortSide::North, PortSide::North) => true
    (PortSide::East, PortSide::East) => true
    (PortSide::South, PortSide::South) => true
    (PortSide::West, PortSide::West) => true
    (PortSide::SideUndefined, PortSide::SideUndefined) => true
    _ => false
  }
}

///|
fn north_south_same_node(left : LNode?, right : LNode?) -> Bool {
  match (left, right) {
    (None, None) => true
    (Some(left_node), Some(right_node)) =>
      lnode_internal_handle(left_node) == lnode_internal_handle(right_node)
    _ => false
  }
}

///|
fn north_south_origin_port_of(node : LNode) -> LPort {
  if node.get_ports().is_empty() {
    abort("north south dummy node has no ports")
  }
  match
    node.get_ports()[0].get_property_l_port(internal_properties_origin_l_port) {
    Some(origin) => origin
    None => abort("north south dummy node has no origin port")
  }
}

///|
fn north_south_origin_of(node : LNode) -> LNode? {
  node.get_property_l_node(internal_properties_origin_l_node)
}

///|
pub struct NorthSouthEdgeNeighbouringNodeCrossingsCounter {
  mut upper_lower_crossings : Int
  mut lower_upper_crossings : Int
  port_positions : Map[Int, Int]
  layer : Array[LNode]
}

///|
pub fn new_north_south_edge_neighbouring_node_crossings_counter(
  nodes : Array[LNode],
) -> NorthSouthEdgeNeighbouringNodeCrossingsCounter {
  let counter = {
    upper_lower_crossings: 0,
    lower_upper_crossings: 0,
    port_positions: {},
    layer: nodes,
  }
  counter.initialize_port_positions()
  counter
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::initialize_port_positions(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
) -> Unit {
  for node in self.layer {
    self.set_port_ids_on(node, PortSide::South)
    self.set_port_ids_on(node, PortSide::North)
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::set_port_ids_on(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
  side : PortSide,
) -> Unit {
  let ports = in_north_south_east_west_order(node, side)
  let mut port_id = 0
  for port in ports {
    self.port_positions[lport_internal_handle(port)] = port_id
    port_id = port_id + 1
  }
}

///|
pub fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::count_crossings(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  self.upper_lower_crossings = 0
  self.lower_upper_crossings = 0

  self.process_if_two_north_south_nodes(upper_node, lower_node)
  self.process_if_north_south_long_edge_dummy_crossing(upper_node, lower_node)
  self.process_if_normal_node_with_ns_ports_and_long_edge_dummy(
    upper_node, lower_node,
  )
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::process_if_two_north_south_nodes(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  if self.is_north_south(upper_node) &&
    self.is_north_south(lower_node) &&
    !self.have_different_origins(upper_node, lower_node) {
    if self.is_north_of_normal_node(upper_node) {
      self.count_crossings_of_two_north_south_dummies(upper_node, lower_node)
    } else {
      self.count_crossings_of_two_north_south_dummies(lower_node, upper_node)
    }
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::count_crossings_of_two_north_south_dummies(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  further_from_normal_node : LNode,
  closer_to_normal_node : LNode,
) -> Unit {
  if self.origin_port_position_of(further_from_normal_node) >
    self.origin_port_position_of(closer_to_normal_node) {
    let closer_east_ports = closer_to_normal_node.get_port_side_view(
      PortSide::East,
    )
    self.upper_lower_crossings = if closer_east_ports.is_empty() {
      0
    } else {
      closer_east_ports[0].get_degree()
    }

    let further_west_ports = further_from_normal_node.get_port_side_view(
      PortSide::West,
    )
    self.lower_upper_crossings = if further_west_ports.is_empty() {
      0
    } else {
      further_west_ports[0].get_degree()
    }
  } else {
    let closer_west_ports = closer_to_normal_node.get_port_side_view(
      PortSide::West,
    )
    self.upper_lower_crossings = if closer_west_ports.is_empty() {
      0
    } else {
      closer_west_ports[0].get_degree()
    }

    let further_east_ports = further_from_normal_node.get_port_side_view(
      PortSide::East,
    )
    self.lower_upper_crossings = if further_east_ports.is_empty() {
      0
    } else {
      further_east_ports[0].get_degree()
    }
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::process_if_north_south_long_edge_dummy_crossing(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  if self.is_north_south(upper_node) && self.is_long_edge_dummy(lower_node) {
    if self.is_north_of_normal_node(upper_node) {
      self.upper_lower_crossings = 1
    } else {
      self.lower_upper_crossings = 1
    }
  } else if self.is_north_south(lower_node) &&
    self.is_long_edge_dummy(upper_node) {
    if self.is_north_of_normal_node(lower_node) {
      self.lower_upper_crossings = 1
    } else {
      self.upper_lower_crossings = 1
    }
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::process_if_normal_node_with_ns_ports_and_long_edge_dummy(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  if self.is_normal(upper_node) && self.is_long_edge_dummy(lower_node) {
    self.upper_lower_crossings = self.number_of_north_south_edges(
      upper_node,
      PortSide::South,
    )
    self.lower_upper_crossings = self.number_of_north_south_edges(
      upper_node,
      PortSide::North,
    )
  }
  if self.is_normal(lower_node) && self.is_long_edge_dummy(upper_node) {
    self.upper_lower_crossings = self.number_of_north_south_edges(
      lower_node,
      PortSide::North,
    )
    self.lower_upper_crossings = self.number_of_north_south_edges(
      lower_node,
      PortSide::South,
    )
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::number_of_north_south_edges(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
  side : PortSide,
) -> Int {
  let mut number_of_edges = 0
  for port in node.get_port_side_view(side) {
    if self.has_connected_north_south_edge(port) {
      number_of_edges = number_of_edges + 1
    }
  }
  number_of_edges
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::has_connected_north_south_edge(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  port : LPort,
) -> Bool {
  ignore(self)
  match port.get_property_l_node(internal_properties_port_dummy) {
    Some(_) => true
    None => false
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::have_different_origins(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
) -> Bool {
  ignore(self)
  !north_south_same_node(
    north_south_origin_of(upper_node),
    north_south_origin_of(lower_node),
  )
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::origin_port_position_of(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
) -> Int {
  let origin = north_south_origin_port_of(node)
  let key = lport_internal_handle(origin)
  match self.port_positions.get(key) {
    Some(position) => position
    None => abort("origin port position was not initialized")
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::is_north_of_normal_node(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
) -> Bool {
  ignore(self)
  north_south_is_side(north_south_origin_port_of(node), PortSide::North)
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::is_long_edge_dummy(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_type() {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::is_north_south(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_type() {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::is_normal(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_type() {
    NodeType::Normal => true
    _ => false
  }
}

///|
pub fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::get_upper_lower_crossings(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
) -> Int {
  self.upper_lower_crossings
}

///|
pub fn NorthSouthEdgeNeighbouringNodeCrossingsCounter::get_lower_upper_crossings(
  self : NorthSouthEdgeNeighbouringNodeCrossingsCounter,
) -> Int {
  self.lower_upper_crossings
}
