///|
pub struct SelfHyperLoop {
  mut id : Int
  sl_holder : SelfLoopHolder
  sl_ports : Array[SelfLoopPort]
  sl_edges : Array[SelfLoopEdge]
  mut sl_labels : SelfHyperLoopLabels?
  mut self_loop_type : SelfLoopType?
  sl_ports_by_side : Map[Int, Array[SelfLoopPort]]
  mut leftmost_port : SelfLoopPort?
  mut rightmost_port : SelfLoopPort?
  occupied_port_sides : Array[PortSide]
  routing_slot : Array[Int]
}

///|
fn self_hyper_loop_port_side_index(side : PortSide) -> Int {
  match side {
    SideUndefined => 0
    North => 1
    East => 2
    South => 3
    West => 4
  }
}

///|
fn self_hyper_loop_add_unique_port(
  ports : Array[SelfLoopPort],
  sl_port : SelfLoopPort,
) -> Unit {
  for existing in ports {
    if lport_internal_handle(existing.get_l_port()) ==
      lport_internal_handle(sl_port.get_l_port()) {
      return
    }
  }
  ports.push(sl_port)
}

///|
fn self_hyper_loop_add_unique_side(
  sides : Array[PortSide],
  side : PortSide,
) -> Unit {
  for existing in sides {
    if self_hyper_loop_port_side_index(existing) ==
      self_hyper_loop_port_side_index(side) {
      return
    }
  }
  sides.push(side)
}

///|
fn self_hyper_loop_has_edge(
  sl_edges : Array[SelfLoopEdge],
  sl_edge : SelfLoopEdge,
) -> Bool {
  for existing in sl_edges {
    if ledge_internal_handle(existing.get_l_edge()) ==
      ledge_internal_handle(sl_edge.get_l_edge()) {
      return true
    }
  }
  false
}

///|
pub fn new_self_hyper_loop(sl_holder : SelfLoopHolder) -> SelfHyperLoop {
  {
    id: -1,
    sl_holder,
    sl_ports: [],
    sl_edges: [],
    sl_labels: None,
    self_loop_type: None,
    sl_ports_by_side: {},
    leftmost_port: None,
    rightmost_port: None,
    occupied_port_sides: [],
    routing_slot: [0, 0, 0, 0, 0],
  }
}

///|
pub fn SelfHyperLoop::get_id(self : SelfHyperLoop) -> Int {
  self.id
}

///|
pub fn SelfHyperLoop::set_id(self : SelfHyperLoop, id : Int) -> Unit {
  self.id = id
}

///|
pub fn SelfHyperLoop::compute_ports_per_side(self : SelfHyperLoop) -> Unit {
  self.sl_ports_by_side.clear()
  self.occupied_port_sides.clear()

  for sl_port in self.sl_ports {
    let port_side = sl_port.get_l_port().get_side()
    if self_hyper_loop_port_side_index(port_side) == 0 {
      abort("SelfHyperLoop ports must have a defined side")
    }

    let side_index = self_hyper_loop_port_side_index(port_side)
    match self.sl_ports_by_side.get(side_index) {
      Some(side_ports) => side_ports.push(sl_port)
      None => self.sl_ports_by_side[side_index] = [sl_port]
    }
    self_hyper_loop_add_unique_side(self.occupied_port_sides, port_side)
  }

  self.self_loop_type = self_loop_type_from_port_sides(self.occupied_port_sides)
}

///|
pub fn SelfHyperLoop::get_sl_holder(self : SelfHyperLoop) -> SelfLoopHolder {
  self.sl_holder
}

///|
pub fn SelfHyperLoop::add_self_loop_edge(
  self : SelfHyperLoop,
  sl_edge : SelfLoopEdge,
) -> Unit {
  if self_hyper_loop_has_edge(self.sl_edges, sl_edge) {
    return
  }

  self.sl_edges.push(sl_edge)
  sl_edge.set_sl_hyper_loop(self)

  let sl_source = sl_edge.get_sl_source()
  self_hyper_loop_add_unique_port(self.sl_ports, sl_source)

  let sl_target = sl_edge.get_sl_target()
  self_hyper_loop_add_unique_port(self.sl_ports, sl_target)

  let l_labels = sl_edge.get_l_edge().get_labels()
  if !l_labels.is_empty() {
    match self.sl_labels {
      Some(sl_labels) => sl_labels.add_l_labels(l_labels)
      None => {
        let sl_labels = new_self_hyper_loop_labels(self)
        sl_labels.add_l_labels(l_labels)
        self.sl_labels = Some(sl_labels)
      }
    }
  }
}

///|
pub fn SelfHyperLoop::get_sl_ports(self : SelfHyperLoop) -> Array[SelfLoopPort] {
  self.sl_ports
}

///|
pub fn SelfHyperLoop::get_sl_edges(self : SelfHyperLoop) -> Array[SelfLoopEdge] {
  self.sl_edges
}

///|
pub fn SelfHyperLoop::get_sl_labels(
  self : SelfHyperLoop,
) -> SelfHyperLoopLabels? {
  self.sl_labels
}

///|
pub fn SelfHyperLoop::get_self_loop_type(self : SelfHyperLoop) -> SelfLoopType? {
  self.self_loop_type
}

///|
pub fn SelfHyperLoop::get_sl_ports_by_side_map(
  self : SelfHyperLoop,
) -> Map[Int, Array[SelfLoopPort]] {
  self.sl_ports_by_side
}

///|
pub fn SelfHyperLoop::get_sl_ports_by_side(
  self : SelfHyperLoop,
  port_side : PortSide,
) -> Array[SelfLoopPort] {
  let side_index = self_hyper_loop_port_side_index(port_side)
  match self.sl_ports_by_side.get(side_index) {
    Some(ports) => ports
    None => []
  }
}

///|
pub fn SelfHyperLoop::has_sl_ports_on_side(
  self : SelfHyperLoop,
  port_side : PortSide,
) -> Bool {
  let side_index = self_hyper_loop_port_side_index(port_side)
  self.sl_ports_by_side.get(side_index).is_some()
}

///|
pub fn SelfHyperLoop::get_leftmost_port(self : SelfHyperLoop) -> SelfLoopPort? {
  self.leftmost_port
}

///|
pub fn SelfHyperLoop::set_leftmost_port(
  self : SelfHyperLoop,
  leftmost_port : SelfLoopPort?,
) -> Unit {
  self.leftmost_port = leftmost_port
}

///|
pub fn SelfHyperLoop::get_rightmost_port(self : SelfHyperLoop) -> SelfLoopPort? {
  self.rightmost_port
}

///|
pub fn SelfHyperLoop::set_rightmost_port(
  self : SelfHyperLoop,
  rightmost_port : SelfLoopPort?,
) -> Unit {
  self.rightmost_port = rightmost_port
}

///|
pub fn SelfHyperLoop::get_occupied_port_sides(
  self : SelfHyperLoop,
) -> Array[PortSide] {
  self.occupied_port_sides
}

///|
pub fn SelfHyperLoop::get_routing_slot(
  self : SelfHyperLoop,
  port_side : PortSide,
) -> Int {
  self.routing_slot[self_hyper_loop_port_side_index(port_side)]
}

///|
pub fn SelfHyperLoop::set_routing_slot(
  self : SelfHyperLoop,
  port_side : PortSide,
  slot : Int,
) -> Unit {
  let side_index = self_hyper_loop_port_side_index(port_side)
  self.routing_slot[side_index] = slot

  let slot_count = self.sl_holder.get_routing_slot_count()
  if slot_count[side_index] < slot + 1 {
    slot_count[side_index] = slot + 1
  }
}
