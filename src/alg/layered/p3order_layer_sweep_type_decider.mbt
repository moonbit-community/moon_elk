///|
fn layer_sweep_type_decider_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => @core.PortConstraints::Undefined
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn layer_sweep_type_decider_is_side(port : LPort, side : @core.PortSide) -> Bool {
  match (port.get_side(), side) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
pub struct LayerSweepTypeDeciderNodeInfo {
  mut connected_edges : Int
  mut hierarchical_influence : Int
  mut random_influence : Int
}

///|
pub fn new_layer_sweep_type_decider_node_info() -> LayerSweepTypeDeciderNodeInfo {
  { connected_edges: 0, hierarchical_influence: 0, random_influence: 0 }
}

///|
pub fn LayerSweepTypeDeciderNodeInfo::transfer(
  self : LayerSweepTypeDeciderNodeInfo,
  node_info : LayerSweepTypeDeciderNodeInfo,
) -> Unit {
  self.hierarchical_influence = self.hierarchical_influence +
    node_info.hierarchical_influence
  self.random_influence = self.random_influence + node_info.random_influence
  self.connected_edges = self.connected_edges + node_info.connected_edges
}

///|
pub struct LayerSweepTypeDecider {
  node_info : Array[Array[LayerSweepTypeDeciderNodeInfo]]
  graph_data : GraphInfoHolder
}

///|
pub fn new_layer_sweep_type_decider(
  graph_data : GraphInfoHolder,
) -> LayerSweepTypeDecider {
  let node_info = []
  for _ in 0..<graph_data.current_node_order().length() {
    node_info.push([])
  }
  { node_info, graph_data }
}

///|
pub fn LayerSweepTypeDecider::use_bottom_up(
  self : LayerSweepTypeDecider,
) -> Bool {
  let boundary = self.graph_data
    .l_graph()
    .get_property_double(
      layered_options_crossing_minimization_hierarchical_sweepiness,
    )
  if self.bottom_up_forced(boundary) ||
    self.root_node() ||
    self.fixed_port_order() ||
    self.fewer_than_two_in_out_edges() {
    return true
  }

  if self.graph_data.cross_min_deterministic() {
    return false
  }

  let mut paths_to_random = 0
  let mut paths_to_hierarchical = 0

  let ns_port_dummies = []
  for layer in self.graph_data.current_node_order() {
    for node in layer {
      if self.is_north_south_dummy(node) {
        ns_port_dummies.push(node)
        continue
      }

      let current_node = self.node_info_for(node)
      if self.is_external_port_dummy(node) {
        current_node.hierarchical_influence = 1
        if self.is_eastern_dummy(node) {
          paths_to_hierarchical = paths_to_hierarchical +
            current_node.connected_edges
        }
      } else if self.has_no_western_ports(node) {
        current_node.random_influence = 1
      } else if self.has_no_eastern_ports(node) {
        paths_to_random = paths_to_random + current_node.connected_edges
      }

      for edge in node.get_outgoing_edges() {
        paths_to_random = paths_to_random + current_node.random_influence
        paths_to_hierarchical = paths_to_hierarchical +
          current_node.hierarchical_influence
        self.transfer_info_to_target(current_node, edge)
      }

      for port in node.get_port_side_view(@core.PortSide::North) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(ns_dummy) => {
            paths_to_random = paths_to_random + current_node.random_influence
            paths_to_hierarchical = paths_to_hierarchical +
              current_node.hierarchical_influence
            self.transfer_info_to(current_node, ns_dummy)
          }
          None => ()
        }
      }
      for port in node.get_port_side_view(@core.PortSide::South) {
        match port.get_property_l_node(internal_properties_port_dummy) {
          Some(ns_dummy) => {
            paths_to_random = paths_to_random + current_node.random_influence
            paths_to_hierarchical = paths_to_hierarchical +
              current_node.hierarchical_influence
            self.transfer_info_to(current_node, ns_dummy)
          }
          None => ()
        }
      }
    }

    for node in ns_port_dummies {
      let current_node = self.node_info_for(node)
      for edge in node.get_outgoing_edges() {
        paths_to_random = paths_to_random + current_node.random_influence
        paths_to_hierarchical = paths_to_hierarchical +
          current_node.hierarchical_influence
        self.transfer_info_to_target(current_node, edge)
      }
    }
    ns_port_dummies.clear()
  }

  let all_paths = (paths_to_random + paths_to_hierarchical).to_double()
  let normalized = if all_paths == 0.0 {
    @double.infinity
  } else {
    (paths_to_random.to_double() - paths_to_hierarchical.to_double()) /
    all_paths
  }
  normalized >= boundary
}

///|
fn LayerSweepTypeDecider::fixed_port_order(
  self : LayerSweepTypeDecider,
) -> Bool {
  if !self.graph_data.has_parent() {
    return false
  }
  let parent = self.graph_data.parent()
  let constraints_value = if parent.has_property_string(@core.port_constraints) {
    parent.get_property_string(@core.port_constraints)
  } else {
    @core.port_constraints.get_default()
  }
  layer_sweep_type_decider_port_constraints_from_string(constraints_value).is_order_fixed()
}

///|
fn LayerSweepTypeDecider::transfer_info_to_target(
  self : LayerSweepTypeDecider,
  current_node : LayerSweepTypeDeciderNodeInfo,
  edge : LEdge,
) -> Unit {
  match edge.get_target() {
    Some(target) =>
      match target.get_node() {
        Some(target_node) => self.transfer_info_to(current_node, target_node)
        None => ()
      }
    None => ()
  }
}

///|
fn LayerSweepTypeDecider::transfer_info_to(
  self : LayerSweepTypeDecider,
  current_node : LayerSweepTypeDeciderNodeInfo,
  target : LNode,
) -> Unit {
  let target_node_info = self.node_info_for(target)
  target_node_info.transfer(current_node)
  target_node_info.connected_edges = target_node_info.connected_edges + 1
}

///|
fn LayerSweepTypeDecider::fewer_than_two_in_out_edges(
  self : LayerSweepTypeDecider,
) -> Bool {
  if !self.graph_data.has_parent() {
    return false
  }
  let parent = self.graph_data.parent()
  parent.get_port_side_view(@core.PortSide::East).length() < 2 &&
  parent.get_port_side_view(@core.PortSide::West).length() < 2
}

///|
fn LayerSweepTypeDecider::root_node(self : LayerSweepTypeDecider) -> Bool {
  !self.graph_data.has_parent()
}

///|
fn LayerSweepTypeDecider::bottom_up_forced(
  self : LayerSweepTypeDecider,
  boundary : Double,
) -> Bool {
  ignore(self)
  boundary < -1.0
}

///|
fn LayerSweepTypeDecider::has_no_eastern_ports(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  let east_ports = node.get_port_side_view(@core.PortSide::East)
  if east_ports.is_empty() {
    return true
  }
  for port in east_ports {
    if !port.get_connected_edges().is_empty() {
      return false
    }
  }
  true
}

///|
fn LayerSweepTypeDecider::has_no_western_ports(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  let west_ports = node.get_port_side_view(@core.PortSide::West)
  if west_ports.is_empty() {
    return true
  }
  for port in west_ports {
    if !port.get_connected_edges().is_empty() {
      return false
    }
  }
  true
}

///|
fn LayerSweepTypeDecider::is_external_port_dummy(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_type() {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn LayerSweepTypeDecider::is_north_south_dummy(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_type() {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn LayerSweepTypeDecider::is_eastern_dummy(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_property_l_port(internal_properties_origin_l_port) {
    Some(origin_port) =>
      layer_sweep_type_decider_is_side(origin_port, @core.PortSide::East)
    None => {
      if node.get_ports().is_empty() {
        return false
      }
      let dummy_port = node.get_ports()[0]
      match dummy_port.get_property_l_port(internal_properties_origin_l_port) {
        Some(fallback_origin_port) =>
          layer_sweep_type_decider_is_side(fallback_origin_port, @core.PortSide::East)
        None => false
      }
    }
  }
}

///|
fn LayerSweepTypeDecider::node_info_for(
  self : LayerSweepTypeDecider,
  node : LNode,
) -> LayerSweepTypeDeciderNodeInfo {
  match node.get_layer() {
    Some(layer) => self.node_info[layer.get_id()][node.get_id()]
    None => abort("node has no layer")
  }
}

///|
pub fn LayerSweepTypeDecider::init_at_layer_level(
  self : LayerSweepTypeDecider,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  if !node_order[l].is_empty() {
    match node_order[l][0].get_layer() {
      Some(layer) => layer.set_id(l)
      None => ()
    }
  }
  let layer_info = []
  for _ in 0..<node_order[l].length() {
    layer_info.push(new_layer_sweep_type_decider_node_info())
  }
  self.node_info[l] = layer_info
}

///|
pub fn LayerSweepTypeDecider::init_at_node_level(
  self : LayerSweepTypeDecider,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  let node = node_order[l][n]
  node.set_id(n)
  self.node_info[l][n] = new_layer_sweep_type_decider_node_info()
}

///|
pub fn LayerSweepTypeDecider::as_initializable(
  self : LayerSweepTypeDecider,
) -> IInitializable {
  new_i_initializable(
    init_at_layer_level=(l, node_order) => {
      self.init_at_layer_level(l, node_order)
    },
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
  )
}
