///|
fn rectpacking_has_minimum_size_constraint(graph : ElkNode) -> Bool {
  for value in node_get_string_set_property(graph, node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn rectpacking_effective_min_size_constraint_for(graph : ElkNode) -> KVector {
  if !rectpacking_has_minimum_size_constraint(graph) {
    return new_kvector_xy(0.0, 0.0)
  }

  let parsed = new_kvector()
  parsed.parse(node_get_string_property(graph, node_size_minimum))
  parsed
}

///|
fn rectpacking_min_size_pre_processor_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Min Size Preprocessing", 1.0))
    None => ()
  }

  let min_size = rectpacking_effective_min_size_constraint_for(graph)
  node_set_double_property(graph, rectpacking_internal_min_width, min_size.x)
  node_set_double_property(graph, rectpacking_internal_min_height, min_size.y)

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_min_size_pre_processor_layout_processor() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_processor(rectpacking_min_size_pre_processor_process)
}
