///|
fn routing_slot_assigner_port_side_equals(left : PortSide, right : PortSide) -> Bool {
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
fn routing_slot_assigner_contains_int(values : Array[Int], target : Int) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
fn routing_slot_assigner_add_unique_int(values : Array[Int], target : Int) -> Unit {
  if !routing_slot_assigner_contains_int(values, target) {
    values.push(target)
  }
}

///|
fn routing_slot_assigner_has_side(sl_loop : SelfHyperLoop, side : PortSide) -> Bool {
  for occupied_side in sl_loop.get_occupied_port_sides() {
    if routing_slot_assigner_port_side_equals(occupied_side, side) {
      return true
    }
  }
  false
}

///|
fn routing_slot_assigner_sort_loops_by_side_slot(
  sl_loops : Array[SelfHyperLoop],
  side : PortSide,
) -> Unit {
  let mut i = 1
  while i < sl_loops.length() {
    let mut j = i
    while j > 0 &&
      sl_loops[j - 1].get_routing_slot(side) > sl_loops[j].get_routing_slot(side) {
      let temp = sl_loops[j - 1]
      sl_loops[j - 1] = sl_loops[j]
      sl_loops[j] = temp
      j -= 1
    }
    i += 1
  }
}

///|
fn routing_slot_assigner_require_segment(
  segments : Map[Int, HyperEdgeSegment],
  loop_id : Int,
) -> HyperEdgeSegment {
  match segments.get(loop_id) {
    Some(segment) => segment
    None => abort("missing segment for self loop")
  }
}

///|
fn routing_slot_assigner_require_loop_activity(
  loop_activity : Map[Int, Array[Bool]],
  loop_id : Int,
) -> Array[Bool] {
  match loop_activity.get(loop_id) {
    Some(activity) => activity
    None => abort("missing loop activity")
  }
}

///|
fn routing_slot_assigner_new_label_crossing_matrix(
  size : Int,
) -> Array[Array[Bool]] {
  let matrix = []
  for _i in 0..<size {
    let row = []
    for _j in 0..<size {
      row.push(false)
    }
    matrix.push(row)
  }
  matrix
}

///|
fn routing_slot_assigner_labels_overlap(
  sl_loop_1 : SelfHyperLoop,
  sl_loop_2 : SelfHyperLoop,
) -> Bool {
  let sl_labels_1 = match sl_loop_1.get_sl_labels() {
    Some(labels) => labels
    None => return false
  }
  let sl_labels_2 = match sl_loop_2.get_sl_labels() {
    Some(labels) => labels
    None => return false
  }

  if !routing_slot_assigner_port_side_equals(
      sl_labels_1.get_side(),
      sl_labels_2.get_side(),
    ) ||
    routing_slot_assigner_port_side_equals(sl_labels_1.get_side(), East) ||
    routing_slot_assigner_port_side_equals(sl_labels_1.get_side(), West) {
    return false
  }

  let start_1 = sl_labels_1.get_position().x
  let end_1 = start_1 + sl_labels_1.get_size().x
  let start_2 = sl_labels_2.get_position().x
  let end_2 = start_2 + sl_labels_2.get_size().x
  start_1 <= end_2 && end_1 >= start_2
}

///|
pub struct RoutingSlotAssigner {
  hyper_edge_segments : Array[HyperEdgeSegment]
  sl_loop_to_segment_map : Map[Int, HyperEdgeSegment]
  sl_loop_activity_over_ports : Map[Int, Array[Bool]]
}

///|
pub fn new_routing_slot_assigner() -> RoutingSlotAssigner {
  {
    hyper_edge_segments: [],
    sl_loop_to_segment_map: {},
    sl_loop_activity_over_ports: {},
  }
}

///|
fn RoutingSlotAssigner::compute_label_crossing_matrix(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
) -> Array[Array[Bool]] {
  ignore(self)
  let mut label_id = 0
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match sl_loop.get_sl_labels() {
      Some(sl_labels) => {
        sl_labels.set_id(label_id)
        label_id += 1
      }
      None => ()
    }
  }

  let crossing_matrix = routing_slot_assigner_new_label_crossing_matrix(label_id)
  let sl_loops = sl_holder.get_sl_hyper_loops()

  for sl_1_index in 0..<sl_loops.length() {
    let sl_loop_1 = sl_loops[sl_1_index]
    if sl_loop_1.get_sl_labels().is_none() {
      continue
    }
    for sl_2_index in (sl_1_index + 1)..<sl_loops.length() {
      let sl_loop_2 = sl_loops[sl_2_index]
      if sl_loop_2.get_sl_labels().is_none() {
        continue
      }
      let overlap = routing_slot_assigner_labels_overlap(sl_loop_1, sl_loop_2)
      let label_id_1 = match sl_loop_1.get_sl_labels() {
        Some(sl_labels) => sl_labels.get_id()
        None => -1
      }
      let label_id_2 = match sl_loop_2.get_sl_labels() {
        Some(sl_labels) => sl_labels.get_id()
        None => -1
      }
      if label_id_1 >= 0 && label_id_2 >= 0 {
        crossing_matrix[label_id_1][label_id_2] = overlap
        crossing_matrix[label_id_2][label_id_1] = overlap
      }
    }
  }

  crossing_matrix
}

///|
fn RoutingSlotAssigner::compute_loop_activity(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  let sl_loops = sl_holder.get_sl_hyper_loops()
  let l_ports = sl_holder.get_l_node().get_ports()

  self.sl_loop_activity_over_ports.clear()
  for sl_loop in sl_loops {
    let loop_activity = []
    for _ in 0..<l_ports.length() {
      loop_activity.push(false)
    }
    self.sl_loop_activity_over_ports[sl_loop.get_id()] = loop_activity

    let mut l_port_index = match sl_loop.get_leftmost_port() {
      Some(port) => port.get_l_port().get_id() - 1
      None => -1
    }
    let l_port_target_index = match sl_loop.get_rightmost_port() {
      Some(port) => port.get_l_port().get_id()
      None => -1
    }

    while l_port_index != l_port_target_index {
      l_port_index = (l_port_index + 1) % l_ports.length()
      loop_activity[l_port_index] = true
    }
  }
}

///|
fn RoutingSlotAssigner::count_crossings(
  self : RoutingSlotAssigner,
  sl_upper_loop : SelfHyperLoop,
  sl_lower_loop : SelfHyperLoop,
) -> Int {
  ignore(self)
  let lower_loop_activity = routing_slot_assigner_require_loop_activity(
    self.sl_loop_activity_over_ports,
    sl_lower_loop.get_id(),
  )
  let mut crossings = 0
  for sl_port in sl_upper_loop.get_sl_ports() {
    if lower_loop_activity[sl_port.get_l_port().get_id()] {
      crossings += 1
    }
  }
  crossings
}

///|
fn RoutingSlotAssigner::labels_overlap_by_matrix(
  self : RoutingSlotAssigner,
  sl_loop_1 : SelfHyperLoop,
  sl_loop_2 : SelfHyperLoop,
  label_crossing_matrix : Array[Array[Bool]],
) -> Bool {
  ignore(self)
  let labels_1 = match sl_loop_1.get_sl_labels() {
    Some(labels) => labels
    None => return false
  }
  let labels_2 = match sl_loop_2.get_sl_labels() {
    Some(labels) => labels
    None => return false
  }
  label_crossing_matrix[labels_1.get_id()][labels_2.get_id()]
}

///|
fn RoutingSlotAssigner::create_dependencies(
  self : RoutingSlotAssigner,
  sl_loop_1 : SelfHyperLoop,
  sl_loop_2 : SelfHyperLoop,
  label_crossing_matrix : Array[Array[Bool]],
) -> Unit {
  let first_above_second_crossings = self.count_crossings(sl_loop_1, sl_loop_2)
  let second_above_first_crossings = self.count_crossings(sl_loop_2, sl_loop_1)

  let segment_1 = routing_slot_assigner_require_segment(
    self.sl_loop_to_segment_map,
    sl_loop_1.get_id(),
  )
  let segment_2 = routing_slot_assigner_require_segment(
    self.sl_loop_to_segment_map,
    sl_loop_2.get_id(),
  )

  if first_above_second_crossings < second_above_first_crossings {
    ignore(hyper_edge_segment_dependency_create_and_add_regular(
      segment_1,
      segment_2,
      second_above_first_crossings - first_above_second_crossings,
    ))
  } else if second_above_first_crossings < first_above_second_crossings {
    ignore(hyper_edge_segment_dependency_create_and_add_regular(
      segment_2,
      segment_1,
      first_above_second_crossings - second_above_first_crossings,
    ))
  } else if first_above_second_crossings != 0 ||
    self.labels_overlap_by_matrix(sl_loop_1, sl_loop_2, label_crossing_matrix) {
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        segment_1,
        segment_2,
        0,
      ),
    )
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        segment_2,
        segment_1,
        0,
      ),
    )
  }
}

///|
fn RoutingSlotAssigner::create_crossing_graph(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
  label_crossing_matrix : Array[Array[Bool]],
) -> Unit {
  let sl_loops = sl_holder.get_sl_hyper_loops()
  self.hyper_edge_segments.clear()
  self.sl_loop_to_segment_map.clear()

  for index in 0..<sl_loops.length() {
    let sl_loop = sl_loops[index]
    sl_loop.set_id(index)
    let segment = new_hyper_edge_segment(new_west_to_east_routing_strategy())
    self.hyper_edge_segments.push(segment)
    self.sl_loop_to_segment_map[index] = segment
  }

  self.compute_loop_activity(sl_holder)

  for first_index in 0..<sl_loops.length() {
    let sl_loop_1 = sl_loops[first_index]
    for second_index in (first_index + 1)..<sl_loops.length() {
      self.create_dependencies(
        sl_loop_1,
        sl_loops[second_index],
        label_crossing_matrix,
      )
    }
  }
}

///|
fn RoutingSlotAssigner::assign_raw_routing_slots_to_segments(
  self : RoutingSlotAssigner,
) -> Unit {
  let sinks = []

  for segment in self.hyper_edge_segments {
    segment.set_in_weight(segment.get_incoming_segment_dependencies().length())
    segment.set_out_weight(segment.get_outgoing_segment_dependencies().length())

    if segment.get_out_weight() == 0 {
      segment.set_routing_slot(0)
      sinks.push(segment)
    }
  }

  let mut queue_index = 0
  while queue_index < sinks.length() {
    let segment = sinks[queue_index]
    queue_index += 1

    let next_routing_slot = segment.get_routing_slot() + 1
    for in_dependency in segment.get_incoming_segment_dependencies() {
      match in_dependency.get_source() {
        Some(source_segment) => {
          source_segment.set_routing_slot(
            Int::max(source_segment.get_routing_slot(), next_routing_slot),
          )

          source_segment.set_out_weight(source_segment.get_out_weight() - 1)
          if source_segment.get_out_weight() == 0 {
            sinks.push(source_segment)
          }
        }
        None => ()
      }
    }
  }
}

///|
fn RoutingSlotAssigner::assign_raw_routing_slots_to_loops(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    let slot = routing_slot_assigner_require_segment(
      self.sl_loop_to_segment_map,
      sl_loop.get_id(),
    ).get_routing_slot()
    for port_side in sl_loop.get_occupied_port_sides() {
      sl_loop.set_routing_slot(port_side, slot)
    }
  }
}

///|
fn RoutingSlotAssigner::shift_towards_node_on_side(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
  side : PortSide,
  next_free_routing_slot_at_port : Array[Int],
  label_crossing_matrix : Array[Array[Bool]],
) -> Unit {
  let sl_loops = []
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    if routing_slot_assigner_has_side(sl_loop, side) {
      sl_loops.push(sl_loop)
    }
  }
  routing_slot_assigner_sort_loops_by_side_slot(sl_loops, side)

  let mut min_l_port_index = @int.max_value
  let mut max_l_port_index = @int.min_value
  for l_port in sl_holder.get_l_node().get_ports() {
    if routing_slot_assigner_port_side_equals(l_port.get_side(), side) {
      min_l_port_index = Int::min(min_l_port_index, l_port.get_id())
      max_l_port_index = Int::max(max_l_port_index, l_port.get_id())
    }
  }

  if min_l_port_index == @int.max_value {
    for i in 0..<sl_loops.length() {
      sl_loops[i].set_routing_slot(side, i)
    }
  } else {
    let slot_assigned_to_label = []
    for _ in 0..<label_crossing_matrix.length() {
      slot_assigned_to_label.push(-1)
    }

    for sl_loop in sl_loops {
      let active_at_port = routing_slot_assigner_require_loop_activity(
        self.sl_loop_activity_over_ports,
        sl_loop.get_id(),
      )
      let mut lowest_available_slot = 0

      let mut port_index = min_l_port_index
      while port_index <= max_l_port_index {
        if active_at_port[port_index] {
          lowest_available_slot = Int::max(
            lowest_available_slot,
            next_free_routing_slot_at_port[port_index],
          )
        }
        port_index += 1
      }

      match sl_loop.get_sl_labels() {
        Some(sl_labels) => {
          let our_label_index = sl_labels.get_id()
          let slots_with_label_conflicts = []
          for other_label_index in 0..<label_crossing_matrix.length() {
            if label_crossing_matrix[our_label_index][other_label_index] {
              routing_slot_assigner_add_unique_int(
                slots_with_label_conflicts,
                slot_assigned_to_label[other_label_index],
              )
            }
          }
          while routing_slot_assigner_contains_int(
            slots_with_label_conflicts,
            lowest_available_slot,
          ) {
            lowest_available_slot += 1
          }
        }
        None => ()
      }

      sl_loop.set_routing_slot(side, lowest_available_slot)
      let mut port_index = min_l_port_index
      while port_index <= max_l_port_index {
        if active_at_port[port_index] {
          next_free_routing_slot_at_port[port_index] = lowest_available_slot + 1
        }
        port_index += 1
      }

      match sl_loop.get_sl_labels() {
        Some(sl_labels) =>
          slot_assigned_to_label[sl_labels.get_id()] = lowest_available_slot
        None => ()
      }
    }
  }
}

///|
fn RoutingSlotAssigner::shift_towards_node(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
  label_crossing_matrix : Array[Array[Bool]],
) -> Unit {
  let next_free_routing_slot_at_port = []
  for _ in 0..<sl_holder.get_l_node().get_ports().length() {
    next_free_routing_slot_at_port.push(0)
  }

  self.shift_towards_node_on_side(
    sl_holder,
    North,
    next_free_routing_slot_at_port,
    label_crossing_matrix,
  )
  self.shift_towards_node_on_side(
    sl_holder,
    East,
    next_free_routing_slot_at_port,
    label_crossing_matrix,
  )
  self.shift_towards_node_on_side(
    sl_holder,
    South,
    next_free_routing_slot_at_port,
    label_crossing_matrix,
  )
  self.shift_towards_node_on_side(
    sl_holder,
    West,
    next_free_routing_slot_at_port,
    label_crossing_matrix,
  )
}

///|
fn RoutingSlotAssigner::do_assign_routing_slots(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
  label_crossing_matrix : Array[Array[Bool]],
) -> Unit {
  self.assign_raw_routing_slots_to_segments()
  self.assign_raw_routing_slots_to_loops(sl_holder)
  self.shift_towards_node(sl_holder, label_crossing_matrix)
}

///|
pub fn RoutingSlotAssigner::assign_routing_slots(
  self : RoutingSlotAssigner,
  sl_holder : SelfLoopHolder,
) -> Unit {
  let label_crossing_matrix = self.compute_label_crossing_matrix(sl_holder)
  self.create_crossing_graph(sl_holder, label_crossing_matrix)
  orthogonal_routing_generator_break_non_critical_cycles(
    self.hyper_edge_segments,
    orthogonal_routing_generator_graph_random(sl_holder.get_l_node().get_graph()),
  )
  self.do_assign_routing_slots(sl_holder, label_crossing_matrix)

  self.hyper_edge_segments.clear()
  self.sl_loop_to_segment_map.clear()
  self.sl_loop_activity_over_ports.clear()
}
