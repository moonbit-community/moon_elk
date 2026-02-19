///|
fn hyper_edge_cycle_detector_test_new_segment() -> HyperEdgeSegment {
  new_hyper_edge_segment(new_west_to_east_routing_strategy())
}

///|
test "HyperEdgeCycleDetector finds one dependency to break a regular two-cycle" {
  let s1 = hyper_edge_cycle_detector_test_new_segment()
  let s2 = hyper_edge_cycle_detector_test_new_segment()
  ignore(hyper_edge_segment_dependency_create_and_add_regular(s1, s2, 1))
  ignore(hyper_edge_segment_dependency_create_and_add_regular(s2, s1, 2))

  let random = @random.Rand::new()
  let cycles = hyper_edge_cycle_detector_detect_cycles([s1, s2], false, random)

  assert_eq(cycles.length(), 1)
  assert_eq(cycles[0].get_weight(), 1)
}

///|
test "HyperEdgeCycleDetector critical-only mode ignores regular dependencies" {
  let s1 = hyper_edge_cycle_detector_test_new_segment()
  let s2 = hyper_edge_cycle_detector_test_new_segment()
  ignore(hyper_edge_segment_dependency_create_and_add_regular(s1, s2, 1))
  ignore(hyper_edge_segment_dependency_create_and_add_regular(s2, s1, 1))

  let random = @random.Rand::new()
  let cycles = hyper_edge_cycle_detector_detect_cycles([s1, s2], true, random)

  assert_eq(cycles.length(), 0)
}

///|
test "HyperEdgeCycleDetector returns critical dependencies in critical mode" {
  let s1 = hyper_edge_cycle_detector_test_new_segment()
  let s2 = hyper_edge_cycle_detector_test_new_segment()
  ignore(hyper_edge_segment_dependency_create_and_add_critical(s1, s2))
  ignore(hyper_edge_segment_dependency_create_and_add_critical(s2, s1))

  let random = @random.Rand::new()
  let cycles = hyper_edge_cycle_detector_detect_cycles([s1, s2], true, random)

  assert_eq(cycles.length(), 1)
  match cycles[0].get_type() {
    Critical => ()
    _ => fail("expected a critical dependency")
  }
}
