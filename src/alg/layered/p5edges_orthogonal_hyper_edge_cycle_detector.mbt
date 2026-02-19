///|
fn hyper_edge_cycle_detector_is_critical_dependency(
  dependency : HyperEdgeSegmentDependency,
) -> Bool {
  match dependency.get_type() {
    Critical => true
    _ => false
  }
}

///|
fn hyper_edge_cycle_detector_contains_segment(
  segments : Array[HyperEdgeSegment],
  segment : HyperEdgeSegment,
) -> Bool {
  let candidate_handle = segment.get_handle()
  for existing in segments {
    if existing.get_handle() == candidate_handle {
      return true
    }
  }
  false
}

///|
fn hyper_edge_cycle_detector_remove_segment(
  segments : Array[HyperEdgeSegment],
  segment : HyperEdgeSegment,
) -> Unit {
  let candidate_handle = segment.get_handle()
  for i in 0..<segments.length() {
    if segments[i].get_handle() == candidate_handle {
      ignore(segments.remove(i))
      return
    }
  }
}

///|
fn hyper_edge_cycle_detector_add_segment_if_absent(
  segments : Array[HyperEdgeSegment],
  segment : HyperEdgeSegment,
) -> Unit {
  if !hyper_edge_cycle_detector_contains_segment(segments, segment) {
    segments.push(segment)
  }
}

///|
fn hyper_edge_cycle_detector_initialize(
  segments : Array[HyperEdgeSegment],
  sources : Array[HyperEdgeSegment],
  sinks : Array[HyperEdgeSegment],
  critical_only : Bool,
) -> Unit {
  let mut next_mark = -1
  for segment in segments {
    segment.set_mark(next_mark)
    next_mark = next_mark - 1

    let mut critical_in_weight = 0
    let mut critical_out_weight = 0
    let mut in_weight = 0
    let mut out_weight = 0

    for dependency in segment.get_incoming_segment_dependencies() {
      if hyper_edge_cycle_detector_is_critical_dependency(dependency) {
        critical_in_weight = critical_in_weight + dependency.get_weight()
      }
      if !critical_only {
        in_weight = in_weight + dependency.get_weight()
      }
    }
    for dependency in segment.get_outgoing_segment_dependencies() {
      if hyper_edge_cycle_detector_is_critical_dependency(dependency) {
        critical_out_weight = critical_out_weight + dependency.get_weight()
      }
      if !critical_only {
        out_weight = out_weight + dependency.get_weight()
      }
    }

    if critical_only {
      in_weight = critical_in_weight
      out_weight = critical_out_weight
    }

    segment.set_in_weight(in_weight)
    segment.set_critical_in_weight(critical_in_weight)
    segment.set_out_weight(out_weight)
    segment.set_critical_out_weight(critical_out_weight)

    if out_weight == 0 {
      sinks.push(segment)
    } else if in_weight == 0 {
      sources.push(segment)
    }
  }
}

///|
fn hyper_edge_cycle_detector_update_neighbors(
  node : HyperEdgeSegment,
  sources : Array[HyperEdgeSegment],
  sinks : Array[HyperEdgeSegment],
  critical_only : Bool,
) -> Unit {
  for dependency in node.get_outgoing_segment_dependencies() {
    if critical_only &&
      !hyper_edge_cycle_detector_is_critical_dependency(dependency) {
      continue
    }

    let target = dependency.get_target().unwrap()
    if target.get_mark() < 0 && dependency.get_weight() > 0 {
      target.set_in_weight(target.get_in_weight() - dependency.get_weight())
      if hyper_edge_cycle_detector_is_critical_dependency(dependency) {
        target.set_critical_in_weight(
          target.get_critical_in_weight() - dependency.get_weight(),
        )
      }

      if target.get_in_weight() <= 0 && target.get_out_weight() > 0 {
        hyper_edge_cycle_detector_add_segment_if_absent(sources, target)
      }
    }
  }

  for dependency in node.get_incoming_segment_dependencies() {
    if critical_only &&
      !hyper_edge_cycle_detector_is_critical_dependency(dependency) {
      continue
    }

    let source = dependency.get_source().unwrap()
    if source.get_mark() < 0 && dependency.get_weight() > 0 {
      source.set_out_weight(source.get_out_weight() - dependency.get_weight())
      if hyper_edge_cycle_detector_is_critical_dependency(dependency) {
        source.set_critical_out_weight(
          source.get_critical_out_weight() - dependency.get_weight(),
        )
      }

      if source.get_out_weight() <= 0 && source.get_in_weight() > 0 {
        hyper_edge_cycle_detector_add_segment_if_absent(sinks, source)
      }
    }
  }
}

///|
fn hyper_edge_cycle_detector_compute_linear_ordering_marks(
  segments : Array[HyperEdgeSegment],
  sources : Array[HyperEdgeSegment],
  sinks : Array[HyperEdgeSegment],
  critical_only : Bool,
  random : @random.Rand,
) -> Unit {
  let unprocessed = segments.copy()
  let max_segments = []

  let mark_base = segments.length()
  let mut next_sink_mark = mark_base - 1
  let mut next_source_mark = mark_base + 1

  while !unprocessed.is_empty() {
    while !sinks.is_empty() {
      let sink = sinks.remove(0)
      if !hyper_edge_cycle_detector_contains_segment(unprocessed, sink) {
        continue
      }
      hyper_edge_cycle_detector_remove_segment(unprocessed, sink)
      sink.set_mark(next_sink_mark)
      next_sink_mark = next_sink_mark - 1
      hyper_edge_cycle_detector_update_neighbors(
        sink, sources, sinks, critical_only,
      )
    }

    while !sources.is_empty() {
      let source = sources.remove(0)
      if !hyper_edge_cycle_detector_contains_segment(unprocessed, source) {
        continue
      }
      hyper_edge_cycle_detector_remove_segment(unprocessed, source)
      source.set_mark(next_source_mark)
      next_source_mark = next_source_mark + 1
      hyper_edge_cycle_detector_update_neighbors(
        source, sources, sinks, critical_only,
      )
    }

    if !unprocessed.is_empty() {
      let mut max_outflow = -1_000_000_000
      max_segments.clear()

      for segment in unprocessed {
        if !critical_only &&
          segment.get_critical_out_weight() > 0 &&
          segment.get_critical_in_weight() <= 0 {
          max_segments.clear()
          max_segments.push(segment)
          break
        }

        let outflow = segment.get_out_weight() - segment.get_in_weight()
        if outflow >= max_outflow {
          if outflow > max_outflow {
            max_segments.clear()
            max_outflow = outflow
          }
          max_segments.push(segment)
        }
      }

      if !max_segments.is_empty() {
        let max_segment = max_segments[random.int(limit=max_segments.length())]
        hyper_edge_cycle_detector_remove_segment(unprocessed, max_segment)
        max_segment.set_mark(next_source_mark)
        next_source_mark = next_source_mark + 1
        hyper_edge_cycle_detector_update_neighbors(
          max_segment, sources, sinks, critical_only,
        )
        max_segments.clear()
      }
    }
  }

  let shift_base = segments.length() + 1
  for segment in segments {
    if segment.get_mark() < mark_base {
      segment.set_mark(segment.get_mark() + shift_base)
    }
  }
}

///|
pub fn hyper_edge_cycle_detector_detect_cycles(
  segments : Array[HyperEdgeSegment],
  critical_only : Bool,
  random : @random.Rand,
) -> Array[HyperEdgeSegmentDependency] {
  let result = []

  let sources = []
  let sinks = []
  hyper_edge_cycle_detector_initialize(segments, sources, sinks, critical_only)

  hyper_edge_cycle_detector_compute_linear_ordering_marks(
    segments, sources, sinks, critical_only, random,
  )

  for source in segments {
    for dependency in source.get_outgoing_segment_dependencies() {
      if critical_only &&
        !hyper_edge_cycle_detector_is_critical_dependency(dependency) {
        continue
      }

      let target = dependency.get_target().unwrap()
      if source.get_mark() > target.get_mark() {
        result.push(dependency)
      }
    }
  }

  result
}
