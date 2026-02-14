///|
fn port_restorer_port_side_equals(left : PortSide, right : PortSide) -> Bool {
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
fn port_restorer_parse_ordering(value : String) -> SelfLoopOrderingStrategy {
  match value {
    "STACKED" => SelfLoopOrderingStrategy::Stacked
    "REVERSE_STACKED" => SelfLoopOrderingStrategy::ReverseStacked
    "SEQUENCED" => SelfLoopOrderingStrategy::Sequenced
    _ => SelfLoopOrderingStrategy::Stacked
  }
}

///|
fn port_restorer_ordering_equals(
  left : SelfLoopOrderingStrategy,
  right : SelfLoopOrderingStrategy,
) -> Bool {
  match (left, right) {
    (SelfLoopOrderingStrategy::Stacked, SelfLoopOrderingStrategy::Stacked) =>
      true
    (
      SelfLoopOrderingStrategy::ReverseStacked,
      SelfLoopOrderingStrategy::ReverseStacked,
    ) =>
      true
    (SelfLoopOrderingStrategy::Sequenced, SelfLoopOrderingStrategy::Sequenced) =>
      true
    _ => false
  }
}

///|
fn port_restorer_self_loop_type_index(self_loop_type : SelfLoopType) -> Int {
  match self_loop_type {
    OneSide => 1
    TwoSidesCorner => 2
    TwoSidesOpposing => 3
    ThreeSides => 4
    FourSides => 5
  }
}

///|
pub enum PortSideArea {
  Start
  Middle
  End
}

///|
fn port_restorer_port_side_area_to_string(area : PortSideArea) -> String {
  match area {
    PortSideArea::Start => "START"
    PortSideArea::Middle => "MIDDLE"
    PortSideArea::End => "END"
  }
}

///|
pub enum AddMode {
  Prepend
  Append
}

///|
fn port_restorer_target_area_key(
  side : PortSide,
  area : PortSideArea,
) -> String {
  port_side_to_string(side) + ":" + port_restorer_port_side_area_to_string(area)
}

///|
fn port_restorer_target_area_ensure(
  target_areas : Map[String, Array[SelfLoopPort]],
  side : PortSide,
  area : PortSideArea,
) -> Array[SelfLoopPort] {
  let key = port_restorer_target_area_key(side, area)
  match target_areas.get(key) {
    Some(target) => target
    None => {
      let target = []
      target_areas[key] = target
      target
    }
  }
}

///|
fn port_restorer_target_area_get(
  target_areas : Map[String, Array[SelfLoopPort]],
  side : PortSide,
  area : PortSideArea,
) -> Array[SelfLoopPort] {
  port_restorer_target_area_ensure(target_areas, side, area)
}

///|
fn port_restorer_sl_loops_by_type_get(
  sl_loops_by_type : Map[Int, Array[SelfHyperLoop]],
  self_loop_type : SelfLoopType,
) -> Array[SelfHyperLoop] {
  let key = port_restorer_self_loop_type_index(self_loop_type)
  match sl_loops_by_type.get(key) {
    Some(loops) => loops
    None => {
      let loops = []
      sl_loops_by_type[key] = loops
      loops
    }
  }
}

///|
fn port_restorer_subarray(
  values : Array[SelfLoopPort],
  begin_index : Int,
  end_index : Int,
) -> Array[SelfLoopPort] {
  let result = []
  let mut i = begin_index
  while i < end_index {
    result.push(values[i])
    i += 1
  }
  result
}

///|
fn port_restorer_reverse_hyper_loops(
  loops : Array[SelfHyperLoop],
) -> Array[SelfHyperLoop] {
  let result = []
  let mut index = loops.length() - 1
  while index >= 0 {
    result.push(loops[index])
    index -= 1
  }
  result
}

///|
fn port_restorer_sort_ports_by_net_flow(sl_ports : Array[SelfLoopPort]) -> Unit {
  let mut i = 1
  while i < sl_ports.length() {
    let mut j = i
    while j > 0 &&
      sl_ports[j - 1].get_sl_net_flow() > sl_ports[j].get_sl_net_flow() {
      let temp = sl_ports[j - 1]
      sl_ports[j - 1] = sl_ports[j]
      sl_ports[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
fn port_restorer_sort_sides(sides : Array[PortSide]) -> Unit {
  let mut i = 1
  while i < sides.length() {
    let mut j = i
    while j > 0 &&
      port_restorer_port_side_order(sides[j - 1]) >
      port_restorer_port_side_order(sides[j]) {
      let temp = sides[j - 1]
      sides[j - 1] = sides[j]
      sides[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
pub struct PortRestorer {
  mut sl_loops_by_type : Map[Int, Array[SelfHyperLoop]]
  target_areas : Map[String, Array[SelfLoopPort]]
}

///|
pub fn new_port_restorer() -> PortRestorer {
  {
    sl_loops_by_type: {},
    target_areas: {},
  }
}

///|
fn PortRestorer::init_target_areas(self : PortRestorer) -> Unit {
  self.target_areas.clear()
  for side in port_side_values() {
    for area in [PortSideArea::Start, PortSideArea::Middle, PortSideArea::End] {
      ignore(port_restorer_target_area_ensure(self.target_areas, side, area))
    }
  }
}

///|
fn PortRestorer::gather_self_loops_by_type(
  self : PortRestorer,
  sl_holder : SelfLoopHolder,
) -> Map[Int, Array[SelfHyperLoop]] {
  let loops : Map[Int, Array[SelfHyperLoop]] = {}
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match sl_loop.get_self_loop_type() {
      Some(self_loop_type) => {
        let list = port_restorer_sl_loops_by_type_get(loops, self_loop_type)
        list.push(sl_loop)
      }
      None => ()
    }
  }
  loops
}

///|
fn PortRestorer::compute_port_list_split_index(
  self : PortRestorer,
  sorted_ports : Array[SelfLoopPort],
) -> Int {
  ignore(self)

  let mut positive_net_flow_index = 0
  while positive_net_flow_index < sorted_ports.length() {
    if sorted_ports[positive_net_flow_index].get_sl_net_flow() > 0 {
      break
    }
    positive_net_flow_index += 1
  }

  if positive_net_flow_index > 0 &&
    positive_net_flow_index < sorted_ports.length() - 1 {
    return positive_net_flow_index
  }

  let mut non_negative_net_flow_index = 0
  while non_negative_net_flow_index < sorted_ports.length() {
    if sorted_ports[non_negative_net_flow_index].get_sl_net_flow() > 0 {
      break
    }
    non_negative_net_flow_index += 1
  }

  if non_negative_net_flow_index > 0 &&
    positive_net_flow_index < sorted_ports.length() - 1 {
    return non_negative_net_flow_index
  }

  sorted_ports.length() / 2
}

///|
fn PortRestorer::add_to_target_area_loop(
  self : PortRestorer,
  sl_loop : SelfHyperLoop,
  port_side : PortSide,
  area : PortSideArea,
  add_mode : AddMode,
) -> Unit {
  self.add_to_target_area_ports(
    sl_loop.get_sl_ports_by_side(port_side),
    port_side,
    area,
    add_mode,
  )
}

///|
fn PortRestorer::add_to_target_area_ports(
  self : PortRestorer,
  sl_ports : Array[SelfLoopPort],
  port_side : PortSide,
  area : PortSideArea,
  add_mode : AddMode,
) -> Unit {
  let hidden_ports = []
  for sl_port in sl_ports {
    if sl_port.is_hidden() {
      hidden_ports.push(sl_port)
    }
  }

  let target = port_restorer_target_area_get(self.target_areas, port_side, area)

  match add_mode {
    AddMode::Prepend => {
      for sl_port in hidden_ports {
        ignore(target.insert(0, sl_port))
      }
    }
    AddMode::Append => {
      let mut index = hidden_ports.length() - 1
      while index >= 0 {
        target.push(hidden_ports[index])
        index -= 1
      }
    }
  }
}

///|
fn PortRestorer::process_one_side_loops(
  self : PortRestorer,
  ordering : SelfLoopOrderingStrategy,
) -> Unit {
  let mut loops = port_restorer_sl_loops_by_type_get(self.sl_loops_by_type, OneSide)
  if port_restorer_ordering_equals(
      ordering,
      SelfLoopOrderingStrategy::ReverseStacked,
    ) {
    loops = port_restorer_reverse_hyper_loops(loops)
  }

  for sl_loop in loops {
    let side = sl_loop.get_sl_ports()[0].get_l_port().get_side()
    let sorted_ports = sl_loop.get_sl_ports().copy()
    port_restorer_sort_ports_by_net_flow(sorted_ports)

    match ordering {
      SelfLoopOrderingStrategy::Sequenced =>
        self.add_to_target_area_ports(
          sorted_ports,
          side,
          PortSideArea::Middle,
          AddMode::Append,
        )
      SelfLoopOrderingStrategy::ReverseStacked =>
        {
          let split_index = self.compute_port_list_split_index(sorted_ports)
          self.add_to_target_area_ports(
            port_restorer_subarray(sorted_ports, 0, split_index),
            side,
            PortSideArea::Middle,
            AddMode::Prepend,
          )
          self.add_to_target_area_ports(
            port_restorer_subarray(
              sorted_ports,
              split_index,
              sorted_ports.length(),
            ),
            side,
            PortSideArea::Middle,
            AddMode::Append,
          )
        }
      SelfLoopOrderingStrategy::Stacked =>
        {
          let split_index = self.compute_port_list_split_index(sorted_ports)
          self.add_to_target_area_ports(
            port_restorer_subarray(sorted_ports, 0, split_index),
            side,
            PortSideArea::Middle,
            AddMode::Prepend,
          )
          self.add_to_target_area_ports(
            port_restorer_subarray(
              sorted_ports,
              split_index,
              sorted_ports.length(),
            ),
            side,
            PortSideArea::Middle,
            AddMode::Append,
          )
        }
    }
  }
}

///|
fn port_restorer_port_side_order(side : PortSide) -> Int {
  match side {
    SideUndefined => 0
    North => 1
    East => 2
    South => 3
    West => 4
  }
}

///|
fn port_restorer_side_pair_swap(values : Array[PortSide]) -> Unit {
  if values.length() < 2 {
    return
  }
  let first = values[0]
  values[0] = values[1]
  values[1] = first
}

///|
pub fn port_restorer_sorted_two_side_loop_port_sides(
  sl_loop : SelfHyperLoop,
) -> Array[PortSide] {
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

  port_restorer_sort_sides(sides)

  if sides.length() == 2 &&
    port_restorer_port_side_equals(sides[0], PortSide::North) &&
    port_restorer_port_side_equals(sides[1], PortSide::West) {
    port_restorer_side_pair_swap(sides)
  }

  sides
}

///|
fn PortRestorer::process_two_side_corner_loops(self : PortRestorer) -> Unit {
  for sl_loop in port_restorer_sl_loops_by_type_get(
    self.sl_loops_by_type,
    TwoSidesCorner,
  ) {
    let sides = port_restorer_sorted_two_side_loop_port_sides(sl_loop)
    if sides.length() == 2 {
      self.add_to_target_area_loop(
        sl_loop,
        sides[0],
        PortSideArea::End,
        AddMode::Prepend,
      )
      self.add_to_target_area_loop(
        sl_loop,
        sides[1],
        PortSideArea::Start,
        AddMode::Append,
      )
    }
  }
}

///|
fn PortRestorer::process_two_side_opposing_loops(self : PortRestorer) -> Unit {
  for sl_loop in port_restorer_sl_loops_by_type_get(
    self.sl_loops_by_type,
    TwoSidesOpposing,
  ) {
    let sides = port_restorer_sorted_two_side_loop_port_sides(sl_loop)
    if sides.length() == 2 {
      self.add_to_target_area_loop(
        sl_loop,
        sides[0],
        PortSideArea::End,
        AddMode::Prepend,
      )
      self.add_to_target_area_loop(
        sl_loop,
        sides[1],
        PortSideArea::Start,
        AddMode::Append,
      )
    }
  }
}

///|
fn port_restorer_loop_has_side(sl_loop : SelfHyperLoop, side : PortSide) -> Bool {
  sl_loop.has_sl_ports_on_side(side)
}

///|
fn PortRestorer::determine_loop_constellation(
  self : PortRestorer,
  sl_loop : SelfHyperLoop,
) -> Array[PortSide] {
  ignore(self)
  if !port_restorer_loop_has_side(sl_loop, PortSide::North) {
    [PortSide::East, PortSide::South, PortSide::West]
  } else if !port_restorer_loop_has_side(sl_loop, PortSide::East) {
    [PortSide::South, PortSide::West, PortSide::North]
  } else if !port_restorer_loop_has_side(sl_loop, PortSide::South) {
    [PortSide::West, PortSide::North, PortSide::East]
  } else if !port_restorer_loop_has_side(sl_loop, PortSide::West) {
    [PortSide::North, PortSide::East, PortSide::South]
  } else {
    []
  }
}

///|
fn PortRestorer::process_three_side_loops(self : PortRestorer) -> Unit {
  for sl_loop in port_restorer_sl_loops_by_type_get(
    self.sl_loops_by_type,
    ThreeSides,
  ) {
    let sides = self.determine_loop_constellation(sl_loop)
    if sides.length() == 3 {
      self.add_to_target_area_loop(
        sl_loop,
        sides[0],
        PortSideArea::End,
        AddMode::Prepend,
      )
      self.add_to_target_area_loop(
        sl_loop,
        sides[1],
        PortSideArea::Middle,
        AddMode::Append,
      )
      self.add_to_target_area_loop(
        sl_loop,
        sides[2],
        PortSideArea::Start,
        AddMode::Append,
      )
    }
  }
}

///|
fn PortRestorer::process_four_side_loops(self : PortRestorer) -> Unit {
  for sl_loop in port_restorer_sl_loops_by_type_get(
    self.sl_loops_by_type,
    FourSides,
  ) {
    for side in [
      PortSide::North,
      PortSide::East,
      PortSide::South,
      PortSide::West,
    ] {
      if sl_loop.has_sl_ports_on_side(side) {
        self.add_to_target_area_loop(
          sl_loop,
          side,
          PortSideArea::Middle,
          AddMode::Append,
        )
      }
    }
  }
}

///|
fn PortRestorer::add_all(self : PortRestorer, sl_ports : Array[SelfLoopPort], l_node : LNode) -> Unit {
  ignore(self)
  for sl_port in sl_ports {
    sl_port.get_l_port().set_node(Some(l_node))
  }
}

///|
fn PortRestorer::add_all_that(
  self : PortRestorer,
  l_ports : Array[LPort],
  from_index : Int,
  condition : (LPort) -> Bool,
  target : Array[LPort],
) -> Int {
  ignore(self)
  for i in from_index..<l_ports.length() {
    let l_port = l_ports[i]
    if condition(l_port) {
      target.push(l_port)
    } else {
      return i
    }
  }
  l_ports.length()
}

///|
fn port_restorer_side_set_contains(
  sides : Array[PortSide],
  side : PortSide,
) -> Bool {
  for existing in sides {
    if port_restorer_port_side_equals(existing, side) {
      return true
    }
  }
  false
}

///|
fn port_restorer_side_set_add(sides : Array[PortSide], side : PortSide) -> Unit {
  if !port_restorer_side_set_contains(sides, side) {
    sides.push(side)
  }
}

///|
fn PortRestorer::north_south_port_connection_sides(
  self : PortRestorer,
  l_port : LPort,
) -> Array[PortSide] {
  ignore(self)
  let connection_sides = []

  match l_port.get_property_l_node(internal_properties_port_dummy) {
    Some(port_dummy) =>
      for dummy_l_port in port_dummy.get_ports() {
        match dummy_l_port.get_property_l_port(internal_properties_origin_l_port) {
          Some(origin) => {
            if lport_internal_handle(origin) == lport_internal_handle(l_port) {
              if !dummy_l_port.get_connected_edges().is_empty() {
                port_restorer_side_set_add(connection_sides, dummy_l_port.get_side())
              }
            }
          }
          None => ()
        }
      }
    None => ()
  }

  connection_sides
}

///|
fn PortRestorer::is_north_south_port_with_west_or_west_east_connections(
  self : PortRestorer,
  l_port : LPort,
) -> Bool {
  let connections = self.north_south_port_connection_sides(l_port)
  let east_connections = port_restorer_side_set_contains(connections, East)
  let west_connections = port_restorer_side_set_contains(connections, West)
  west_connections || (west_connections && east_connections)
}

///|
fn PortRestorer::is_north_south_port_with_east_connections(
  self : PortRestorer,
  l_port : LPort,
) -> Bool {
  let connections = self.north_south_port_connection_sides(l_port)
  port_restorer_side_set_contains(connections, East)
}

///|
fn PortRestorer::restore_ports_internal(
  self : PortRestorer,
  sl_holder : SelfLoopHolder,
) -> Unit {
  let l_node = sl_holder.get_l_node()
  let old_port_list = l_node.get_ports().copy()
  let mut next_old_port_index = 0

  let new_port_list = l_node.get_ports()
  new_port_list.clear()

  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      North,
      PortSideArea::Start,
    ),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) =>
      port_restorer_port_side_equals(l_port.get_side(), North) &&
      self.is_north_south_port_with_west_or_west_east_connections(l_port),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      North,
      PortSideArea::Middle,
    ),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) => port_restorer_port_side_equals(l_port.get_side(), North),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      North,
      PortSideArea::End,
    ),
    l_node,
  )

  self.add_all(
    port_restorer_target_area_get(self.target_areas, East, PortSideArea::Start),
    l_node,
  )
  self.add_all(
    port_restorer_target_area_get(self.target_areas, East, PortSideArea::Middle),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) => port_restorer_port_side_equals(l_port.get_side(), East),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(self.target_areas, East, PortSideArea::End),
    l_node,
  )

  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      South,
      PortSideArea::Start,
    ),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) =>
      port_restorer_port_side_equals(l_port.get_side(), South) &&
      self.is_north_south_port_with_east_connections(l_port),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      South,
      PortSideArea::Middle,
    ),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) => port_restorer_port_side_equals(l_port.get_side(), South),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(
      self.target_areas,
      South,
      PortSideArea::End,
    ),
    l_node,
  )

  self.add_all(
    port_restorer_target_area_get(self.target_areas, West, PortSideArea::Start),
    l_node,
  )
  next_old_port_index = self.add_all_that(
    old_port_list,
    next_old_port_index,
    (l_port) => port_restorer_port_side_equals(l_port.get_side(), West),
    new_port_list,
  )
  self.add_all(
    port_restorer_target_area_get(self.target_areas, West, PortSideArea::Middle),
    l_node,
  )
  self.add_all(
    port_restorer_target_area_get(self.target_areas, West, PortSideArea::End),
    l_node,
  )
}

///|
pub fn PortRestorer::restore_ports(
  self : PortRestorer,
  sl_holder : SelfLoopHolder,
  monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(monitor)
  self.init_target_areas()
  self.sl_loops_by_type = self.gather_self_loops_by_type(sl_holder)

  let ordering = port_restorer_parse_ordering(
    sl_holder.get_l_node().get_property_string(
      layered_options_edge_routing_self_loop_ordering,
    ),
  )
  self.process_one_side_loops(ordering)
  self.process_two_side_corner_loops()
  self.process_three_side_loops()
  self.process_four_side_loops()
  self.process_two_side_opposing_loops()

  self.restore_ports_internal(sl_holder)

  for side in port_side_values() {
    for area in [PortSideArea::Start, PortSideArea::Middle, PortSideArea::End] {
      for sl_port in port_restorer_target_area_get(self.target_areas, side, area) {
        sl_port.set_hidden(false)
      }
    }
  }
  sl_holder.set_ports_hidden(false)
  self.sl_loops_by_type.clear()
}
