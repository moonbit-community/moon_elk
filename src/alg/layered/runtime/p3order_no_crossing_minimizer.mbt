///|
fn no_crossing_minimizer_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  ignore(graph)
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("No crossing minimization", 1.0))
  monitor.done()
}

///|
fn no_crossing_minimizer_intermediate_processing_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    P3NodeOrdering,
    layered_intermediate_processor_factory(graph, LongEdgeSplitter),
  )
  .add_before(
    P4NodePlacement,
    layered_intermediate_processor_factory(graph, InLayerConstraintProcessor),
  )
  .after(P5EdgeRouting)
  .add(layered_intermediate_processor_factory(graph, LongEdgeJoiner))
}

///|
fn no_crossing_minimizer_default_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  no_crossing_minimizer_intermediate_processing_configuration(graph)
}

///|
fn no_crossing_minimizer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration? raise {
  let configuration = @core.layout_processor_configuration_create_from(
    no_crossing_minimizer_default_configuration(graph),
  )
  ignore(
    configuration.add_before(
      P3NodeOrdering,
      layered_intermediate_processor_factory(graph, PortListSorter),
    ),
  )
  Some(configuration)
}

///|
pub fn new_no_crossing_minimizer_layout_phase() -> @core.TypedLayoutProcessor[
  LGraph,
] {
  @core.new_layout_phase(
    no_crossing_minimizer_process, no_crossing_minimizer_configuration,
  )
}
