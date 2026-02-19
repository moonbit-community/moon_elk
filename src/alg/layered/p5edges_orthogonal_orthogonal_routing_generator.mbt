///|
pub let orthogonal_routing_generator_tolerance : Double = 0.001

///|
let orthogonal_routing_generator_critical_conflicts_detected : Int = -1

///|
let orthogonal_routing_generator_conflict_threshold_factor : Double = 0.5

///|
let orthogonal_routing_generator_critical_conflict_threshold_factor : Double = 0.2

///|
let orthogonal_routing_generator_conflict_penalty : Int = 1

///|
let orthogonal_routing_generator_crossing_penalty : Int = 16

///|
fn orthogonal_routing_generator_sort_doubles(values : Array[Double]) -> Unit {
  let length = values.length()
  for i in 1..<length {
    let current = values[i]
    let mut j = i
    while j > 0 && current < values[j - 1] {
      values[j] = values[j - 1]
      j = j - 1
    }
    values[j] = current
  }
}

///|
fn orthogonal_routing_generator_append_distinct(
  target : Array[Double],
  values : Array[Double],
) -> Unit {
  for value in values {
    let mut exists = false
    for existing in target {
      if existing == value {
        exists = true
        break
      }
    }
    if !exists {
      target.push(value)
    }
  }
}

///|
fn orthogonal_routing_generator_minimum_difference(
  values : Array[Double],
) -> Double {
  let distinct_values = []
  orthogonal_routing_generator_append_distinct(distinct_values, values)
  orthogonal_routing_generator_sort_doubles(distinct_values)

  if distinct_values.length() < 2 {
    return @double.max_value
  }

  let mut min_difference = @double.max_value
  for i in 1..<distinct_values.length() {
    let difference = distinct_values[i] - distinct_values[i - 1]
    if difference < min_difference {
      min_difference = difference
    }
  }
  min_difference
}

///|
pub struct OrthogonalRoutingGenerator {
  mut segment_splitter : HyperEdgeSegmentSplitter?
  routing_strategy : BaseRoutingDirectionStrategy
  edge_spacing : Double
  conflict_threshold : Double
  mut critical_conflict_threshold : Double
  debug_prefix : String?
}

///|
pub fn new_orthogonal_routing_generator(
  direction : RoutingDirection,
  edge_spacing : Double,
  debug_prefix : String?,
) -> OrthogonalRoutingGenerator {
  {
    segment_splitter: None,
    routing_strategy: base_routing_direction_strategy_for_routing_direction(
      direction,
    ),
    edge_spacing,
    conflict_threshold: orthogonal_routing_generator_conflict_threshold_factor *
    edge_spacing,
    critical_conflict_threshold: 0.0,
    debug_prefix,
  }
}

///|
pub fn OrthogonalRoutingGenerator::get_routing_strategy(
  self : OrthogonalRoutingGenerator,
) -> BaseRoutingDirectionStrategy {
  self.routing_strategy
}

///|
pub fn OrthogonalRoutingGenerator::get_edge_spacing(
  self : OrthogonalRoutingGenerator,
) -> Double {
  self.edge_spacing
}

///|
pub fn OrthogonalRoutingGenerator::set_critical_conflict_threshold(
  self : OrthogonalRoutingGenerator,
  threshold : Double,
) -> Unit {
  self.critical_conflict_threshold = threshold
}

///|
pub fn OrthogonalRoutingGenerator::get_critical_conflict_threshold(
  self : OrthogonalRoutingGenerator,
) -> Double {
  self.critical_conflict_threshold
}

///|
fn orthogonal_routing_generator_seeded_random(
  seed_value : Int64,
) -> @random.Rand {
  let seed = @buffer.new()
  seed.write_int64_le(seed_value)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  @random.Rand::chacha8(seed=seed.to_bytes())
}

///|
fn orthogonal_routing_generator_graph_random(
  layered_graph : LGraph,
) -> @random.Rand {
  let use_one = layered_graph.get_property_bool(
    internal_properties_random_next_boolean,
  )
  layered_graph.set_property_bool(
    internal_properties_random_next_boolean,
    !use_one,
  )
  if use_one {
    orthogonal_routing_generator_seeded_random(1)
  } else {
    orthogonal_routing_generator_seeded_random(2)
  }
}

///|
fn OrthogonalRoutingGenerator::create_hyper_edge_segments(
  self : OrthogonalRoutingGenerator,
  nodes : Array[LNode]?,
  port_side : @core.PortSide,
  hyper_edges : Array[HyperEdgeSegment],
  port_to_hyper_edge_segment_map : Map[Int, HyperEdgeSegment],
) -> Unit {
  match nodes {
    Some(layer_nodes) =>
      for node in layer_nodes {
        for port in node.get_ports_by_type_and_side(PortType::Output, port_side) {
          if port_to_hyper_edge_segment_map.contains(port.get_handle()) {
            continue
          }
          let hyper_edge = new_hyper_edge_segment(self.routing_strategy)
          hyper_edges.push(hyper_edge)
          hyper_edge.add_port_positions(port, port_to_hyper_edge_segment_map)
        }
      }
    None => ()
  }
}

///|
fn OrthogonalRoutingGenerator::break_critical_cycles(
  self : OrthogonalRoutingGenerator,
  edge_segments : Array[HyperEdgeSegment],
  random : @random.Rand,
) -> Unit {
  let cycle_dependencies = hyper_edge_cycle_detector_detect_cycles(
    edge_segments, true, random,
  )

  if self.segment_splitter is None {
    self.segment_splitter = Some(new_hyper_edge_segment_splitter(self))
  }

  match self.segment_splitter {
    Some(splitter) =>
      splitter.split_segments(
        cycle_dependencies,
        edge_segments,
        self.critical_conflict_threshold,
      )
    None => ()
  }
}

///|
pub fn OrthogonalRoutingGenerator::route_edges(
  self : OrthogonalRoutingGenerator,
  monitor : @core.IElkProgressMonitor,
  layered_graph : LGraph,
  source_layer_nodes : Array[LNode]?,
  source_layer_index : Int,
  target_layer_nodes : Array[LNode]?,
  start_pos : Double,
) -> Int {
  ignore(monitor)
  ignore(source_layer_index)
  ignore(self.debug_prefix)

  let port_to_edge_segment_map : Map[Int, HyperEdgeSegment] = {}
  let edge_segments = []

  self.create_hyper_edge_segments(
    source_layer_nodes,
    self.routing_strategy.get_source_port_side(),
    edge_segments,
    port_to_edge_segment_map,
  )
  self.create_hyper_edge_segments(
    target_layer_nodes,
    self.routing_strategy.get_target_port_side(),
    edge_segments,
    port_to_edge_segment_map,
  )

  self.critical_conflict_threshold = orthogonal_routing_generator_critical_conflict_threshold_factor *
    self.minimum_horizontal_segment_distance(edge_segments)

  let mut critical_dependency_count = 0
  for first_index in 0..<edge_segments.length() {
    let mut second_index = first_index + 1
    while second_index < edge_segments.length() {
      critical_dependency_count = critical_dependency_count +
        self.create_dependency_if_necessary(
          edge_segments[first_index],
          edge_segments[second_index],
        )
      second_index = second_index + 1
    }
  }

  let random = orthogonal_routing_generator_graph_random(layered_graph)
  if critical_dependency_count >= 2 {
    self.break_critical_cycles(edge_segments, random)
  }
  orthogonal_routing_generator_break_non_critical_cycles(edge_segments, random)
  orthogonal_routing_generator_topological_numbering(edge_segments)

  let mut rank_count = -1
  for node in edge_segments {
    if (node.get_start_coordinate() - node.get_end_coordinate()).abs() <
      orthogonal_routing_generator_tolerance {
      continue
    }

    if node.get_routing_slot() > rank_count {
      rank_count = node.get_routing_slot()
    }
    self.routing_strategy.calculate_bend_points(
      node,
      start_pos,
      self.edge_spacing,
    )
  }

  self.routing_strategy.clear_created_junction_points()
  rank_count + 1
}

///|
pub fn OrthogonalRoutingGenerator::minimum_horizontal_segment_distance(
  _self : OrthogonalRoutingGenerator,
  edge_segments : Array[HyperEdgeSegment],
) -> Double {
  let incoming_values = []
  let outgoing_values = []

  for segment in edge_segments {
    orthogonal_routing_generator_append_distinct(
      incoming_values,
      segment.get_incoming_connection_coordinates(),
    )
    orthogonal_routing_generator_append_distinct(
      outgoing_values,
      segment.get_outgoing_connection_coordinates(),
    )
  }

  let min_incoming_distance = orthogonal_routing_generator_minimum_difference(
    incoming_values,
  )
  let min_outgoing_distance = orthogonal_routing_generator_minimum_difference(
    outgoing_values,
  )

  if min_incoming_distance <= min_outgoing_distance {
    min_incoming_distance
  } else {
    min_outgoing_distance
  }
}

///|
fn OrthogonalRoutingGenerator::count_conflicts(
  self : OrthogonalRoutingGenerator,
  positions_1 : Array[Double],
  positions_2 : Array[Double],
) -> Int {
  let mut conflicts = 0

  if positions_1.is_empty() || positions_2.is_empty() {
    return conflicts
  }

  let mut index_1 = 0
  let mut index_2 = 0
  let mut position_1 = positions_1[index_1]
  let mut position_2 = positions_2[index_2]
  let mut has_more = true

  while has_more {
    if position_1 > position_2 - self.critical_conflict_threshold &&
      position_1 < position_2 + self.critical_conflict_threshold {
      return orthogonal_routing_generator_critical_conflicts_detected
    } else if position_1 > position_2 - self.conflict_threshold &&
      position_1 < position_2 + self.conflict_threshold {
      conflicts = conflicts + 1
    }

    if position_1 <= position_2 && index_1 + 1 < positions_1.length() {
      index_1 = index_1 + 1
      position_1 = positions_1[index_1]
    } else if position_2 <= position_1 && index_2 + 1 < positions_2.length() {
      index_2 = index_2 + 1
      position_2 = positions_2[index_2]
    } else {
      has_more = false
    }
  }

  conflicts
}

///|
pub fn OrthogonalRoutingGenerator::create_dependency_if_necessary(
  self : OrthogonalRoutingGenerator,
  first_segment : HyperEdgeSegment,
  second_segment : HyperEdgeSegment,
) -> Int {
  if (first_segment.get_start_coordinate() - first_segment.get_end_coordinate()).abs() <
    orthogonal_routing_generator_tolerance ||
    (second_segment.get_start_coordinate() - second_segment.get_end_coordinate()).abs() <
    orthogonal_routing_generator_tolerance {
    return 0
  }

  let conflicts_1 = self.count_conflicts(
    first_segment.get_outgoing_connection_coordinates(),
    second_segment.get_incoming_connection_coordinates(),
  )
  let conflicts_2 = self.count_conflicts(
    second_segment.get_outgoing_connection_coordinates(),
    first_segment.get_incoming_connection_coordinates(),
  )

  let critical_conflicts_detected = conflicts_1 ==
    orthogonal_routing_generator_critical_conflicts_detected ||
    conflicts_2 == orthogonal_routing_generator_critical_conflicts_detected

  let mut critical_dependency_count = 0

  if critical_conflicts_detected {
    if conflicts_1 == orthogonal_routing_generator_critical_conflicts_detected {
      ignore(
        hyper_edge_segment_dependency_create_and_add_critical(
          second_segment, first_segment,
        ),
      )
      critical_dependency_count = critical_dependency_count + 1
    }

    if conflicts_2 == orthogonal_routing_generator_critical_conflicts_detected {
      ignore(
        hyper_edge_segment_dependency_create_and_add_critical(
          first_segment, second_segment,
        ),
      )
      critical_dependency_count = critical_dependency_count + 1
    }

    return critical_dependency_count
  }

  let mut crossings_1 = orthogonal_routing_generator_count_crossings(
    first_segment.get_outgoing_connection_coordinates(),
    second_segment.get_start_coordinate(),
    second_segment.get_end_coordinate(),
  )
  crossings_1 = crossings_1 +
    orthogonal_routing_generator_count_crossings(
      second_segment.get_incoming_connection_coordinates(),
      first_segment.get_start_coordinate(),
      first_segment.get_end_coordinate(),
    )

  let mut crossings_2 = orthogonal_routing_generator_count_crossings(
    second_segment.get_outgoing_connection_coordinates(),
    first_segment.get_start_coordinate(),
    first_segment.get_end_coordinate(),
  )
  crossings_2 = crossings_2 +
    orthogonal_routing_generator_count_crossings(
      first_segment.get_incoming_connection_coordinates(),
      second_segment.get_start_coordinate(),
      second_segment.get_end_coordinate(),
    )

  let dependency_value_1 = orthogonal_routing_generator_conflict_penalty *
    conflicts_1 +
    orthogonal_routing_generator_crossing_penalty * crossings_1
  let dependency_value_2 = orthogonal_routing_generator_conflict_penalty *
    conflicts_2 +
    orthogonal_routing_generator_crossing_penalty * crossings_2

  if dependency_value_1 < dependency_value_2 {
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        first_segment,
        second_segment,
        dependency_value_2 - dependency_value_1,
      ),
    )
  } else if dependency_value_1 > dependency_value_2 {
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        second_segment,
        first_segment,
        dependency_value_1 - dependency_value_2,
      ),
    )
  } else if dependency_value_1 > 0 && dependency_value_2 > 0 {
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        first_segment, second_segment, 0,
      ),
    )
    ignore(
      hyper_edge_segment_dependency_create_and_add_regular(
        second_segment, first_segment, 0,
      ),
    )
  }

  0
}

///|
pub fn orthogonal_routing_generator_count_crossings(
  positions : Array[Double],
  start : Double,
  end : Double,
) -> Int {
  let mut crossings = 0
  for position in positions {
    if position > end {
      break
    } else if position >= start {
      crossings = crossings + 1
    }
  }
  crossings
}

///|
pub fn orthogonal_routing_generator_break_non_critical_cycles(
  edge_segments : Array[HyperEdgeSegment],
  random : @random.Rand,
) -> Unit {
  let cycle_dependencies = hyper_edge_cycle_detector_detect_cycles(
    edge_segments, false, random,
  )

  for cycle_dependency in cycle_dependencies {
    if cycle_dependency.get_weight() == 0 {
      cycle_dependency.remove()
    } else {
      cycle_dependency.reverse()
    }
  }
}

///|
pub fn orthogonal_routing_generator_topological_numbering(
  segments : Array[HyperEdgeSegment],
) -> Unit {
  let sources = []
  let rightward_targets = []

  for node in segments {
    node.set_in_weight(node.get_incoming_segment_dependencies().length())
    node.set_out_weight(node.get_outgoing_segment_dependencies().length())

    if node.get_in_weight() == 0 {
      sources.push(node)
    }

    if node.get_out_weight() == 0 &&
      node.get_incoming_connection_coordinates().is_empty() {
      rightward_targets.push(node)
    }
  }

  let mut max_rank = -1
  while !sources.is_empty() {
    let node = sources.remove(0)
    for dependency in node.get_outgoing_segment_dependencies() {
      let target = dependency.get_target().unwrap()
      let candidate_slot = node.get_routing_slot() + 1
      if candidate_slot > target.get_routing_slot() {
        target.set_routing_slot(candidate_slot)
      }
      if target.get_routing_slot() > max_rank {
        max_rank = target.get_routing_slot()
      }

      target.set_in_weight(target.get_in_weight() - 1)
      if target.get_in_weight() == 0 {
        sources.push(target)
      }
    }
  }

  if max_rank > -1 {
    for node in rightward_targets {
      node.set_routing_slot(max_rank)
    }

    while !rightward_targets.is_empty() {
      let node = rightward_targets.remove(0)
      for dependency in node.get_incoming_segment_dependencies() {
        let source = dependency.get_source().unwrap()
        if !source.get_incoming_connection_coordinates().is_empty() {
          continue
        }

        let candidate_slot = node.get_routing_slot() - 1
        if candidate_slot < source.get_routing_slot() {
          source.set_routing_slot(candidate_slot)
        }

        source.set_out_weight(source.get_out_weight() - 1)
        if source.get_out_weight() == 0 {
          rightward_targets.push(source)
        }
      }
    }
  }
}
