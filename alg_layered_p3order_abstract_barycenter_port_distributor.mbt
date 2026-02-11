///|
fn abstract_barycenter_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  match value {
    "UNDEFINED" => PortConstraints::Undefined
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn abstract_barycenter_is_order_fixed(node : LNode) -> Bool {
  let port_constraints_value = if node.has_property_string(port_constraints) {
    node.get_property_string(port_constraints)
  } else {
    port_constraints.get_default()
  }
  abstract_barycenter_port_constraints_from_string(port_constraints_value).is_order_fixed()
}

///|
fn abstract_barycenter_side_ordinal(side : PortSide) -> Int {
  match side {
    PortSide::SideUndefined => 0
    PortSide::North => 1
    PortSide::East => 2
    PortSide::South => 3
    PortSide::West => 4
  }
}

///|
fn abstract_barycenter_same_layer(left : LNode, right : LNode) -> Bool {
  match (left.get_layer(), right.get_layer()) {
    (Some(left_layer), Some(right_layer)) =>
      layer_internal_handle(left_layer) == layer_internal_handle(right_layer)
    _ => false
  }
}

///|
fn abstract_barycenter_node_layer_id(node : LNode) -> Int {
  match node.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("node has no layer")
  }
}

///|
pub struct AbstractBarycenterPortDistributor {
  mut port_ranks : Array[Double]
  mut min_barycenter : Double
  mut max_barycenter : Double
  node_positions : Array[Array[Int]]
  mut port_barycenter : Array[Double]
  in_layer_ports : Array[LPort]
  mut n_ports : Int
  calculate_port_ranks_fn : (
    AbstractBarycenterPortDistributor,
    LNode,
    Double,
    PortType,
  ) -> Double
}

///|
pub fn new_abstract_barycenter_port_distributor(
  num_layers : Int,
  calculate_port_ranks : (
    AbstractBarycenterPortDistributor,
    LNode,
    Double,
    PortType,
  ) -> Double,
) -> AbstractBarycenterPortDistributor {
  let node_positions = []
  for _ in 0..<num_layers {
    node_positions.push([])
  }
  {
    port_ranks: [],
    min_barycenter: 0.0,
    max_barycenter: 0.0,
    node_positions,
    port_barycenter: [],
    in_layer_ports: [],
    n_ports: 0,
    calculate_port_ranks_fn: calculate_port_ranks,
  }
}

///|
pub fn AbstractBarycenterPortDistributor::get_port_ranks(
  self : AbstractBarycenterPortDistributor,
) -> Array[Double] {
  self.port_ranks
}

///|
pub fn AbstractBarycenterPortDistributor::distribute_ports_while_sweeping(
  self : AbstractBarycenterPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  self.update_node_positions(node_order, current_index)
  let free_layer = node_order[current_index]
  let side = if is_forward_sweep { PortSide::West } else { PortSide::East }

  if self.is_not_first_layer(
      node_order.length(),
      current_index,
      is_forward_sweep,
    ) {
    let fixed_layer = node_order[if is_forward_sweep {
        current_index - 1
      } else {
        current_index + 1
      }]

    self.calculate_port_ranks(fixed_layer, self.port_type_for(is_forward_sweep))
    for node in free_layer {
      self.distribute_ports(node, side)
    }

    self.calculate_port_ranks(free_layer, self.port_type_for(!is_forward_sweep))
    for node in fixed_layer {
      if !self.has_nested_graph(node) {
        self.distribute_ports(node, side.opposed())
      }
    }
  } else {
    for node in free_layer {
      self.distribute_ports(node, side)
    }
  }

  // Barycenter-based port distribution does not report guaranteed improvements.
  false
}

///|
pub fn AbstractBarycenterPortDistributor::calculate_port_ranks(
  self : AbstractBarycenterPortDistributor,
  layer : Array[LNode],
  port_type : PortType,
) -> Unit {
  let mut consumed_rank = 0.0
  for node in layer {
    consumed_rank += self.calculate_port_ranks_on_node(
      node, consumed_rank, port_type,
    )
  }
}

///|
pub fn AbstractBarycenterPortDistributor::calculate_port_ranks_on_node(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
  rank_sum : Double,
  port_type : PortType,
) -> Double {
  (self.calculate_port_ranks_fn)(self, node, rank_sum, port_type)
}

///|
fn AbstractBarycenterPortDistributor::distribute_ports(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
  side : PortSide,
) -> Unit {
  if !abstract_barycenter_is_order_fixed(node) {
    self.distribute_ports_for_iterable(node, node.get_ports_by_side(side))
    self.distribute_ports_for_iterable(
      node,
      node.get_ports_by_side(PortSide::South),
    )
    self.distribute_ports_for_iterable(
      node,
      node.get_ports_by_side(PortSide::North),
    )
    self.sort_ports(node)
  }
}

///|
fn AbstractBarycenterPortDistributor::distribute_ports_for_iterable(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
  ports : Array[LPort],
) -> Unit {
  self.in_layer_ports.clear()
  self.iterate_ports_and_collect_in_layer_ports(node, ports)
  if !self.in_layer_ports.is_empty() {
    self.calculate_in_layer_ports_barycenter_values(node)
  }
}

///|
fn AbstractBarycenterPortDistributor::iterate_ports_and_collect_in_layer_ports(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
  ports : Array[LPort],
) -> Unit {
  self.min_barycenter = 0.0
  self.max_barycenter = 0.0

  let layer = match node.get_layer() {
    Some(layer) => layer
    None => abort("node has no layer")
  }
  let absurdly_large_float = (2 * layer.get_nodes().length() + 1).to_double()

  for port in ports {
    let north_south_port = match port.get_side() {
      PortSide::North => true
      PortSide::South => true
      _ => false
    }
    let mut sum = 0.0

    if north_south_port {
      match port.get_property_l_node(internal_properties_port_dummy) {
        Some(port_dummy) =>
          sum += self.deal_with_north_south_ports(
            absurdly_large_float, port, port_dummy,
          )
        None => continue
      }
    } else {
      let mut has_in_layer_connection = false
      for outgoing_edge in port.get_outgoing_edges() {
        match outgoing_edge.get_target() {
          Some(connected_port) =>
            match connected_port.get_node() {
              Some(connected_node) =>
                if abstract_barycenter_same_layer(connected_node, node) {
                  self.in_layer_ports.push(port)
                  has_in_layer_connection = true
                  break
                } else {
                  sum += self.port_ranks[connected_port.get_id()]
                }
              None => ()
            }
          None => ()
        }
      }
      if has_in_layer_connection {
        continue
      }

      for incoming_edge in port.get_incoming_edges() {
        match incoming_edge.get_source() {
          Some(connected_port) =>
            match connected_port.get_node() {
              Some(connected_node) =>
                if abstract_barycenter_same_layer(connected_node, node) {
                  self.in_layer_ports.push(port)
                  has_in_layer_connection = true
                  break
                } else {
                  sum -= self.port_ranks[connected_port.get_id()]
                }
              None => ()
            }
          None => ()
        }
      }
      if has_in_layer_connection {
        continue
      }
    }

    if port.get_degree() > 0 {
      let barycenter = sum / port.get_degree().to_double()
      self.port_barycenter[port.get_id()] = barycenter
      self.min_barycenter = @math.minimum(self.min_barycenter, barycenter)
      self.max_barycenter = @math.maximum(self.max_barycenter, barycenter)
    } else if north_south_port {
      self.port_barycenter[port.get_id()] = sum
    }
  }
}

///|
fn AbstractBarycenterPortDistributor::calculate_in_layer_ports_barycenter_values(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
) -> Unit {
  let node_index_in_layer = self.position_of(node) + 1
  let layer_size = match node.get_layer() {
    Some(layer) => layer.get_nodes().length() + 1
    None => abort("node has no layer")
  }

  for in_layer_port in self.in_layer_ports {
    let mut sum = 0
    let mut in_layer_connections = 0
    for connected_port in in_layer_port.get_connected_ports() {
      match connected_port.get_node() {
        Some(connected_node) =>
          if abstract_barycenter_same_layer(connected_node, node) {
            sum += self.position_of(connected_node) + 1
            in_layer_connections = in_layer_connections + 1
          }
        None => ()
      }
    }
    if in_layer_connections == 0 {
      continue
    }

    let barycenter = sum.to_double() / in_layer_connections.to_double()
    let node_index_double = node_index_in_layer.to_double()
    let layer_size_double = layer_size.to_double()

    match in_layer_port.get_side() {
      PortSide::East =>
        if barycenter < node_index_double {
          self.port_barycenter[in_layer_port.get_id()] = self.min_barycenter -
            barycenter
        } else {
          self.port_barycenter[in_layer_port.get_id()] = self.max_barycenter +
            (layer_size_double - barycenter)
        }
      PortSide::West =>
        if barycenter < node_index_double {
          self.port_barycenter[in_layer_port.get_id()] = self.max_barycenter +
            barycenter
        } else {
          self.port_barycenter[in_layer_port.get_id()] = self.min_barycenter -
            (layer_size_double - barycenter)
        }
      _ => ()
    }
  }
}

///|
fn AbstractBarycenterPortDistributor::deal_with_north_south_ports(
  self : AbstractBarycenterPortDistributor,
  absurdly_large_float : Double,
  port : LPort,
  port_dummy : LNode,
) -> Double {
  let mut input = false
  let mut output = false

  for port_dummy_port in port_dummy.get_ports() {
    match
      port_dummy_port.get_property_l_port(internal_properties_origin_l_port) {
      Some(origin_port) =>
        if origin_port.get_handle() == port.get_handle() {
          if !port_dummy_port.get_outgoing_edges().is_empty() {
            output = true
          } else if !port_dummy_port.get_incoming_edges().is_empty() {
            input = true
          }
        }
      None => ()
    }
  }

  if input && input != output {
    if lnode_port_side_equals(port.get_side(), PortSide::North) {
      -self.position_of(port_dummy).to_double()
    } else {
      absurdly_large_float - self.position_of(port_dummy).to_double()
    }
  } else if output && input != output {
    self.position_of(port_dummy).to_double() + 1.0
  } else if input && output {
    if lnode_port_side_equals(port.get_side(), PortSide::North) {
      0.0
    } else {
      absurdly_large_float / 2.0
    }
  } else {
    0.0
  }
}

///|
fn AbstractBarycenterPortDistributor::position_of(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
) -> Int {
  let layer_id = abstract_barycenter_node_layer_id(node)
  self.node_positions[layer_id][node.get_id()]
}

///|
fn AbstractBarycenterPortDistributor::update_node_positions(
  self : AbstractBarycenterPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
) -> Unit {
  let layer = node_order[current_index]
  for i in 0..<layer.length() {
    let node = layer[i]
    let layer_id = abstract_barycenter_node_layer_id(node)
    self.node_positions[layer_id][node.get_id()] = i
  }
}

///|
fn AbstractBarycenterPortDistributor::has_nested_graph(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
) -> Bool {
  ignore(self)
  match node.get_nested_graph() {
    Some(_) => true
    None => false
  }
}

///|
fn AbstractBarycenterPortDistributor::is_not_first_layer(
  self : AbstractBarycenterPortDistributor,
  length : Int,
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  ignore(self)
  if is_forward_sweep {
    current_index != 0
  } else {
    current_index != length - 1
  }
}

///|
fn AbstractBarycenterPortDistributor::port_type_for(
  self : AbstractBarycenterPortDistributor,
  is_forward_sweep : Bool,
) -> PortType {
  ignore(self)
  if is_forward_sweep {
    PortType::Output
  } else {
    PortType::Input
  }
}

///|
fn AbstractBarycenterPortDistributor::sort_ports(
  self : AbstractBarycenterPortDistributor,
  node : LNode,
) -> Unit {
  let ports = node.get_ports()
  let mut i = 1
  while i < ports.length() {
    let port = ports[i]
    let mut j = i
    while j > 0 && self.compare_ports(port, ports[j - 1]) < 0 {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = port
    i = i + 1
  }
}

///|
fn AbstractBarycenterPortDistributor::compare_ports(
  self : AbstractBarycenterPortDistributor,
  port1 : LPort,
  port2 : LPort,
) -> Int {
  let side1 = port1.get_side()
  let side2 = port2.get_side()
  if !lnode_port_side_equals(side1, side2) {
    return abstract_barycenter_side_ordinal(side1) -
      abstract_barycenter_side_ordinal(side2)
  }

  let port1_bary = self.port_barycenter[port1.get_id()]
  let port2_bary = self.port_barycenter[port2.get_id()]
  if port1_bary == 0.0 && port2_bary == 0.0 {
    0
  } else if port1_bary == 0.0 {
    -1
  } else if port2_bary == 0.0 {
    1
  } else if port1_bary < port2_bary {
    -1
  } else if port1_bary > port2_bary {
    1
  } else {
    0
  }
}

///|
pub fn AbstractBarycenterPortDistributor::init_at_layer_level(
  self : AbstractBarycenterPortDistributor,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.node_positions[l] = Array::make(node_order[l].length(), 0)
}

///|
pub fn AbstractBarycenterPortDistributor::init_at_node_level(
  self : AbstractBarycenterPortDistributor,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  let node = node_order[l][n]
  node.set_id(n)
  self.node_positions[l][n] = n
}

///|
pub fn AbstractBarycenterPortDistributor::init_at_port_level(
  self : AbstractBarycenterPortDistributor,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  node_order[l][n].get_ports()[p].set_id(self.n_ports)
  self.n_ports = self.n_ports + 1
}

///|
pub fn AbstractBarycenterPortDistributor::init_after_traversal(
  self : AbstractBarycenterPortDistributor,
) -> Unit {
  self.port_ranks = Array::make(self.n_ports, 0.0)
  self.port_barycenter = Array::make(self.n_ports, 0.0)
}

///|
pub fn AbstractBarycenterPortDistributor::as_i_sweep_port_distributor(
  self : AbstractBarycenterPortDistributor,
) -> ISweepPortDistributor {
  new_i_sweep_port_distributor(
    (order, free_layer_index, is_forward_sweep) => {
      self.distribute_ports_while_sweeping(
        order, free_layer_index, is_forward_sweep,
      )
    },
    init_at_layer_level=(l, node_order) => {
      self.init_at_layer_level(l, node_order)
    },
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
    init_at_port_level=(l, n, p, node_order) => {
      self.init_at_port_level(l, n, p, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}

///|
pub fn AbstractBarycenterPortDistributor::as_initializable(
  self : AbstractBarycenterPortDistributor,
) -> IInitializable {
  self.as_i_sweep_port_distributor().as_initializable()
}
