///|
fn no_crossing_minimizer_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(graph)
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("No crossing minimization", 1.0))
  monitor.done()
}

///|
fn no_crossing_minimizer_intermediate_processing_configuration() -> LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] {
  layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeSplitter,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::InLayerConstraintProcessor,
    ),
  )
  .after(LayeredPhases::P5EdgeRouting)
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeJoiner,
    ),
  )
}

///|
let no_crossing_minimizer_default_configuration : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = no_crossing_minimizer_intermediate_processing_configuration()

///|
fn no_crossing_minimizer_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  let configuration = layout_processor_configuration_create_from(
    no_crossing_minimizer_default_configuration,
  )
  ignore(
    configuration.add_before(
      LayeredPhases::P3NodeOrdering,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::PortListSorter,
      ),
    ),
  )
  Some(configuration)
}

///|
pub fn new_no_crossing_minimizer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    no_crossing_minimizer_process, no_crossing_minimizer_configuration,
  )
}
