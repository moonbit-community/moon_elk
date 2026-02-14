///|
fn routing_director_port_side_equals(left : PortSide, right : PortSide) -> Bool {
  match (left, right) {
    (SideUndefined, SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn routing_director_require_leftmost_port(sl_loop : SelfHyperLoop) -> SelfLoopPort {
  match sl_loop.get_leftmost_port() {
    Some(port) => port
    None => abort("self hyper loop has no leftmost port")
  }
}

///|
fn routing_director_require_rightmost_port(sl_loop : SelfHyperLoop) -> SelfLoopPort {
  match sl_loop.get_rightmost_port() {
    Some(port) => port
    None => abort("self hyper loop has no rightmost port")
  }
}

///|
fn routing_director_require_self_loop_type(sl_loop : SelfHyperLoop) -> SelfLoopType {
  match sl_loop.get_self_loop_type() {
    Some(self_loop_type) => self_loop_type
    None => abort("self hyper loop type not computed")
  }
}

///|
fn routing_director_sort_sl_ports_by_id(sl_ports : Array[SelfLoopPort]) -> Unit {
  let mut i = 1
  while i < sl_ports.length() {
    let mut j = i
    while j > 0 &&
      sl_ports[j - 1].get_l_port().get_id() > sl_ports[j].get_l_port().get_id() {
      let temp = sl_ports[j - 1]
      sl_ports[j - 1] = sl_ports[j]
      sl_ports[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
pub struct RoutingDirector {
  mut port_penalties : Array[Int]?
}

///|
pub fn new_routing_director() -> RoutingDirector {
  { port_penalties: None }
}

///|
fn RoutingDirector::assign_port_ids(self : RoutingDirector, l_ports : Array[LPort]) -> Unit {
  ignore(self)
  for i in 0..<l_ports.length() {
    l_ports[i].set_id(i)
  }
}

///|
fn RoutingDirector::sort_hyper_loop_port_lists(
  self : RoutingDirector,
  sl_holder : SelfLoopHolder,
) -> Unit {
  ignore(self)
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    routing_director_sort_sl_ports_by_id(sl_loop.get_sl_ports())
  }
}

///|
fn RoutingDirector::compute_occupied_port_sides(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  ignore(self)
  let occupied_sides = sl_loop.get_occupied_port_sides()
  occupied_sides.clear()

  let mut curr_side = routing_director_require_leftmost_port(sl_loop).get_l_port().get_side()
  let target_side = routing_director_require_rightmost_port(sl_loop).get_l_port().get_side()

  while !routing_director_port_side_equals(curr_side, target_side) {
    occupied_sides.push(curr_side)
    curr_side = curr_side.right()
  }
  occupied_sides.push(curr_side)
}

///|
fn RoutingDirector::assign_leftmost_rightmost_ports(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
  leftmost_side : PortSide,
  rightmost_side : PortSide,
) -> Unit {
  sl_loop.set_leftmost_port(Some(self.lowest_port_on_side(sl_loop, leftmost_side)))
  sl_loop.set_rightmost_port(Some(self.highest_port_on_side(sl_loop, rightmost_side)))
}

///|
fn RoutingDirector::lowest_port_on_side(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
  side : PortSide,
) -> SelfLoopPort {
  ignore(self)
  let side_ports = sl_loop.get_sl_ports_by_side(side)
  if side_ports.is_empty() {
    abort("missing side port")
  }
  let mut best = side_ports[0]
  for i in 1..<side_ports.length() {
    let curr = side_ports[i]
    if curr.get_l_port().get_id() < best.get_l_port().get_id() {
      best = curr
    }
  }
  best
}

///|
fn RoutingDirector::highest_port_on_side(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
  side : PortSide,
) -> SelfLoopPort {
  ignore(self)
  let side_ports = sl_loop.get_sl_ports_by_side(side)
  if side_ports.is_empty() {
    abort("missing side port")
  }
  let mut best = side_ports[0]
  for i in 1..<side_ports.length() {
    let curr = side_ports[i]
    if curr.get_l_port().get_id() > best.get_l_port().get_id() {
      best = curr
    }
  }
  best
}

///|
fn RoutingDirector::determine_one_side_loop_routes(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  let side = sl_loop.get_sl_ports()[0].get_l_port().get_side()
  self.assign_leftmost_rightmost_ports(sl_loop, side, side)
}

///|
fn RoutingDirector::determine_two_side_corner_loop_routes(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  let sides = port_restorer_sorted_two_side_loop_port_sides(sl_loop)
  if sides.length() != 2 {
    abort("two-side corner loop must occupy exactly two sides")
  }
  self.assign_leftmost_rightmost_ports(sl_loop, sides[0], sides[1])
}

///|
fn RoutingDirector::determine_two_side_opposing_loop_routes(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  let sides = []
  for side in [
    PortSide::North,
    PortSide::East,
    PortSide::South,
    PortSide::West,
  ] {
    if sl_loop.has_sl_ports_on_side(side) {
      sides.push(side)
    }
  }
  if sides.length() != 2 {
    abort("two-side opposing loop must occupy exactly two sides")
  }

  let option_1_leftmost = self.lowest_port_on_side(sl_loop, sides[0])
  let option_1_rightmost = self.highest_port_on_side(sl_loop, sides[1])
  let option_1_penalty = self.compute_edge_penalty(
    sl_loop.get_sl_holder(),
    option_1_leftmost,
    option_1_rightmost,
  )

  let option_2_leftmost = self.lowest_port_on_side(sl_loop, sides[1])
  let option_2_rightmost = self.highest_port_on_side(sl_loop, sides[0])
  let option_2_penalty = self.compute_edge_penalty(
    sl_loop.get_sl_holder(),
    option_2_leftmost,
    option_2_rightmost,
  )

  if option_1_penalty <= option_2_penalty {
    sl_loop.set_leftmost_port(Some(option_1_leftmost))
    sl_loop.set_rightmost_port(Some(option_1_rightmost))
  } else {
    sl_loop.set_leftmost_port(Some(option_2_leftmost))
    sl_loop.set_rightmost_port(Some(option_2_rightmost))
  }
}

///|
fn RoutingDirector::compute_missing_port_side(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> PortSide {
  ignore(self)
  for side in [
    PortSide::North,
    PortSide::East,
    PortSide::South,
    PortSide::West,
  ] {
    if !sl_loop.has_sl_ports_on_side(side) {
      return side
    }
  }
  abort("missing side not found")
}

///|
fn RoutingDirector::determine_three_side_loop_routes(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  let mut leftmost_side = SideUndefined
  let mut rightmost_side = SideUndefined

  match self.compute_missing_port_side(sl_loop) {
    PortSide::North => {
      leftmost_side = PortSide::East
      rightmost_side = PortSide::West
    }
    PortSide::East => {
      leftmost_side = PortSide::South
      rightmost_side = PortSide::North
    }
    PortSide::South => {
      leftmost_side = PortSide::West
      rightmost_side = PortSide::East
    }
    PortSide::West => {
      leftmost_side = PortSide::North
      rightmost_side = PortSide::South
    }
    PortSide::SideUndefined => abort("invalid missing side")
  }

  self.assign_leftmost_rightmost_ports(sl_loop, leftmost_side, rightmost_side)
}

///|
fn RoutingDirector::determine_four_side_loop_routes(
  self : RoutingDirector,
  sl_loop : SelfHyperLoop,
) -> Unit {
  let sorted_ports = sl_loop.get_sl_ports()
  if sorted_ports.is_empty() {
    return
  }

  let mut worst_left_port = sorted_ports[sorted_ports.length() - 1]
  let mut worst_right_port = sorted_ports[0]
  let mut worst_penalty = self.compute_edge_penalty(
    sl_loop.get_sl_holder(),
    worst_left_port,
    worst_right_port,
  )

  for right_port_index in 1..<sorted_ports.length() {
    let curr_left_port = sorted_ports[right_port_index - 1]
    let curr_right_port = sorted_ports[right_port_index]
    let curr_penalty = self.compute_edge_penalty(
      sl_loop.get_sl_holder(),
      curr_left_port,
      curr_right_port,
    )

    if curr_penalty > worst_penalty {
      worst_left_port = curr_left_port
      worst_right_port = curr_right_port
      worst_penalty = curr_penalty
    }
  }

  sl_loop.set_leftmost_port(Some(worst_right_port))
  sl_loop.set_rightmost_port(Some(worst_left_port))
}

///|
fn RoutingDirector::compute_penalties(self : RoutingDirector, sl_holder : SelfLoopHolder) -> Unit {
  let ports = sl_holder.get_l_node().get_ports()
  let penalties = []
  let mut penalty_sum = 0

  for port in ports {
    if port.get_incoming_edges().is_empty() && port.get_outgoing_edges().is_empty() {
      penalty_sum += 1
    } else {
      penalty_sum += 3
    }
    penalties.push(penalty_sum)
  }

  self.port_penalties = Some(penalties)
}

///|
fn RoutingDirector::require_port_penalties(self : RoutingDirector) -> Array[Int] {
  match self.port_penalties {
    Some(penalties) => penalties
    None => abort("port penalties not initialized")
  }
}

///|
fn RoutingDirector::compute_edge_penalty(
  self : RoutingDirector,
  sl_holder : SelfLoopHolder,
  leftmost_port : SelfLoopPort,
  rightmost_port : SelfLoopPort,
) -> Int {
  if self.port_penalties.is_none() {
    self.compute_penalties(sl_holder)
  }
  let penalties = self.require_port_penalties()

  let port_count = sl_holder.get_l_node().get_ports().length()
  let leftmost_port_id = leftmost_port.get_l_port().get_id()
  let rightmost_port_id = rightmost_port.get_l_port().get_id()
  let mut left_of_rightmost_port_id = rightmost_port_id - 1

  if left_of_rightmost_port_id < 0 {
    left_of_rightmost_port_id = port_count - 1
  }

  if leftmost_port_id <= left_of_rightmost_port_id {
    penalties[left_of_rightmost_port_id] - penalties[leftmost_port_id]
  } else {
    penalties[port_count - 1] - penalties[leftmost_port_id] +
    penalties[left_of_rightmost_port_id]
  }
}

///|
pub fn RoutingDirector::determine_loop_routes(
  self : RoutingDirector,
  sl_holder : SelfLoopHolder,
) -> Unit {
  self.assign_port_ids(sl_holder.get_l_node().get_ports())
  self.sort_hyper_loop_port_lists(sl_holder)

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match routing_director_require_self_loop_type(sl_loop) {
      OneSide => self.determine_one_side_loop_routes(sl_loop)
      TwoSidesCorner => self.determine_two_side_corner_loop_routes(sl_loop)
      TwoSidesOpposing => self.determine_two_side_opposing_loop_routes(sl_loop)
      ThreeSides => self.determine_three_side_loop_routes(sl_loop)
      FourSides => self.determine_four_side_loop_routes(sl_loop)
    }

    self.compute_occupied_port_sides(sl_loop)
  }

  self.port_penalties = None
}
