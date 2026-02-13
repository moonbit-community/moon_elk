///|
pub enum IntermediateProcessorStrategy {
  LongEdgeSplitter
  InLayerConstraintProcessor
  LongEdgeJoiner
  PortListSorter
  ReversedEdgeRestorer
  InteractiveExternalPortPositioner
  FinalSplineBendpointsCalculator
  InvertedPortProcessor
  SelfLoopPreprocessor
  SelfLoopPostprocessor
  SelfLoopPortRestorer
  SelfLoopRouter
  LabelDummyInserter
  LabelDummySwitcher
  LabelSideSelector
  LabelDummyRemover
  NorthSouthPortPreprocessor
  NorthSouthPortPostprocessor
  EndLabelPreprocessor
  EndLabelPostprocessor
  HyperedgeDummyMerger
  HierarchicalPortConstraintProcessor
  HierarchicalPortDummySizeProcessor
  HierarchicalPortOrthogonalEdgeRouter
  HypernodeProcessor
  EdgeAndLayerConstraintEdgeReverser
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
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator => 6
    IntermediateProcessorStrategy::InvertedPortProcessor => 7
    IntermediateProcessorStrategy::SelfLoopPreprocessor => 8
    IntermediateProcessorStrategy::SelfLoopPostprocessor => 9
    IntermediateProcessorStrategy::SelfLoopPortRestorer => 10
    IntermediateProcessorStrategy::SelfLoopRouter => 11
    IntermediateProcessorStrategy::LabelDummyInserter => 12
    IntermediateProcessorStrategy::LabelDummySwitcher => 13
    IntermediateProcessorStrategy::LabelSideSelector => 14
    IntermediateProcessorStrategy::LabelDummyRemover => 15
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor => 16
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor => 17
    IntermediateProcessorStrategy::EndLabelPreprocessor => 18
    IntermediateProcessorStrategy::EndLabelPostprocessor => 19
    IntermediateProcessorStrategy::HyperedgeDummyMerger => 20
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor => 21
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor => 22
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter => 23
    IntermediateProcessorStrategy::HypernodeProcessor => 24
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser => 25
  }
}

///|
pub fn intermediate_processor_strategy_values() -> Array[
  IntermediateProcessorStrategy,
] {
  [
    LongEdgeSplitter,
    InLayerConstraintProcessor,
    LongEdgeJoiner,
    PortListSorter,
    ReversedEdgeRestorer,
    InteractiveExternalPortPositioner,
    FinalSplineBendpointsCalculator,
    InvertedPortProcessor,
    SelfLoopPreprocessor,
    SelfLoopPostprocessor,
    SelfLoopPortRestorer,
    SelfLoopRouter,
    LabelDummyInserter,
    LabelDummySwitcher,
    LabelSideSelector,
    LabelDummyRemover,
    NorthSouthPortPreprocessor,
    NorthSouthPortPostprocessor,
    EndLabelPreprocessor,
    EndLabelPostprocessor,
    HyperedgeDummyMerger,
    HierarchicalPortConstraintProcessor,
    HierarchicalPortDummySizeProcessor,
    HierarchicalPortOrthogonalEdgeRouter,
    HypernodeProcessor,
    EdgeAndLayerConstraintEdgeReverser,
  ]
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
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator =>
      "FINAL_SPLINE_BENDPOINTS_CALCULATOR"
    IntermediateProcessorStrategy::InvertedPortProcessor =>
      "INVERTED_PORT_PROCESSOR"
    IntermediateProcessorStrategy::SelfLoopPreprocessor =>
      "SELF_LOOP_PREPROCESSOR"
    IntermediateProcessorStrategy::SelfLoopPostprocessor =>
      "SELF_LOOP_POSTPROCESSOR"
    IntermediateProcessorStrategy::SelfLoopPortRestorer =>
      "SELF_LOOP_PORT_RESTORER"
    IntermediateProcessorStrategy::SelfLoopRouter => "SELF_LOOP_ROUTER"
    IntermediateProcessorStrategy::LabelDummyInserter => "LABEL_DUMMY_INSERTER"
    IntermediateProcessorStrategy::LabelDummySwitcher => "LABEL_DUMMY_SWITCHER"
    IntermediateProcessorStrategy::LabelSideSelector => "LABEL_SIDE_SELECTOR"
    IntermediateProcessorStrategy::LabelDummyRemover => "LABEL_DUMMY_REMOVER"
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor =>
      "NORTH_SOUTH_PORT_PREPROCESSOR"
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor =>
      "NORTH_SOUTH_PORT_POSTPROCESSOR"
    IntermediateProcessorStrategy::EndLabelPreprocessor =>
      "END_LABEL_PREPROCESSOR"
    IntermediateProcessorStrategy::EndLabelPostprocessor =>
      "END_LABEL_POSTPROCESSOR"
    IntermediateProcessorStrategy::HyperedgeDummyMerger =>
      "HYPEREDGE_DUMMY_MERGER"
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor =>
      "HIERARCHICAL_PORT_CONSTRAINT_PROCESSOR"
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor =>
      "HIERARCHICAL_PORT_DUMMY_SIZE_PROCESSOR"
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter =>
      "HIERARCHICAL_PORT_ORTHOGONAL_EDGE_ROUTER"
    IntermediateProcessorStrategy::HypernodeProcessor => "HYPERNODE_PROCESSOR"
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      "EDGE_AND_LAYER_CONSTRAINT_EDGE_REVERSER"
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
    IntermediateProcessorStrategy::LongEdgeSplitter =>
      new_long_edge_splitter_layout_processor()
    IntermediateProcessorStrategy::LongEdgeJoiner =>
      new_long_edge_joiner_layout_processor()
    IntermediateProcessorStrategy::PortListSorter =>
      new_port_list_sorter_layout_processor()
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      new_reversed_edge_restorer_layout_processor()
    IntermediateProcessorStrategy::InvertedPortProcessor =>
      new_inverted_port_processor_layout_processor()
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      new_edge_and_layer_constraint_edge_reverser_layout_processor()
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
