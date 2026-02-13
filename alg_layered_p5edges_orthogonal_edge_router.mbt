///|
fn orthogonal_edge_router_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(layout_processor_configuration_create(layered_phase_descriptor))
}

///|
fn orthogonal_edge_router_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(layered_graph)
  let actual_monitor = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Orthogonal edge routing", 1.0))
  actual_monitor.done()
}

///|
pub fn new_orthogonal_edge_router_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    orthogonal_edge_router_process, orthogonal_edge_router_configuration,
  )
}
