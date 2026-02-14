///|
fn port_side_assigner_port_side_equals(left : PortSide, right : PortSide) -> Bool {
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
fn port_side_assigner_parse_constraints(value : String) -> PortConstraints {
  match value {
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn port_side_assigner_parse_distribution(
  value : String,
) -> SelfLoopDistributionStrategy {
  match value {
    "NORTH" => SelfLoopDistributionStrategy::North
    "NORTH_SOUTH" => SelfLoopDistributionStrategy::NorthSouth
    "EQUALLY" => SelfLoopDistributionStrategy::Equally
    _ => SelfLoopDistributionStrategy::North
  }
}

///|
pub struct PortSideAssigner {
  _reserved : Int
}

///|
pub fn new_port_side_assigner() -> PortSideAssigner {
  { _reserved: 0 }
}

///|
fn port_side_assigner_hidden_ports(sl_loop : SelfHyperLoop) -> Array[SelfLoopPort] {
  let hidden = []
  for sl_port in sl_loop.get_sl_ports() {
    if sl_port.is_hidden() {
      hidden.push(sl_port)
    }
  }
  hidden
}

///|
fn port_side_assigner_sort_ports_by_net_flow(
  sl_ports : Array[SelfLoopPort],
) -> Unit {
  let mut i = 1
  while i < sl_ports.length() {
    let mut j = i
    while j > 0 &&
      sl_ports[j - 1].get_l_port().get_net_flow() >
      sl_ports[j].get_l_port().get_net_flow() {
      let temp = sl_ports[j - 1]
      sl_ports[j - 1] = sl_ports[j]
      sl_ports[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
fn port_side_assigner_sort_loops_by_port_count_desc(
  sl_loops : Array[SelfHyperLoop],
) -> Unit {
  let mut i = 1
  while i < sl_loops.length() {
    let mut j = i
    while j > 0 &&
      sl_loops[j - 1].get_sl_ports().length() <
      sl_loops[j].get_sl_ports().length() {
      let temp = sl_loops[j - 1]
      sl_loops[j - 1] = sl_loops[j]
      sl_loops[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
fn PortSideAssigner::assign_to_north_side(
  self : PortSideAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  ignore(self)
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    for sl_port in port_side_assigner_hidden_ports(sl_loop) {
      sl_port.get_l_port().set_side(PortSide::North)
    }
  }
}

///|
fn PortSideAssigner::assign_to_north_or_south_side(
  self : PortSideAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  ignore(self)
  let mut north_ports = 0
  let mut south_ports = 0

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    let sl_hidden_ports = port_side_assigner_hidden_ports(sl_loop)
    let mut new_port_side : PortSide = PortSide::North

    if north_ports <= south_ports {
      new_port_side = PortSide::North
      north_ports += sl_hidden_ports.length()
    } else {
      new_port_side = PortSide::South
      south_ports += sl_hidden_ports.length()
    }

    for sl_port in sl_hidden_ports {
      sl_port.get_l_port().set_side(new_port_side)
    }
  }
}

///|
pub enum PortSideAssignerTarget {
  NorthTarget
  SouthTarget
  EastTarget
  WestTarget
  NorthWestCornerTarget
  NorthEastCornerTarget
  SouthWestCornerTarget
  SouthEastCornerTarget
}

///|
fn port_side_assigner_target_sides(
  target : PortSideAssignerTarget,
) -> (PortSide, PortSide) {
  match target {
    PortSideAssignerTarget::NorthTarget =>
      (PortSide::North, PortSide::North)
    PortSideAssignerTarget::SouthTarget =>
      (PortSide::South, PortSide::South)
    PortSideAssignerTarget::EastTarget =>
      (PortSide::East, PortSide::East)
    PortSideAssignerTarget::WestTarget =>
      (PortSide::West, PortSide::West)
    PortSideAssignerTarget::NorthWestCornerTarget =>
      (PortSide::West, PortSide::North)
    PortSideAssignerTarget::NorthEastCornerTarget =>
      (PortSide::North, PortSide::East)
    PortSideAssignerTarget::SouthWestCornerTarget =>
      (PortSide::South, PortSide::West)
    PortSideAssignerTarget::SouthEastCornerTarget =>
      (PortSide::East, PortSide::South)
  }
}

///|
fn port_side_assigner_is_corner_target(target : PortSideAssignerTarget) -> Bool {
  let (first_side, second_side) = port_side_assigner_target_sides(target)
  !port_side_assigner_port_side_equals(first_side, second_side)
}

///|
fn PortSideAssigner::assign_to_target(
  self : PortSideAssigner,
  sl_loop : SelfHyperLoop,
  target : PortSideAssignerTarget,
) -> Unit {
  ignore(self)
  let (first_side, second_side) = port_side_assigner_target_sides(target)
  let sl_ports = sl_loop.get_sl_ports()

  if port_side_assigner_is_corner_target(target) {
    port_side_assigner_sort_ports_by_net_flow(sl_ports)
  }

  let second_half_start_index = sl_ports.length() / 2
  for i in 0..<second_half_start_index {
    let sl_port = sl_ports[i]
    if sl_port.is_hidden() {
      sl_port.get_l_port().set_side(first_side)
    }
  }

  for i in second_half_start_index..<sl_ports.length() {
    let sl_port = sl_ports[i]
    if sl_port.is_hidden() {
      sl_port.get_l_port().set_side(second_side)
    }
  }
}

///|
fn PortSideAssigner::assign_to_all_sides(
  self : PortSideAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  let sl_sorted_loops = sl_holder.get_sl_hyper_loops().copy()
  port_side_assigner_sort_loops_by_port_count_desc(sl_sorted_loops)

  let assignment_targets : Array[PortSideAssignerTarget] = [
    NorthTarget,
    SouthTarget,
    EastTarget,
    WestTarget,
    NorthWestCornerTarget,
    NorthEastCornerTarget,
    SouthWestCornerTarget,
    SouthEastCornerTarget,
  ]

  let mut curr_loop = 0
  for sl_loop in sl_sorted_loops {
    let curr_target = assignment_targets[curr_loop % assignment_targets.length()]
    self.assign_to_target(sl_loop, curr_target)
    curr_loop += 1
  }
}

///|
pub fn PortSideAssigner::assign_port_sides(
  self : PortSideAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  let l_node = sl_holder.get_l_node()
  let original_constraints = port_side_assigner_parse_constraints(
    l_node.get_property_string(internal_properties_original_port_constraints),
  )

  if original_constraints.is_side_fixed() {
    return
  }

  let distribution = port_side_assigner_parse_distribution(
    l_node.get_property_string(
      layered_options_edge_routing_self_loop_distribution,
    ),
  )

  match distribution {
    SelfLoopDistributionStrategy::North => self.assign_to_north_side(sl_holder)
    SelfLoopDistributionStrategy::NorthSouth =>
      self.assign_to_north_or_south_side(sl_holder)
    SelfLoopDistributionStrategy::Equally => self.assign_to_all_sides(sl_holder)
  }
}
