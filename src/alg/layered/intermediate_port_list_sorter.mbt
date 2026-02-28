///|
fn port_list_sorter_port_constraints_from_string(
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
fn port_list_sorter_port_sorting_strategy_from_string(
  value : String,
) -> PortSortingStrategy {
  match value {
    "PORT_DEGREE" => PortSortingStrategy::PortDegree
    _ => PortSortingStrategy::InputOrder
  }
}

///|
fn port_list_sorter_port_side_rank(side : @core.PortSide) -> Int {
  match side {
    @core.PortSide::SideUndefined => 0
    @core.PortSide::North => 1
    @core.PortSide::East => 2
    @core.PortSide::South => 3
    @core.PortSide::West => 4
  }
}

///|
fn _port_list_sorter_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
fn port_list_sorter_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn port_list_sorter_compare_port_side(p1 : LPort, p2 : LPort) -> Int {
  port_list_sorter_port_side_rank(p1.get_side()) -
  port_list_sorter_port_side_rank(p2.get_side())
}

///|
fn port_list_sorter_real_degree(port : LPort, incoming : Bool) -> Int {
  let mut degree = 0
  if incoming {
    for edge in port.get_incoming_edges() {
      if !edge.get_property_bool(internal_properties_reversed) {
        degree = degree + 1
      }
    }
  } else {
    for edge in port.get_outgoing_edges() {
      if !edge.get_property_bool(internal_properties_reversed) {
        degree = degree + 1
      }
    }
  }
  degree
}

///|
fn port_list_sorter_compare_port_degree_east_west(
  p1 : LPort,
  p2 : LPort,
) -> Int {
  let side_diff = port_list_sorter_compare_port_side(p1, p2)
  if side_diff != 0 {
    return 0
  }

  match p1.get_side() {
    @core.PortSide::East =>
      port_list_sorter_real_degree(p2, false) -
      port_list_sorter_real_degree(p1, false)
    @core.PortSide::West =>
      port_list_sorter_real_degree(p1, true) -
      port_list_sorter_real_degree(p2, true)
    _ => 0
  }
}

///|
fn port_list_sorter_compare_fixed_order_and_fixed_pos(
  p1 : LPort,
  p2 : LPort,
) -> Int {
  let side_diff = port_list_sorter_compare_port_side(p1, p2)
  if side_diff != 0 {
    return 0
  }

  let node = match p1.get_node() {
    Some(value) => value
    None => return 0
  }
  let constraints_value = if node.has_property_string(@core.port_constraints) {
    node.get_property_string(@core.port_constraints)
  } else {
    @core.port_constraints.get_default()
  }
  let constraints = port_list_sorter_port_constraints_from_string(
    constraints_value,
  )
  if !constraints.is_order_fixed() {
    return 0
  }

  if constraints is FixedOrder &&
    p1.has_property_int(layered_options_port_index) &&
    p2.has_property_int(layered_options_port_index) {
    let index_diff = p1.get_property_int(layered_options_port_index) -
      p2.get_property_int(layered_options_port_index)
    if index_diff != 0 {
      return index_diff
    }
  }

  match p1.get_side() {
    @core.PortSide::North =>
      port_list_sorter_compare_double(p1.get_position().x, p2.get_position().x)
    @core.PortSide::East =>
      port_list_sorter_compare_double(p1.get_position().y, p2.get_position().y)
    @core.PortSide::South =>
      port_list_sorter_compare_double(p2.get_position().x, p1.get_position().x)
    @core.PortSide::West =>
      port_list_sorter_compare_double(p2.get_position().y, p1.get_position().y)
    @core.PortSide::SideUndefined => 0
  }
}

///|
fn port_list_sorter_compare_combined(p1 : LPort, p2 : LPort) -> Int {
  let side_diff = port_list_sorter_compare_port_side(p1, p2)
  if side_diff != 0 {
    return side_diff
  }
  port_list_sorter_compare_fixed_order_and_fixed_pos(p1, p2)
}

///|
fn port_list_sorter_insertion_sort(
  ports : Array[LPort],
  compare : (LPort, LPort) -> Int,
) -> Unit {
  let mut i = 1
  while i < ports.length() {
    let current = ports[i]
    let mut j = i
    while j > 0 && compare(ports[j - 1], current) > 0 {
      ports[j] = ports[j - 1]
      j = j - 1
    }
    ports[j] = current
    i = i + 1
  }
}

///|
fn port_list_sorter_find_port_side_range(
  ports : Array[LPort],
  side : @core.PortSide,
) -> (Int, Int) {
  if ports.is_empty() {
    return (0, 0)
  }

  let mut current_side = ports[0].get_side()
  let mut low_idx = 0
  let lb = port_list_sorter_port_side_rank(side)
  let hb = lb + 1

  while low_idx < ports.length() - 1 &&
        port_list_sorter_port_side_rank(current_side) < lb {
    low_idx = low_idx + 1
    current_side = ports[low_idx].get_side()
  }

  let mut high_idx = low_idx
  while high_idx < ports.length() - 1 &&
        port_list_sorter_port_side_rank(current_side) < hb {
    high_idx = high_idx + 1
    current_side = ports[low_idx].get_side()
  }

  (low_idx, high_idx)
}

///|
fn port_list_sorter_reverse(
  ports : Array[LPort],
  low_idx : Int,
  high_idx : Int,
) -> Unit {
  if high_idx <= low_idx + 2 {
    return
  }

  let n = (high_idx - low_idx) / 2
  let mut i = 0
  while i < n {
    let tmp = ports[low_idx + i]
    ports[low_idx + i] = ports[high_idx - i - 1]
    ports[high_idx - i - 1] = tmp
    i = i + 1
  }
}

///|
fn port_list_sorter_reverse_west_and_south_side(ports : Array[LPort]) -> Unit {
  if ports.length() <= 1 {
    return
  }

  let (south_low, south_high) = port_list_sorter_find_port_side_range(
    ports,
    @core.PortSide::South,
  )
  port_list_sorter_reverse(ports, south_low, south_high)

  let (west_low, west_high) = port_list_sorter_find_port_side_range(
    ports,
    @core.PortSide::West,
  )
  port_list_sorter_reverse(ports, west_low, west_high)
}

///|
fn port_list_sorter_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Port order processing", 1.0))

  let strategy_value = if layered_graph.has_property_string(
      layered_options_port_sorting_strategy,
    ) {
    layered_graph.get_property_string(layered_options_port_sorting_strategy)
  } else {
    layered_options_port_sorting_strategy.get_default()
  }
  let sorting_strategy = port_list_sorter_port_sorting_strategy_from_string(
    strategy_value,
  )

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      let constraints_value = if node.has_property_string(
          @core.port_constraints,
        ) {
        node.get_property_string(@core.port_constraints)
      } else {
        @core.port_constraints.get_default()
      }
      let constraints = port_list_sorter_port_constraints_from_string(
        constraints_value,
      )
      let ports = node.get_ports()

      if constraints.is_order_fixed() {
        port_list_sorter_insertion_sort(
          ports, port_list_sorter_compare_combined,
        )
      } else if constraints.is_side_fixed() {
        port_list_sorter_insertion_sort(
          ports, port_list_sorter_compare_port_side,
        )
        port_list_sorter_reverse_west_and_south_side(ports)

        if sorting_strategy is PortDegree {
          port_list_sorter_insertion_sort(
            ports, port_list_sorter_compare_port_degree_east_west,
          )
        }
      }
      node.cache_port_sides()
    }
  }

  monitor.done()
}

///|
pub fn new_port_list_sorter_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(port_list_sorter_process)
}
