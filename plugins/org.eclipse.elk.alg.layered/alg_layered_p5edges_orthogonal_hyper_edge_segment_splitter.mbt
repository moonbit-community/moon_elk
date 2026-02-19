///|
struct HyperEdgeSegmentSplitterFreeArea {
  start_position : Double
  end_position : Double
  size : Double
}

///|
fn new_hyper_edge_segment_splitter_free_area(
  start_position : Double,
  end_position : Double,
) -> HyperEdgeSegmentSplitterFreeArea {
  { start_position, end_position, size: end_position - start_position }
}

///|
struct HyperEdgeSegmentSplitterAreaRating {
  mut dependencies : Int
  mut crossings : Int
}

///|
fn new_hyper_edge_segment_splitter_area_rating(
  dependencies : Int,
  crossings : Int,
) -> HyperEdgeSegmentSplitterAreaRating {
  { dependencies, crossings }
}

///|
fn hyper_edge_segment_splitter_sort_doubles(values : Array[Double]) -> Unit {
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
fn hyper_edge_segment_splitter_sort_segments_by_length(
  values : Array[HyperEdgeSegment],
) -> Unit {
  let length = values.length()
  for i in 1..<length {
    let current = values[i]
    let mut j = i
    while j > 0 && current.get_length() < values[j - 1].get_length() {
      values[j] = values[j - 1]
      j = j - 1
    }
    values[j] = current
  }
}

///|
fn hyper_edge_segment_splitter_contains_segment(
  segments : Array[HyperEdgeSegment],
  segment : HyperEdgeSegment,
) -> Bool {
  let segment_handle = segment.get_handle()
  for existing in segments {
    if existing.get_handle() == segment_handle {
      return true
    }
  }
  false
}

///|
fn hyper_edge_segment_splitter_center_of_positions(
  first : Double,
  second : Double,
) -> Double {
  (first + second) / 2.0
}

///|
fn hyper_edge_segment_splitter_center_of_segment(
  segment : HyperEdgeSegment,
) -> Double {
  hyper_edge_segment_splitter_center_of_positions(
    segment.get_start_coordinate(),
    segment.get_end_coordinate(),
  )
}

///|
fn hyper_edge_segment_splitter_center_of_area(
  area : HyperEdgeSegmentSplitterFreeArea,
) -> Double {
  hyper_edge_segment_splitter_center_of_positions(
    area.start_position,
    area.end_position,
  )
}

///|
pub struct HyperEdgeSegmentSplitter {
  routing_generator : OrthogonalRoutingGenerator
}

///|
pub fn new_hyper_edge_segment_splitter(
  routing_generator : OrthogonalRoutingGenerator,
) -> HyperEdgeSegmentSplitter {
  { routing_generator, }
}

///|
pub fn HyperEdgeSegmentSplitter::split_segments(
  self : HyperEdgeSegmentSplitter,
  dependencies_to_resolve : Array[HyperEdgeSegmentDependency],
  segments : Array[HyperEdgeSegment],
  critical_conflict_threshold : Double,
) -> Unit {
  if dependencies_to_resolve.is_empty() {
    return
  }

  let free_areas = self.find_free_areas(segments, critical_conflict_threshold)
  let segments_to_split = self.decide_which_segments_to_split(
    dependencies_to_resolve,
  )
  hyper_edge_segment_splitter_sort_segments_by_length(segments_to_split)

  for segment in segments_to_split {
    self.split(segment, segments, free_areas, critical_conflict_threshold)
  }
}

///|
fn HyperEdgeSegmentSplitter::find_free_areas(
  self : HyperEdgeSegmentSplitter,
  segments : Array[HyperEdgeSegment],
  critical_conflict_threshold : Double,
) -> Array[HyperEdgeSegmentSplitterFreeArea] {
  let _ = self

  let free_areas = []
  let coordinates = []

  for segment in segments {
    for incoming in segment.get_incoming_connection_coordinates() {
      coordinates.push(incoming)
    }
    for outgoing in segment.get_outgoing_connection_coordinates() {
      coordinates.push(outgoing)
    }
  }

  hyper_edge_segment_splitter_sort_doubles(coordinates)

  for i in 1..<coordinates.length() {
    if coordinates[i] - coordinates[i - 1] >= 2.0 * critical_conflict_threshold {
      free_areas.push(
        new_hyper_edge_segment_splitter_free_area(
          coordinates[i - 1] + critical_conflict_threshold,
          coordinates[i] - critical_conflict_threshold,
        ),
      )
    }
  }

  free_areas
}

///|
fn HyperEdgeSegmentSplitter::decide_which_segments_to_split(
  self : HyperEdgeSegmentSplitter,
  dependencies : Array[HyperEdgeSegmentDependency],
) -> Array[HyperEdgeSegment] {
  let _ = self

  let segments_to_split = []

  for dependency in dependencies {
    let source_segment = dependency.get_source().unwrap()
    let target_segment = dependency.get_target().unwrap()

    if hyper_edge_segment_splitter_contains_segment(
        segments_to_split, source_segment,
      ) ||
      hyper_edge_segment_splitter_contains_segment(
        segments_to_split, target_segment,
      ) {
      continue
    }

    let mut segment_to_split = source_segment
    let mut segment_causing_split = target_segment

    if source_segment.represents_hyperedge() &&
      !target_segment.represents_hyperedge() {
      segment_to_split = target_segment
      segment_causing_split = source_segment
    }

    segments_to_split.push(segment_to_split)
    segment_to_split.set_split_by(Some(segment_causing_split))
  }

  segments_to_split
}

///|
fn HyperEdgeSegmentSplitter::split(
  self : HyperEdgeSegmentSplitter,
  segment : HyperEdgeSegment,
  segments : Array[HyperEdgeSegment],
  free_areas : Array[HyperEdgeSegmentSplitterFreeArea],
  critical_conflict_threshold : Double,
) -> Unit {
  let split_position = self.compute_position_to_split_and_update_free_areas(
    segment, free_areas, critical_conflict_threshold,
  )

  segments.push(segment.split_at(split_position))
  self.update_dependencies(segment, segments)
}

///|
fn HyperEdgeSegmentSplitter::update_dependencies(
  self : HyperEdgeSegmentSplitter,
  segment : HyperEdgeSegment,
  segments : Array[HyperEdgeSegment],
) -> Unit {
  let split_causing_segment = segment.get_split_by().unwrap()
  let split_partner = segment.get_split_partner().unwrap()

  ignore(
    hyper_edge_segment_dependency_create_and_add_critical(
      segment, split_causing_segment,
    ),
  )
  ignore(
    hyper_edge_segment_dependency_create_and_add_critical(
      split_causing_segment, split_partner,
    ),
  )

  let split_causing_handle = split_causing_segment.get_handle()
  let segment_handle = segment.get_handle()
  let split_partner_handle = split_partner.get_handle()

  for other_segment in segments {
    let other_handle = other_segment.get_handle()
    if other_handle != split_causing_handle &&
      other_handle != segment_handle &&
      other_handle != split_partner_handle {
      ignore(
        self.routing_generator.create_dependency_if_necessary(
          other_segment, segment,
        ),
      )
      ignore(
        self.routing_generator.create_dependency_if_necessary(
          other_segment, split_partner,
        ),
      )
    }
  }
}

///|
fn HyperEdgeSegmentSplitter::compute_position_to_split_and_update_free_areas(
  self : HyperEdgeSegmentSplitter,
  segment : HyperEdgeSegment,
  free_areas : Array[HyperEdgeSegmentSplitterFreeArea],
  critical_conflict_threshold : Double,
) -> Double {
  let mut first_possible_area_index = -1
  let mut last_possible_area_index = -1

  for i in 0..<free_areas.length() {
    let current_area = free_areas[i]
    if current_area.start_position > segment.get_end_coordinate() {
      break
    } else if current_area.end_position >= segment.get_start_coordinate() {
      if first_possible_area_index < 0 {
        first_possible_area_index = i
      }
      last_possible_area_index = i
    }
  }

  let mut split_position = hyper_edge_segment_splitter_center_of_segment(
    segment,
  )
  if first_possible_area_index >= 0 {
    let best_area_index = self.choose_best_area_index(
      segment, free_areas, first_possible_area_index, last_possible_area_index,
    )
    split_position = hyper_edge_segment_splitter_center_of_area(
      free_areas[best_area_index],
    )
    self.use_area(free_areas, best_area_index, critical_conflict_threshold)
  }

  split_position
}

///|
fn HyperEdgeSegmentSplitter::choose_best_area_index(
  self : HyperEdgeSegmentSplitter,
  segment : HyperEdgeSegment,
  free_areas : Array[HyperEdgeSegmentSplitterFreeArea],
  from_index : Int,
  to_index : Int,
) -> Int {
  let mut best_area_index = from_index

  if from_index < to_index {
    let split_segments = segment.simulate_split()
    let split_segment = split_segments.get_first().unwrap()
    let split_partner = split_segments.get_second().unwrap()

    let mut best_area = free_areas[best_area_index]
    let mut best_rating = self.rate_area(
      segment, split_segment, split_partner, best_area,
    )

    let mut i = from_index + 1
    while i <= to_index {
      let current_area = free_areas[i]
      let current_rating = self.rate_area(
        segment, split_segment, split_partner, current_area,
      )

      if self.is_better(current_area, current_rating, best_area, best_rating) {
        best_area = current_area
        best_rating = current_rating
        best_area_index = i
      }
      i = i + 1
    }
  }

  best_area_index
}

///|
fn HyperEdgeSegmentSplitter::rate_area(
  self : HyperEdgeSegmentSplitter,
  segment : HyperEdgeSegment,
  split_segment : HyperEdgeSegment,
  split_partner : HyperEdgeSegment,
  area : HyperEdgeSegmentSplitterFreeArea,
) -> HyperEdgeSegmentSplitterAreaRating {
  let area_centre = hyper_edge_segment_splitter_center_of_area(area)
  split_segment.get_outgoing_connection_coordinates().clear()
  split_segment.get_outgoing_connection_coordinates().push(area_centre)
  split_partner.get_incoming_connection_coordinates().clear()
  split_partner.get_incoming_connection_coordinates().push(area_centre)

  let rating = new_hyper_edge_segment_splitter_area_rating(0, 0)

  for dependency in segment.get_incoming_segment_dependencies() {
    let other_segment = dependency.get_source().unwrap()
    self.update_considering_both_orderings(rating, split_segment, other_segment)
    self.update_considering_both_orderings(rating, split_partner, other_segment)
  }

  for dependency in segment.get_outgoing_segment_dependencies() {
    let other_segment = dependency.get_target().unwrap()
    self.update_considering_both_orderings(rating, split_segment, other_segment)
    self.update_considering_both_orderings(rating, split_partner, other_segment)
  }

  let split_by = segment.get_split_by().unwrap()
  rating.dependencies = rating.dependencies + 2
  rating.crossings = rating.crossings +
    self.count_crossings_for_single_ordering(split_segment, split_by)
  rating.crossings = rating.crossings +
    self.count_crossings_for_single_ordering(split_by, split_partner)

  rating
}

///|
fn HyperEdgeSegmentSplitter::update_considering_both_orderings(
  self : HyperEdgeSegmentSplitter,
  rating : HyperEdgeSegmentSplitterAreaRating,
  first_segment : HyperEdgeSegment,
  second_segment : HyperEdgeSegment,
) -> Unit {
  let crossings_first_left = self.count_crossings_for_single_ordering(
    first_segment, second_segment,
  )
  let crossings_second_left = self.count_crossings_for_single_ordering(
    second_segment, first_segment,
  )

  if crossings_first_left == crossings_second_left {
    if crossings_first_left > 0 {
      rating.dependencies = rating.dependencies + 2
      rating.crossings = rating.crossings + crossings_first_left
    }
  } else {
    rating.dependencies = rating.dependencies + 1
    if crossings_first_left <= crossings_second_left {
      rating.crossings = rating.crossings + crossings_first_left
    } else {
      rating.crossings = rating.crossings + crossings_second_left
    }
  }
}

///|
fn HyperEdgeSegmentSplitter::count_crossings_for_single_ordering(
  self : HyperEdgeSegmentSplitter,
  left_segment : HyperEdgeSegment,
  right_segment : HyperEdgeSegment,
) -> Int {
  let _ = self
  orthogonal_routing_generator_count_crossings(
    left_segment.get_outgoing_connection_coordinates(),
    right_segment.get_start_coordinate(),
    right_segment.get_end_coordinate(),
  ) +
  orthogonal_routing_generator_count_crossings(
    right_segment.get_incoming_connection_coordinates(),
    left_segment.get_start_coordinate(),
    left_segment.get_end_coordinate(),
  )
}

///|
fn HyperEdgeSegmentSplitter::is_better(
  self : HyperEdgeSegmentSplitter,
  current_area : HyperEdgeSegmentSplitterFreeArea,
  current_rating : HyperEdgeSegmentSplitterAreaRating,
  best_area : HyperEdgeSegmentSplitterFreeArea,
  best_rating : HyperEdgeSegmentSplitterAreaRating,
) -> Bool {
  let _ = self

  if current_rating.crossings < best_rating.crossings {
    true
  } else if current_rating.crossings == best_rating.crossings {
    if current_rating.dependencies < best_rating.dependencies {
      true
    } else if current_rating.dependencies == best_rating.dependencies {
      current_area.size > best_area.size
    } else {
      false
    }
  } else {
    false
  }
}

///|
fn HyperEdgeSegmentSplitter::use_area(
  self : HyperEdgeSegmentSplitter,
  free_areas : Array[HyperEdgeSegmentSplitterFreeArea],
  used_area_index : Int,
  critical_conflict_threshold : Double,
) -> Unit {
  let _ = self
  let old_area = free_areas[used_area_index]
  ignore(free_areas.remove(used_area_index))

  if old_area.size / 2.0 >= critical_conflict_threshold {
    let mut insert_index = used_area_index
    let old_area_centre = hyper_edge_segment_splitter_center_of_area(old_area)

    let new_end_1 = old_area_centre - critical_conflict_threshold
    if old_area.start_position <= old_area_centre - critical_conflict_threshold {
      ignore(
        free_areas.insert(
          insert_index,
          new_hyper_edge_segment_splitter_free_area(
            old_area.start_position,
            new_end_1,
          ),
        ),
      )
      insert_index = insert_index + 1
    }

    let new_start_2 = old_area_centre + critical_conflict_threshold
    if new_start_2 <= old_area.end_position {
      ignore(
        free_areas.insert(
          insert_index,
          new_hyper_edge_segment_splitter_free_area(
            new_start_2,
            old_area.end_position,
          ),
        ),
      )
    }
  }
}
