///|
fn sweep_copy_port_constraints_from_string(
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
fn sweep_copy_port_side_ordinal(side : @core.PortSide) -> Int {
  match side {
    @core.PortSide::SideUndefined => 0
    @core.PortSide::North => 1
    @core.PortSide::East => 2
    @core.PortSide::South => 3
    @core.PortSide::West => 4
  }
}

///|
fn sweep_copy_port_side_is(
  side : @core.PortSide,
  expected : @core.PortSide,
) -> Bool {
  sweep_copy_port_side_ordinal(side) == sweep_copy_port_side_ordinal(expected)
}

///|
fn sweep_copy_compare_doubles(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn sweep_copy_compare_ports(left : LPort, right : LPort) -> Int {
  let side_difference = sweep_copy_port_side_ordinal(left.get_side()) -
    sweep_copy_port_side_ordinal(right.get_side())
  if side_difference != 0 {
    return side_difference
  }

  let node = match left.get_node() {
    Some(node) => node
    None => return 0
  }
  let port_constraints_value = if node.has_property_string(
      @core.port_constraints,
    ) {
    node.get_property_string(@core.port_constraints)
  } else {
    @core.port_constraints.get_default()
  }
  let constraints = sweep_copy_port_constraints_from_string(
    port_constraints_value,
  )
  if !constraints.is_order_fixed() {
    return 0
  }

  match left.get_side() {
    @core.PortSide::North =>
      sweep_copy_compare_doubles(left.get_position().x, right.get_position().x)
    @core.PortSide::East =>
      sweep_copy_compare_doubles(left.get_position().y, right.get_position().y)
    @core.PortSide::South =>
      sweep_copy_compare_doubles(right.get_position().x, left.get_position().x)
    @core.PortSide::West =>
      sweep_copy_compare_doubles(right.get_position().y, left.get_position().y)
    @core.PortSide::SideUndefined => abort("Port side is undefined")
  }
}

///|
fn sweep_copy_sort_ports(ports : Array[LPort]) -> Unit {
  let mut i = 1
  while i < ports.length() {
    let current = ports[i]
    let mut j = i
    while j > 0 && sweep_copy_compare_ports(ports[j - 1], current) > 0 {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = current
    i = i + 1
  }
}

///|
fn sweep_copy_add_unique_node(nodes : Array[LNode], node : LNode) -> Unit {
  for candidate in nodes {
    if lnode_internal_handle(candidate) == lnode_internal_handle(node) {
      return
    }
  }
  nodes.push(node)
}

///|
fn sweep_copy_deep_copy_node_order(
  currently_best_node_order : Array[Array[LNode]]?,
) -> Array[Array[LNode]]? {
  match currently_best_node_order {
    Some(order) => {
      let result = []
      for layer in order {
        result.push(layer.copy())
      }
      Some(result)
    }
    None => None
  }
}

///|
pub struct SweepCopy {
  node_order : Array[Array[LNode]]
  port_orders : Array[Array[Array[LPort]]]
}

///|
pub fn new_sweep_copy(node_order_in : Array[Array[LNode]]) -> SweepCopy {
  let node_order = match sweep_copy_deep_copy_node_order(Some(node_order_in)) {
    Some(order) => order
    None => []
  }

  let port_orders = []
  for layer_nodes in node_order_in {
    let layer_port_orders = []
    for node in layer_nodes {
      layer_port_orders.push(node.get_ports().copy())
    }
    port_orders.push(layer_port_orders)
  }

  { node_order, port_orders }
}

///|
pub fn new_sweep_copy_from(sc : SweepCopy) -> SweepCopy {
  let node_order = match sweep_copy_deep_copy_node_order(Some(sc.node_order)) {
    Some(order) => order
    None => []
  }
  { node_order, port_orders: sc.port_orders.copy() }
}

///|
pub fn SweepCopy::nodes(self : SweepCopy) -> Array[Array[LNode]] {
  self.node_order
}

///|
pub fn SweepCopy::transfer_node_and_port_orders_to_graph(
  self : SweepCopy,
  l_graph : LGraph,
  set_port_constraints : Bool,
) -> Unit {
  let north_south_port_dummies = []
  let update_port_order = []

  let layers = l_graph.get_layers()
  for i in 0..<layers.length() {
    let nodes = layers[i].get_nodes()
    north_south_port_dummies.clear()

    for j in 0..<nodes.length() {
      let node = self.node_order[i][j]
      node.set_id(j)
      match node.get_type() {
        NodeType::NorthSouthPort => north_south_port_dummies.push(node)
        _ => ()
      }

      layers[i].get_nodes()[j] = node
      node.get_ports().clear()
      for port in self.port_orders[i][j] {
        node.get_ports().push(port)
      }

      if set_port_constraints {
        let current_constraints = if node.has_property_string(
            @core.port_constraints,
          ) {
          node.get_property_string(@core.port_constraints)
        } else {
          @core.port_constraints.get_default()
        }
        if !sweep_copy_port_constraints_from_string(current_constraints).is_order_fixed() {
          node.set_property_string(@core.port_constraints, "FIXED_ORDER")
        }
      }
    }

    for dummy in north_south_port_dummies {
      let origin = self.assert_correct_port_sides(dummy)
      sweep_copy_add_unique_node(update_port_order, origin)
      sweep_copy_add_unique_node(update_port_order, dummy)
    }
  }

  for node in update_port_order {
    sweep_copy_sort_ports(node.get_ports())
  }
}

///|
fn SweepCopy::assert_correct_port_sides(
  self : SweepCopy,
  dummy : LNode,
) -> LNode {
  ignore(self)
  match dummy.get_type() {
    NodeType::NorthSouthPort => ()
    _ => abort("dummy node must be a north-south port node")
  }

  let origin = match
    dummy.get_property_l_node(internal_properties_in_layer_layout_unit) {
    Some(origin) => origin
    None => abort("north-south dummy has no layout unit origin")
  }

  let dummy_ports = dummy.get_ports()
  if dummy_ports.is_empty() {
    return origin
  }
  let dummy_port = dummy_ports[0]
  let dummy_origin_port = dummy_port.get_property_l_port(
    internal_properties_origin_l_port,
  )

  for port in origin.get_ports() {
    let is_dummy_origin = match dummy_origin_port {
      Some(origin_port) =>
        lport_internal_handle(port) == lport_internal_handle(origin_port)
      None => false
    }
    if !is_dummy_origin {
      continue
    }

    if sweep_copy_port_side_is(port.get_side(), @core.PortSide::North) &&
      dummy.get_id() > origin.get_id() {
      port.set_side(@core.PortSide::South)
      if port.is_explicitly_supplied_port_anchor() {
        let port_height = port.get_size().y
        let anchor_y = port.get_anchor().y
        port.get_anchor().y = port_height - anchor_y
      }
    } else if sweep_copy_port_side_is(port.get_side(), @core.PortSide::South) &&
      origin.get_id() > dummy.get_id() {
      port.set_side(@core.PortSide::North)
      if port.is_explicitly_supplied_port_anchor() {
        let port_height = port.get_size().y
        let anchor_y = port.get_anchor().y
        port.get_anchor().y = -(port_height - anchor_y)
      }
    }
    break
  }

  origin
}
