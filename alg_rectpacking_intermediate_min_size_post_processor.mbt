///|
fn rectpacking_min_size_post_processor_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Min Size Postprocessing", 1.0))
    None => ()
  }

  node_set_double_property(
    graph,
    rectpacking_internal_target_width,
    @cmp.maximum(
      node_get_double_property(graph, rectpacking_internal_target_width),
      node_get_double_property(graph, rectpacking_internal_min_width),
    ),
  )

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_min_size_post_processor_layout_processor() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_processor(rectpacking_min_size_post_processor_process)
}
