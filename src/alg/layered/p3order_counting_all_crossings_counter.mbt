///|
pub struct AllCrossingsCounter {
  mut crossing_counter : CrossingsCounter?
  has_hyper_edges_east_of_index : Array[Bool]
  mut hyperedge_crossings_counter : HyperedgeCrossingsCounter?
  in_layer_edge_counts : Array[Int]
  has_north_south_ports : Array[Bool]
  mut n_ports : Int
}

///|
pub fn new_all_crossings_counter(
  graph : Array[Array[LNode]],
) -> AllCrossingsCounter {
  {
    crossing_counter: None,
    has_hyper_edges_east_of_index: Array::make(graph.length(), false),
    hyperedge_crossings_counter: None,
    in_layer_edge_counts: Array::make(graph.length(), 0),
    has_north_south_ports: Array::make(graph.length(), false),
    n_ports: 0,
  }
}

///|
fn all_crossings_counter_crossings_counter(
  state : AllCrossingsCounter,
) -> CrossingsCounter {
  match state.crossing_counter {
    Some(counter) => counter
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "all crossings counter is not initialized",
      )
      new_crossings_counter([])
    }
  }
}

///|
fn all_crossings_counter_hyperedge_counter(
  state : AllCrossingsCounter,
) -> HyperedgeCrossingsCounter {
  match state.hyperedge_crossings_counter {
    Some(counter) => counter
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "all crossings counter is not initialized",
      )
      new_hyperedge_crossings_counter([], [], [])
    }
  }
}

///|
fn all_crossings_counter_is_north_south_port(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn all_crossings_counter_port_side_is(
  port : LPort,
  side : @core.PortSide,
) -> Bool {
  match (port.get_side(), side) {
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
pub fn AllCrossingsCounter::count_all_crossings(
  self : AllCrossingsCounter,
  current_order : Array[Array[LNode]],
) -> Int {
  if current_order.length() == 0 {
    return 0
  }

  let counter = all_crossings_counter_crossings_counter(self)

  let mut crossings = counter.count_in_layer_crossings_on_side(
    current_order[0],
    @core.PortSide::West,
  )
  crossings = crossings +
    counter.count_in_layer_crossings_on_side(
      current_order[current_order.length() - 1],
      @core.PortSide::East,
    )

  for layer_index in 0..<current_order.length() {
    crossings = crossings + self.count_crossings_at(layer_index, current_order)
  }

  crossings
}

///|
fn AllCrossingsCounter::count_crossings_at(
  self : AllCrossingsCounter,
  layer_index : Int,
  current_order : Array[Array[LNode]],
) -> Int {
  let counter = all_crossings_counter_crossings_counter(self)
  let mut total_crossings = 0
  let left_layer = current_order[layer_index]

  if layer_index < current_order.length() - 1 {
    let right_layer = current_order[layer_index + 1]

    if self.has_hyper_edges_east_of_index[layer_index] {
      let hyperedge_counter = all_crossings_counter_hyperedge_counter(self)
      total_crossings = hyperedge_counter.count_crossings(
        left_layer, right_layer,
      )
      total_crossings = total_crossings +
        counter.count_in_layer_crossings_on_side(
          left_layer,
          @core.PortSide::East,
        )
      total_crossings = total_crossings +
        counter.count_in_layer_crossings_on_side(
          right_layer,
          @core.PortSide::West,
        )
    } else {
      total_crossings = counter.count_crossings_between_layers(
        left_layer, right_layer,
      )
    }
  }

  if self.has_north_south_ports[layer_index] {
    total_crossings = total_crossings +
      counter.count_north_south_port_crossings_in_layer(left_layer)
  }

  total_crossings
}

///|
pub fn AllCrossingsCounter::init_at_node_level(
  self : AllCrossingsCounter,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(n)
  let node = node_order[l][n]
  if all_crossings_counter_is_north_south_port(node) {
    self.has_north_south_ports[l] = true
  }
}

///|
pub fn AllCrossingsCounter::init_at_port_level(
  self : AllCrossingsCounter,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  let port = node_order[l][n].get_ports()[p]
  port.set_id(self.n_ports)
  self.n_ports = self.n_ports + 1

  if port.get_outgoing_edges().length() + port.get_incoming_edges().length() > 1 {
    if all_crossings_counter_port_side_is(port, @core.PortSide::East) {
      self.has_hyper_edges_east_of_index[l] = true
    } else if all_crossings_counter_port_side_is(port, @core.PortSide::West) &&
      l > 0 {
      self.has_hyper_edges_east_of_index[l - 1] = true
    }
  }
}

///|
pub fn AllCrossingsCounter::init_at_edge_level(
  self : AllCrossingsCounter,
  l : Int,
  n : Int,
  p : Int,
  e : Int,
  edge : LEdge,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(e)
  let port = node_order[l][n].get_ports()[p]

  let is_source_port = match edge.get_source() {
    Some(source) => lport_internal_handle(source) == lport_internal_handle(port)
    None => false
  }

  if !is_source_port {
    return
  }

  let source_layer = match edge.get_source() {
    Some(source) =>
      match source.get_node() {
        Some(node) => node.get_layer()
        None => None
      }
    None => None
  }
  let target_layer = match edge.get_target() {
    Some(target) =>
      match target.get_node() {
        Some(node) => node.get_layer()
        None => None
      }
    None => None
  }

  match (source_layer, target_layer) {
    (Some(source), Some(target)) =>
      if layer_internal_handle(source) == layer_internal_handle(target) {
        self.in_layer_edge_counts[l] = self.in_layer_edge_counts[l] + 1
      }
    _ => ()
  }
}

///|
pub fn AllCrossingsCounter::init_after_traversal(
  self : AllCrossingsCounter,
) -> Unit {
  let port_pos = Array::make(self.n_ports, 0)
  self.hyperedge_crossings_counter = Some(
    new_hyperedge_crossings_counter(
      self.in_layer_edge_counts,
      self.has_north_south_ports,
      port_pos,
    ),
  )
  self.crossing_counter = Some(new_crossings_counter(port_pos))
}

///|
pub fn AllCrossingsCounter::as_initializable(
  self : AllCrossingsCounter,
) -> IInitializable {
  new_i_initializable(
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
    init_at_port_level=(l, n, p, node_order) => {
      self.init_at_port_level(l, n, p, node_order)
    },
    init_at_edge_level=(l, n, p, e, edge, node_order) => {
      self.init_at_edge_level(l, n, p, e, edge, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}
