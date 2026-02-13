///|
fn hyper_edge_segment_splitter_test_new_segment(
  incoming : Array[Double],
  outgoing : Array[Double],
) -> HyperEdgeSegment {
  let segment = new_hyper_edge_segment(new_west_to_east_routing_strategy())
  for coordinate in incoming {
    segment.get_incoming_connection_coordinates().push(coordinate)
  }
  for coordinate in outgoing {
    segment.get_outgoing_connection_coordinates().push(coordinate)
  }
  segment.recompute_extent()
  segment
}

///|
fn hyper_edge_segment_splitter_test_contains_dependency(
  source : HyperEdgeSegment,
  target : HyperEdgeSegment,
  critical : Bool,
) -> Bool {
  let target_handle = target.get_handle()
  for dependency in source.get_outgoing_segment_dependencies() {
    let type_matches = match dependency.get_type() {
      DependencyType::Critical => critical
      DependencyType::Regular => !critical
      _ => false
    }
    if !type_matches {
      continue
    }
    match dependency.get_target() {
      Some(candidate_target) =>
        if candidate_target.get_handle() == target_handle {
          return true
        }
      None => ()
    }
  }
  false
}

///|
fn hyper_edge_segment_splitter_test_west_to_east() -> RoutingDirection {
  routing_direction_values()[0]
}

///|
test "HyperEdgeSegmentSplitter splits regular edge when paired with hyperedge" {
  let generator = new_orthogonal_routing_generator(
    hyper_edge_segment_splitter_test_west_to_east(),
    10.0,
    None,
  )
  let splitter = new_hyper_edge_segment_splitter(generator)

  let hyperedge_segment = hyper_edge_segment_splitter_test_new_segment(
    [0.0, 6.0],
    [3.0],
  )
  let regular_segment = hyper_edge_segment_splitter_test_new_segment([2.0], [
    5.0,
  ])
  let dependency = hyper_edge_segment_dependency_create_and_add_critical(
    hyperedge_segment, regular_segment,
  )
  let dependencies_to_resolve = [dependency]
  let segments = [hyperedge_segment, regular_segment]

  splitter.split_segments(dependencies_to_resolve, segments, 0.5)

  assert_eq(segments.length(), 3)
  assert_true(
    hyper_edge_segment_splitter_test_contains_dependency(
      regular_segment, hyperedge_segment, true,
    ),
  )

  match regular_segment.get_split_partner() {
    Some(partner) =>
      assert_true(
        hyper_edge_segment_splitter_test_contains_dependency(
          hyperedge_segment, partner, true,
        ),
      )
    None => fail("expected regular segment to have a split partner")
  }

  match hyperedge_segment.get_split_partner() {
    Some(_) => fail("hyperedge segment should not be split in this case")
    None => ()
  }
}
