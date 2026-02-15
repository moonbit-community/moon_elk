///|
fn label_and_node_size_processor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Node and Port Label Placement and Node Sizing", 1.0))

  // Java 1:1 main path: delegate sizing/placement to NodeDimensionCalculation.
  // External-port-dummy label placement will be added once nodespacing chain is fully ported.
  node_dimension_calculation_calculate_label_and_node_sizes_for_layered_graph(
    layered_graph,
  )

  monitor.done()
}

///|
pub fn new_label_and_node_size_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(label_and_node_size_processor_process)
}
