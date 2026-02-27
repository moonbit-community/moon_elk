///|
priv struct NorthSouthTargetAndDegree {
  target : LPort
  degree : Int
}

///|
pub struct CrossingsCounter {
  port_positions : Array[Int]
  mut index_tree : BinaryIndexedTree?
  ends : Array[Int]
  mut node_cardinalities : Array[Int]
}

///|
pub fn new_crossings_counter(port_positions : Array[Int]) -> CrossingsCounter {
  { port_positions, index_tree: None, ends: [], node_cardinalities: [] }
}

///|
fn crossings_counter_pop_end(ends : Array[Int]) -> Int {
  ends.pop().unwrap()
}

///|
fn crossings_counter_tree(counter : CrossingsCounter) -> BinaryIndexedTree {
  counter.index_tree.unwrap()
}

///|
fn crossings_counter_reverse_ports(ports : Array[LPort]) -> Array[LPort] {
  let reversed = []
  let mut i = ports.length()
  while i > 0 {
    i = i - 1
    reversed.push(ports[i])
  }
  reversed
}

///|
fn crossings_counter_sort_ports_by_position(
  counter : CrossingsCounter,
  ports : Array[LPort],
) -> Unit {
  let length = ports.length()
  for i in 1..<length {
    let current = ports[i]
    let current_pos = counter.position_of(current)
    let mut j = i
    while j > 0 && counter.position_of(ports[j - 1]) > current_pos {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = current
  }
}

///|
fn crossings_counter_node_cardinality(
  counter : CrossingsCounter,
  node : LNode,
) -> Int {
  let node_id = node.get_id()
  if node_id >= 0 && node_id < counter.node_cardinalities.length() {
    counter.node_cardinalities[node_id]
  } else {
    0
  }
}

///|
fn crossings_counter_add_port_if_position_missing(
  counter : CrossingsCounter,
  ports : Array[LPort],
  port : LPort,
) -> Unit {
  let position = counter.position_of(port)
  for existing in ports {
    if counter.position_of(existing) == position {
      return
    }
  }
  ports.push(port)
}

///|
pub fn CrossingsCounter::count_crossings_between_layers(
  self : CrossingsCounter,
  left_layer_nodes : Array[LNode],
  right_layer_nodes : Array[LNode],
) -> Int {
  let ports = self.init_port_positions_counter_clockwise(
    left_layer_nodes, right_layer_nodes,
  )
  self.index_tree = Some(new_binary_indexed_tree(ports.length()))
  self.count_crossings_on_ports(ports)
}

///|
pub fn CrossingsCounter::count_in_layer_crossings_on_side(
  self : CrossingsCounter,
  nodes : Array[LNode],
  side : @core.PortSide,
) -> Int {
  let ports = self.init_port_positions_for_in_layer_crossings(nodes, side)
  self.count_in_layer_crossings_on_ports(ports)
}

///|
pub fn CrossingsCounter::count_north_south_port_crossings_in_layer(
  self : CrossingsCounter,
  layer : Array[LNode],
) -> Int {
  let ports = self.init_positions_for_north_south_counting(layer)
  self.index_tree = Some(new_binary_indexed_tree(ports.length()))
  self.count_north_south_crossings_on_ports(ports)
}

///|
pub fn CrossingsCounter::count_crossings_between_ports_in_both_orders(
  self : CrossingsCounter,
  upper_port : LPort,
  lower_port : LPort,
) -> @core.Pair[Int, Int] {
  let ports = self.connected_ports_sorted_by_position(upper_port, lower_port)
  let upper_lower_crossings = self.count_crossings_on_ports(ports)

  let tree = crossings_counter_tree(self)
  tree.clear()

  self.switch_ports(upper_port, lower_port)
  crossings_counter_sort_ports_by_position(self, ports)
  let lower_upper_crossings = self.count_crossings_on_ports(ports)

  tree.clear()
  self.switch_ports(lower_port, upper_port)

  @core.pair_of(upper_lower_crossings, lower_upper_crossings)
}

///|
pub fn CrossingsCounter::count_in_layer_crossings_between_nodes_in_both_orders(
  self : CrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
  side : @core.PortSide,
) -> @core.Pair[Int, Int] {
  let ports = self.connected_in_layer_ports_sorted_by_position(
    upper_node, lower_node, side,
  )
  let upper_lower_crossings = self.count_in_layer_crossings_on_ports(ports)

  self.switch_nodes(upper_node, lower_node, side)

  let tree = crossings_counter_tree(self)
  tree.clear()

  crossings_counter_sort_ports_by_position(self, ports)
  let lower_upper_crossings = self.count_in_layer_crossings_on_ports(ports)

  self.switch_nodes(lower_node, upper_node, side)
  tree.clear()

  @core.pair_of(upper_lower_crossings, lower_upper_crossings)
}

///|
pub fn CrossingsCounter::init_for_counting_between(
  self : CrossingsCounter,
  left_layer_nodes : Array[LNode],
  right_layer_nodes : Array[LNode],
) -> Unit {
  let ports = self.init_port_positions_counter_clockwise(
    left_layer_nodes, right_layer_nodes,
  )
  self.index_tree = Some(new_binary_indexed_tree(ports.length()))
}

///|
pub fn CrossingsCounter::init_port_positions_for_in_layer_crossings(
  self : CrossingsCounter,
  nodes : Array[LNode],
  side : @core.PortSide,
) -> Array[LPort] {
  let ports = []
  self.init_positions(nodes, ports, side, true, true)
  self.index_tree = Some(new_binary_indexed_tree(ports.length()))
  ports
}

///|
pub fn CrossingsCounter::switch_ports(
  self : CrossingsCounter,
  top_port : LPort,
  bottom_port : LPort,
) -> Unit {
  let top_port_pos = self.port_positions[top_port.get_id()]
  self.port_positions[top_port.get_id()] = self.port_positions[bottom_port.get_id()]
  self.port_positions[bottom_port.get_id()] = top_port_pos
}

///|
pub fn CrossingsCounter::switch_nodes(
  self : CrossingsCounter,
  was_upper_node : LNode,
  was_lower_node : LNode,
  side : @core.PortSide,
) -> Unit {
  let upper_delta = crossings_counter_node_cardinality(self, was_lower_node)
  for port in in_north_south_east_west_order(was_upper_node, side) {
    self.port_positions[port.get_id()] = self.position_of(port) + upper_delta
  }

  let lower_delta = crossings_counter_node_cardinality(self, was_upper_node)
  for port in in_north_south_east_west_order(was_lower_node, side) {
    self.port_positions[port.get_id()] = self.position_of(port) - lower_delta
  }
}

///|
fn CrossingsCounter::connected_in_layer_ports_sorted_by_position(
  self : CrossingsCounter,
  upper_node : LNode,
  lower_node : LNode,
  side : @core.PortSide,
) -> Array[LPort] {
  let ports = []

  for node in [upper_node, lower_node] {
    for port in in_north_south_east_west_order(node, side) {
      for edge in port.get_connected_edges() {
        if !edge.is_self_loop() {
          crossings_counter_add_port_if_position_missing(self, ports, port)
          if self.is_in_layer(edge) {
            crossings_counter_add_port_if_position_missing(
              self,
              ports,
              self.other_end_of(edge, port),
            )
          }
        }
      }
    }
  }

  crossings_counter_sort_ports_by_position(self, ports)
  ports
}

///|
fn CrossingsCounter::connected_ports_sorted_by_position(
  self : CrossingsCounter,
  upper_port : LPort,
  lower_port : LPort,
) -> Array[LPort] {
  let ports = []

  for port in [upper_port, lower_port] {
    crossings_counter_add_port_if_position_missing(self, ports, port)
    for edge in port.get_connected_edges() {
      if !self.is_port_self_loop(edge) {
        crossings_counter_add_port_if_position_missing(
          self,
          ports,
          self.other_end_of(edge, port),
        )
      }
    }
  }

  crossings_counter_sort_ports_by_position(self, ports)
  ports
}

///|
fn CrossingsCounter::count_crossings_on_ports(
  self : CrossingsCounter,
  ports : Array[LPort],
) -> Int {
  let tree = crossings_counter_tree(self)
  let mut crossings = 0

  for port in ports {
    tree.remove_all(self.position_of(port))

    for edge in port.get_connected_edges() {
      let other_port = self.other_end_of(edge, port)
      let end_position = self.position_of(other_port)
      if end_position > self.position_of(port) {
        crossings = crossings + tree.rank(end_position)
        self.ends.push(end_position)
      }
    }

    while !self.ends.is_empty() {
      let end_position = crossings_counter_pop_end(self.ends)
      tree.add(end_position)
    }
  }

  crossings
}

///|
fn CrossingsCounter::count_in_layer_crossings_on_ports(
  self : CrossingsCounter,
  ports : Array[LPort],
) -> Int {
  let tree = crossings_counter_tree(self)
  let mut crossings = 0

  for port in ports {
    tree.remove_all(self.position_of(port))
    let mut num_between_layer_edges = 0

    for edge in port.get_connected_edges() {
      if self.is_in_layer(edge) {
        let end_position = self.position_of(self.other_end_of(edge, port))
        if end_position > self.position_of(port) {
          crossings = crossings + tree.rank(end_position)
          self.ends.push(end_position)
        }
      } else {
        num_between_layer_edges = num_between_layer_edges + 1
      }
    }

    crossings = crossings + tree.size() * num_between_layer_edges

    while !self.ends.is_empty() {
      tree.add(crossings_counter_pop_end(self.ends))
    }
  }

  crossings
}

///|
fn CrossingsCounter::count_north_south_crossings_on_ports(
  self : CrossingsCounter,
  ports : Array[LPort],
) -> Int {
  let tree = crossings_counter_tree(self)
  let mut crossings = 0

  for port in ports {
    tree.remove_all(self.position_of(port))
    let targets_and_degrees = []

    match port.get_node() {
      Some(node) =>
        match node.get_type() {
          NodeType::Normal => {
            let dummy = port
              .get_property_l_node(internal_properties_port_dummy)
              .unwrap()
            for p in dummy.get_ports() {
              targets_and_degrees.push({ target: p, degree: p.get_degree() })
            }
          }
          NodeType::LongEdge => {
            let mut other_port : LPort? = None
            for p in node.get_ports() {
              if lport_internal_handle(p) != lport_internal_handle(port) {
                other_port = Some(p)
                break
              }
            }
            match other_port {
              Some(p) =>
                targets_and_degrees.push({ target: p, degree: p.get_degree() })
              None => ()
            }
          }
          NodeType::NorthSouthPort =>
            match port.get_property_l_port(internal_properties_origin_l_port) {
              Some(dummy_port) =>
                targets_and_degrees.push({
                  target: dummy_port,
                  degree: port.get_degree(),
                })
              None => ()
            }
          _ => ()
        }
      None => ()
    }

    for target_and_degree in targets_and_degrees {
      let end_position = self.position_of(target_and_degree.target)
      if end_position > self.position_of(port) {
        crossings = crossings +
          tree.rank(end_position) * target_and_degree.degree
        self.ends.push(end_position)
      }
    }

    while !self.ends.is_empty() {
      tree.add(crossings_counter_pop_end(self.ends))
    }
  }

  crossings
}

///|
fn CrossingsCounter::init_positions(
  self : CrossingsCounter,
  nodes : Array[LNode],
  ports : Array[LPort],
  side : @core.PortSide,
  top_down : Bool,
  get_cardinalities : Bool,
) -> Unit {
  let mut num_ports = ports.length()

  if get_cardinalities {
    self.node_cardinalities = Array::make(nodes.length(), 0)
  }

  let mut i = self.start(nodes, top_down)
  while self.end(i, top_down, nodes) {
    let node = nodes[i]
    let node_ports = self.get_ports(node, side, top_down)

    if get_cardinalities {
      let node_id = node.get_id()
      if node_id >= 0 && node_id < self.node_cardinalities.length() {
        self.node_cardinalities[node_id] = node_ports.length()
      }
    }

    for port in node_ports {
      self.port_positions[port.get_id()] = num_ports
      num_ports = num_ports + 1
    }

    for port in node_ports {
      ports.push(port)
    }

    i = i + self.step(top_down)
  }
}

///|
fn CrossingsCounter::init_port_positions_counter_clockwise(
  self : CrossingsCounter,
  left_layer_nodes : Array[LNode],
  right_layer_nodes : Array[LNode],
) -> Array[LPort] {
  let ports = []
  self.init_positions(
    left_layer_nodes,
    ports,
    @core.PortSide::East,
    true,
    false,
  )
  self.init_positions(
    right_layer_nodes,
    ports,
    @core.PortSide::West,
    false,
    false,
  )
  ports
}

///|
fn CrossingsCounter::init_positions_for_north_south_counting(
  self : CrossingsCounter,
  nodes : Array[LNode],
) -> Array[LPort] {
  let ports = []
  let stack = []

  let mut last_layout_unit : LNode? = None
  let mut index = 0

  for current in nodes {
    if self.is_layout_unit_changed(last_layout_unit, current) {
      index = self.empty_stack(stack, ports, @core.PortSide::East, index)
    }

    if current.has_property_l_node(internal_properties_in_layer_layout_unit) {
      last_layout_unit = current.get_property_l_node(
        internal_properties_in_layer_layout_unit,
      )
    }

    match current.get_type() {
      NodeType::Normal => {
        for
          p in self.get_north_south_ports_with_incident_edges(
            current,
            @core.PortSide::North,
          ) {
          self.port_positions[p.get_id()] = index
          index = index + 1
          ports.push(p)
        }

        index = self.empty_stack(stack, ports, @core.PortSide::East, index)

        for
          p in self.get_north_south_ports_with_incident_edges(
            current,
            @core.PortSide::South,
          ) {
          self.port_positions[p.get_id()] = index
          index = index + 1
          ports.push(p)
        }
      }
      NodeType::NorthSouthPort => {
        let indexing_ports = current.get_port_side_view(@core.PortSide::West)
        if !indexing_ports.is_empty() {
          let p = indexing_ports[0]
          self.port_positions[p.get_id()] = index
          index = index + 1
          ports.push(p)
        }

        let stack_ports = current.get_port_side_view(@core.PortSide::East)
        if !stack_ports.is_empty() {
          stack.push(current)
        }
      }
      NodeType::LongEdge => {
        for p in current.get_port_side_view(@core.PortSide::West) {
          self.port_positions[p.get_id()] = index
          index = index + 1
          ports.push(p)
        }

        for _ in current.get_port_side_view(@core.PortSide::East) {
          stack.push(current)
        }
      }
      _ => ()
    }
  }

  ignore(self.empty_stack(stack, ports, @core.PortSide::East, index))

  ports
}

///|
fn CrossingsCounter::empty_stack(
  self : CrossingsCounter,
  stack : Array[LNode],
  ports : Array[LPort],
  side : @core.PortSide,
  start_index : Int,
) -> Int {
  let mut index = start_index

  while !stack.is_empty() {
    let dummy = stack.pop().unwrap()
    let dummy_ports = dummy.get_port_side_view(side)
    if !dummy_ports.is_empty() {
      let p = dummy_ports[0]
      self.port_positions[p.get_id()] = index
      index = index + 1
      ports.push(p)
    }
  }

  index
}

///|
fn CrossingsCounter::get_ports(
  _self : CrossingsCounter,
  node : LNode,
  side : @core.PortSide,
  top_down : Bool,
) -> Array[LPort] {
  let ports = node.get_port_side_view(side)
  match side {
    @core.PortSide::East =>
      if top_down {
        ports
      } else {
        crossings_counter_reverse_ports(ports)
      }
    _ => if top_down { crossings_counter_reverse_ports(ports) } else { ports }
  }
}

///|
fn CrossingsCounter::get_north_south_ports_with_incident_edges(
  _self : CrossingsCounter,
  node : LNode,
  side : @core.PortSide,
) -> Array[LPort] {
  let result = []
  for port in node.get_port_side_view(side) {
    if port.has_property_l_node(internal_properties_port_dummy) {
      result.push(port)
    }
  }
  result
}

///|
fn CrossingsCounter::start(
  _self : CrossingsCounter,
  nodes : Array[LNode],
  top_down : Bool,
) -> Int {
  if top_down {
    0
  } else {
    nodes.length() - 1
  }
}

///|
fn CrossingsCounter::end(
  _self : CrossingsCounter,
  i : Int,
  top_down : Bool,
  nodes : Array[LNode],
) -> Bool {
  if top_down {
    i < nodes.length()
  } else {
    i >= 0
  }
}

///|
fn CrossingsCounter::step(_self : CrossingsCounter, top_down : Bool) -> Int {
  if top_down {
    1
  } else {
    -1
  }
}

///|
fn CrossingsCounter::is_in_layer(
  _self : CrossingsCounter,
  edge : LEdge,
) -> Bool {
  let source_layer = match edge.get_source() {
    Some(source_port) =>
      match source_port.get_node() {
        Some(source_node) => source_node.get_layer()
        None => None
      }
    None => None
  }

  let target_layer = match edge.get_target() {
    Some(target_port) =>
      match target_port.get_node() {
        Some(target_node) => target_node.get_layer()
        None => None
      }
    None => None
  }

  match (source_layer, target_layer) {
    (Some(source), Some(target)) =>
      layer_internal_handle(source) == layer_internal_handle(target)
    _ => false
  }
}

///|
fn CrossingsCounter::position_of(self : CrossingsCounter, port : LPort) -> Int {
  self.port_positions[port.get_id()]
}

///|
fn CrossingsCounter::other_end_of(
  _self : CrossingsCounter,
  edge : LEdge,
  from_port : LPort,
) -> LPort {
  let source = edge.get_source().unwrap()
  let target = edge.get_target().unwrap()
  if lport_internal_handle(from_port) == lport_internal_handle(source) {
    target
  } else {
    source
  }
}

///|
fn CrossingsCounter::is_port_self_loop(
  _self : CrossingsCounter,
  edge : LEdge,
) -> Bool {
  match (edge.get_source(), edge.get_target()) {
    (Some(source), Some(target)) =>
      lport_internal_handle(source) == lport_internal_handle(target)
    _ => false
  }
}

///|
fn CrossingsCounter::is_layout_unit_changed(
  _self : CrossingsCounter,
  last_unit : LNode?,
  node : LNode,
) -> Bool {
  match last_unit {
    None => false
    Some(last_layout_unit) => {
      if lnode_internal_handle(last_layout_unit) == lnode_internal_handle(node) ||
        !node.has_property_l_node(internal_properties_in_layer_layout_unit) {
        return false
      }

      match node.get_property_l_node(internal_properties_in_layer_layout_unit) {
        Some(unit) =>
          lnode_internal_handle(unit) != lnode_internal_handle(last_layout_unit)
        None => false
      }
    }
  }
}
