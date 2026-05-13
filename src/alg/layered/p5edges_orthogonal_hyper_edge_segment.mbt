///|
let hyper_edge_segment_next_handle_ref : Ref[Int] = Ref(0)

///|
fn hyper_edge_segment_next_handle() -> Int {
  let handle = hyper_edge_segment_next_handle_ref.val
  hyper_edge_segment_next_handle_ref.val = handle + 1
  handle
}

///|
fn hyper_edge_segment_insert_sorted(
  list : Array[Double],
  value : Double,
) -> Unit {
  for i in 0..<list.length() {
    let next = list[i]
    if next == value {
      return
    } else if next > value {
      ignore(list.insert(i, value))
      return
    }
  }
  list.push(value)
}

///|
pub struct HyperEdgeSegment {
  segment_handle : Int
  routing_strategy : BaseRoutingDirectionStrategy
  ports : Array[LPort]
  mut mark : Int
  mut routing_slot : Int
  mut start_position : Double
  mut end_position : Double
  incoming_connection_coordinates : Array[Double]
  outgoing_connection_coordinates : Array[Double]
  outgoing_segment_dependencies : Array[HyperEdgeSegmentDependency]
  mut out_dep_weight : Int
  mut critical_out_dep_weight : Int
  incoming_segment_dependencies : Array[HyperEdgeSegmentDependency]
  mut in_dep_weight : Int
  mut critical_in_dep_weight : Int
  mut split_partner : HyperEdgeSegment?
  mut split_by : HyperEdgeSegment?
}

///|
fn hyper_edge_segment_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
pub fn new_hyper_edge_segment(
  routing_strategy : BaseRoutingDirectionStrategy,
) -> HyperEdgeSegment {
  {
    segment_handle: hyper_edge_segment_next_handle(),
    routing_strategy,
    ports: [],
    mark: 0,
    routing_slot: 0,
    start_position: 0.0,
    end_position: 0.0,
    incoming_connection_coordinates: [],
    outgoing_connection_coordinates: [],
    outgoing_segment_dependencies: [],
    out_dep_weight: 0,
    critical_out_dep_weight: 0,
    incoming_segment_dependencies: [],
    in_dep_weight: 0,
    critical_in_dep_weight: 0,
    split_partner: None,
    split_by: None,
  }
}

///|
pub fn HyperEdgeSegment::add_port_positions(
  self : HyperEdgeSegment,
  port : LPort,
  hyper_edge_segment_map : Map[Int, HyperEdgeSegment],
) -> Unit {
  hyper_edge_segment_map[lport_internal_handle(port)] = self
  self.ports.push(port)

  let port_pos = self.routing_strategy.get_port_position_on_hyper_node(port)
  if hyper_edge_segment_port_side_equals(
      port.get_side(),
      self.routing_strategy.get_source_port_side(),
    ) {
    hyper_edge_segment_insert_sorted(
      self.incoming_connection_coordinates,
      port_pos,
    )
  } else {
    hyper_edge_segment_insert_sorted(
      self.outgoing_connection_coordinates,
      port_pos,
    )
  }

  self.recompute_extent()

  for other_port in port.get_connected_ports() {
    if !hyper_edge_segment_map.contains(lport_internal_handle(other_port)) {
      self.add_port_positions(other_port, hyper_edge_segment_map)
    }
  }
}

///|
pub fn HyperEdgeSegment::get_ports(self : HyperEdgeSegment) -> Array[LPort] {
  self.ports
}

///|
pub fn HyperEdgeSegment::get_handle(self : HyperEdgeSegment) -> Int {
  self.segment_handle
}

///|
pub fn HyperEdgeSegment::get_routing_slot(self : HyperEdgeSegment) -> Int {
  self.routing_slot
}

///|
pub fn HyperEdgeSegment::get_mark(self : HyperEdgeSegment) -> Int {
  self.mark
}

///|
pub fn HyperEdgeSegment::set_mark(self : HyperEdgeSegment, mark : Int) -> Unit {
  self.mark = mark
}

///|
pub fn HyperEdgeSegment::set_routing_slot(
  self : HyperEdgeSegment,
  slot : Int,
) -> Unit {
  self.routing_slot = slot
}

///|
pub fn HyperEdgeSegment::get_start_coordinate(
  self : HyperEdgeSegment,
) -> Double {
  self.start_position
}

///|
pub fn HyperEdgeSegment::get_end_coordinate(self : HyperEdgeSegment) -> Double {
  self.end_position
}

///|
pub fn HyperEdgeSegment::get_incoming_connection_coordinates(
  self : HyperEdgeSegment,
) -> Array[Double] {
  self.incoming_connection_coordinates
}

///|
pub fn HyperEdgeSegment::get_outgoing_connection_coordinates(
  self : HyperEdgeSegment,
) -> Array[Double] {
  self.outgoing_connection_coordinates
}

///|
pub fn HyperEdgeSegment::get_outgoing_segment_dependencies(
  self : HyperEdgeSegment,
) -> Array[HyperEdgeSegmentDependency] {
  self.outgoing_segment_dependencies
}

///|
pub fn HyperEdgeSegment::get_out_weight(self : HyperEdgeSegment) -> Int {
  self.out_dep_weight
}

///|
pub fn HyperEdgeSegment::set_out_weight(
  self : HyperEdgeSegment,
  out_weight : Int,
) -> Unit {
  self.out_dep_weight = out_weight
}

///|
pub fn HyperEdgeSegment::get_critical_out_weight(
  self : HyperEdgeSegment,
) -> Int {
  self.critical_out_dep_weight
}

///|
pub fn HyperEdgeSegment::set_critical_out_weight(
  self : HyperEdgeSegment,
  out_weight : Int,
) -> Unit {
  self.critical_out_dep_weight = out_weight
}

///|
pub fn HyperEdgeSegment::get_incoming_segment_dependencies(
  self : HyperEdgeSegment,
) -> Array[HyperEdgeSegmentDependency] {
  self.incoming_segment_dependencies
}

///|
pub fn HyperEdgeSegment::get_in_weight(self : HyperEdgeSegment) -> Int {
  self.in_dep_weight
}

///|
pub fn HyperEdgeSegment::set_in_weight(
  self : HyperEdgeSegment,
  in_weight : Int,
) -> Unit {
  self.in_dep_weight = in_weight
}

///|
pub fn HyperEdgeSegment::get_critical_in_weight(self : HyperEdgeSegment) -> Int {
  self.critical_in_dep_weight
}

///|
pub fn HyperEdgeSegment::set_critical_in_weight(
  self : HyperEdgeSegment,
  in_weight : Int,
) -> Unit {
  self.critical_in_dep_weight = in_weight
}

///|
pub fn HyperEdgeSegment::get_split_partner(
  self : HyperEdgeSegment,
) -> HyperEdgeSegment? {
  self.split_partner
}

///|
pub fn HyperEdgeSegment::set_split_partner(
  self : HyperEdgeSegment,
  split_partner : HyperEdgeSegment?,
) -> Unit {
  self.split_partner = split_partner
}

///|
pub fn HyperEdgeSegment::get_split_by(
  self : HyperEdgeSegment,
) -> HyperEdgeSegment? {
  self.split_by
}

///|
pub fn HyperEdgeSegment::set_split_by(
  self : HyperEdgeSegment,
  split_by : HyperEdgeSegment?,
) -> Unit {
  self.split_by = split_by
}

///|
pub fn HyperEdgeSegment::get_length(self : HyperEdgeSegment) -> Double {
  self.get_end_coordinate() - self.get_start_coordinate()
}

///|
pub fn HyperEdgeSegment::represents_hyperedge(self : HyperEdgeSegment) -> Bool {
  self.get_incoming_connection_coordinates().length() +
  self.get_outgoing_connection_coordinates().length() >
  2
}

///|
pub fn HyperEdgeSegment::is_dummy(self : HyperEdgeSegment) -> Bool {
  match (self.split_partner, self.split_by) {
    (Some(_), None) => true
    _ => false
  }
}

///|
pub fn HyperEdgeSegment::recompute_extent(self : HyperEdgeSegment) -> Unit {
  let mut has_extent = false
  let mut start_position = 0.0
  let mut end_position = 0.0

  if !self.incoming_connection_coordinates.is_empty() {
    let first = self.incoming_connection_coordinates[0]
    let last = self.incoming_connection_coordinates[self.incoming_connection_coordinates.length() -
      1]
    if !has_extent {
      has_extent = true
      start_position = first
      end_position = last
    } else {
      start_position = if first < start_position {
        first
      } else {
        start_position
      }
      end_position = if last > end_position { last } else { end_position }
    }
  }

  if !self.outgoing_connection_coordinates.is_empty() {
    let first = self.outgoing_connection_coordinates[0]
    let last = self.outgoing_connection_coordinates[self.outgoing_connection_coordinates.length() -
      1]
    if !has_extent {
      has_extent = true
      start_position = first
      end_position = last
    } else {
      start_position = if first < start_position {
        first
      } else {
        start_position
      }
      end_position = if last > end_position { last } else { end_position }
    }
  }

  self.start_position = start_position
  self.end_position = end_position
}

///|
pub fn HyperEdgeSegment::simulate_split(
  self : HyperEdgeSegment,
) -> @core.Pair[HyperEdgeSegment, HyperEdgeSegment] {
  let new_split = new_hyper_edge_segment(self.routing_strategy)
  let new_split_partner = new_hyper_edge_segment(self.routing_strategy)

  for value in self.incoming_connection_coordinates {
    new_split.incoming_connection_coordinates.push(value)
  }
  new_split.split_by = self.split_by
  new_split.split_partner = Some(new_split_partner)
  new_split.recompute_extent()

  for value in self.outgoing_connection_coordinates {
    new_split_partner.outgoing_connection_coordinates.push(value)
  }
  new_split_partner.split_partner = Some(new_split)
  new_split_partner.recompute_extent()

  @core.pair_of(new_split, new_split_partner)
}

///|
pub fn HyperEdgeSegment::split_at(
  self : HyperEdgeSegment,
  split_position : Double,
) -> HyperEdgeSegment {
  let split_partner = new_hyper_edge_segment(self.routing_strategy)
  self.split_partner = Some(split_partner)
  split_partner.set_split_partner(Some(self))

  for value in self.outgoing_connection_coordinates {
    split_partner.outgoing_connection_coordinates.push(value)
  }
  self.outgoing_connection_coordinates.clear()

  self.outgoing_connection_coordinates.push(split_position)
  split_partner.incoming_connection_coordinates.push(split_position)

  self.recompute_extent()
  split_partner.recompute_extent()

  while !self.incoming_segment_dependencies.is_empty() {
    self.incoming_segment_dependencies[0].remove()
  }

  while !self.outgoing_segment_dependencies.is_empty() {
    self.outgoing_segment_dependencies[0].remove()
  }

  split_partner
}

///|
pub fn HyperEdgeSegment::compare_to(
  self : HyperEdgeSegment,
  other : HyperEdgeSegment,
) -> Int {
  self.get_mark() - other.get_mark()
}

///|
pub fn HyperEdgeSegment::equals(
  self : HyperEdgeSegment,
  other : HyperEdgeSegment,
) -> Bool {
  self.get_mark() == other.get_mark()
}

///|
pub fn HyperEdgeSegment::hash_code(self : HyperEdgeSegment) -> Int {
  self.get_mark()
}

///|
pub fn HyperEdgeSegment::to_string(self : HyperEdgeSegment) -> String {
  let mut result = "{"
  for i in 0..<self.ports.length() {
    let port = self.ports[i]
    let node = port.get_node().unwrap()
    let name = match node.get_designation() {
      Some(node_name) => node_name
      None => "n" + node.get_id().to_string()
    }
    result = result + name
    if i + 1 < self.ports.length() {
      result = result + ","
    }
  }
  result + "}"
}
