///|
pub enum IntermediateProcessorStrategy {
  LongEdgeSplitter
  InLayerConstraintProcessor
  LongEdgeJoiner
  PortListSorter
  ReversedEdgeRestorer
  InteractiveExternalPortPositioner
}

///|
fn intermediate_processor_strategy_ordinal(
  strategy : IntermediateProcessorStrategy,
) -> Int {
  match strategy {
    IntermediateProcessorStrategy::LongEdgeSplitter => 0
    IntermediateProcessorStrategy::InLayerConstraintProcessor => 1
    IntermediateProcessorStrategy::LongEdgeJoiner => 2
    IntermediateProcessorStrategy::PortListSorter => 3
    IntermediateProcessorStrategy::ReversedEdgeRestorer => 4
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner => 5
  }
}

///|
pub fn intermediate_processor_strategy_to_string(
  strategy : IntermediateProcessorStrategy,
) -> String {
  match strategy {
    IntermediateProcessorStrategy::LongEdgeSplitter => "LONG_EDGE_SPLITTER"
    IntermediateProcessorStrategy::InLayerConstraintProcessor =>
      "IN_LAYER_CONSTRAINT_PROCESSOR"
    IntermediateProcessorStrategy::LongEdgeJoiner => "LONG_EDGE_JOINER"
    IntermediateProcessorStrategy::PortListSorter => "PORT_LIST_SORTER"
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      "REVERSED_EDGE_RESTORER"
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner =>
      "INTERACTIVE_EXTERNAL_PORT_POSITIONER"
  }
}

///|
fn intermediate_processor_noop_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(graph)
  ignore(progress_monitor)
}

///|
fn intermediate_processor_create(
  strategy : IntermediateProcessorStrategy,
) -> ILayoutProcessor[LayeredPhases, LGraph] {
  match strategy {
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      new_reversed_edge_restorer_layout_processor()
    _ => new_layout_processor(intermediate_processor_noop_process)
  }
}

///|
pub fn layered_intermediate_processor_factory(
  strategy : IntermediateProcessorStrategy,
) -> ILayoutProcessorFactory[LayeredPhases, LGraph] {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  new_layout_processor_factory(23000 + ordinal, ordinal, () => {
    intermediate_processor_create(strategy)
  })
}
