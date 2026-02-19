///|
fn rectpacking_has_minimum_size_constraint(graph : @graph.ElkNode) -> Bool {
  for value in @graph.node_get_string_set_property(graph, @core.node_size_constraints) {
    if value == "MINIMUM_SIZE" || value == "MINIMUM_SIZE_WITH_PORTS" {
      return true
    }
  }
  false
}

///|
fn rectpacking_effective_min_size_constraint_for(graph : @graph.ElkNode) -> @core.KVector {
  if !rectpacking_has_minimum_size_constraint(graph) {
    return @core.new_kvector_xy(0.0, 0.0)
  }

  let parsed = @core.new_kvector()
  parsed.parse(@graph.node_get_string_property(graph, @core.node_size_minimum))
  parsed
}

///|
fn rectpacking_min_size_pre_processor_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Min Size Preprocessing", 1.0))
    None => ()
  }

  let min_size = rectpacking_effective_min_size_constraint_for(graph)
  @graph.node_set_double_property(graph, rectpacking_internal_min_width, min_size.x)
  @graph.node_set_double_property(graph, rectpacking_internal_min_height, min_size.y)

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_min_size_pre_processor_layout_processor() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor(rectpacking_min_size_pre_processor_process)
}
