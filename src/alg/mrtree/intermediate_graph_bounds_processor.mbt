///|
fn mrtree_graph_bounds_processor_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Process graph bounds", 1.0))
    None => ()
  }
  mrtree_process_graph_bounds(graph)
  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_graph_bounds_processor_layout_processor() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_processor(mrtree_graph_bounds_processor_process)
}
