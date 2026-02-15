///|
pub enum IntermediateProcessorStrategy {
  LongEdgeSplitter
  InLayerConstraintProcessor
  LongEdgeJoiner
  PortListSorter
  EndLabelSorter
  ReversedEdgeRestorer
  InteractiveExternalPortPositioner
  FinalSplineBendpointsCalculator
  InvertedPortProcessor
  SelfLoopPreprocessor
  HighDegreeNodeLayerProcessor
  SelfLoopPostprocessor
  SelfLoopPortRestorer
  AlternatingLayerUnzipper
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
  HierarchicalPortPositionProcessor
  HierarchicalPortOrthogonalEdgeRouter
  HypernodeProcessor
  EdgeAndLayerConstraintEdgeReverser
  NodePromotion
  SemiInteractiveCrossMinProcessor
}

///|
fn intermediate_processor_strategy_ordinal(
  strategy : IntermediateProcessorStrategy,
) -> Int {
  match strategy {
    IntermediateProcessorStrategy::LongEdgeSplitter => 16
    IntermediateProcessorStrategy::InLayerConstraintProcessor => 28
    IntermediateProcessorStrategy::LongEdgeJoiner => 46
    IntermediateProcessorStrategy::PortListSorter => 19
    IntermediateProcessorStrategy::EndLabelSorter => 53
    IntermediateProcessorStrategy::ReversedEdgeRestorer => 54
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner => 3
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator => 52
    IntermediateProcessorStrategy::InvertedPortProcessor => 18
    IntermediateProcessorStrategy::SelfLoopPreprocessor => 6
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor => 9
    IntermediateProcessorStrategy::SelfLoopPostprocessor => 47
    IntermediateProcessorStrategy::SelfLoopPortRestorer => 25
    IntermediateProcessorStrategy::AlternatingLayerUnzipper => 26
    IntermediateProcessorStrategy::SelfLoopRouter => 32
    IntermediateProcessorStrategy::LabelDummyInserter => 5
    IntermediateProcessorStrategy::LabelDummySwitcher => 35
    IntermediateProcessorStrategy::LabelSideSelector => 37
    IntermediateProcessorStrategy::LabelDummyRemover => 51
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor => 21
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor => 49
    IntermediateProcessorStrategy::EndLabelPreprocessor => 34
    IntermediateProcessorStrategy::EndLabelPostprocessor => 55
    IntermediateProcessorStrategy::HyperedgeDummyMerger => 38
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor => 13
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor => 39
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor => 43
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter => 45
    IntermediateProcessorStrategy::HypernodeProcessor => 44
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser => 2
    IntermediateProcessorStrategy::NodePromotion => 10
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor => 14
  }
}

///|
pub fn intermediate_processor_strategy_values() -> Array[
  IntermediateProcessorStrategy,
] {
  [
    EdgeAndLayerConstraintEdgeReverser,
    InteractiveExternalPortPositioner,
    LabelDummyInserter,
    SelfLoopPreprocessor,
    HighDegreeNodeLayerProcessor,
    NodePromotion,
    HierarchicalPortConstraintProcessor,
    SemiInteractiveCrossMinProcessor,
    LongEdgeSplitter,
    InvertedPortProcessor,
    PortListSorter,
    NorthSouthPortPreprocessor,
    SelfLoopPortRestorer,
    AlternatingLayerUnzipper,
    InLayerConstraintProcessor,
    SelfLoopRouter,
    EndLabelPreprocessor,
    LabelDummySwitcher,
    LabelSideSelector,
    HyperedgeDummyMerger,
    HierarchicalPortDummySizeProcessor,
    HierarchicalPortPositionProcessor,
    HypernodeProcessor,
    HierarchicalPortOrthogonalEdgeRouter,
    LongEdgeJoiner,
    EndLabelSorter,
    SelfLoopPostprocessor,
    NorthSouthPortPostprocessor,
    LabelDummyRemover,
    FinalSplineBendpointsCalculator,
    ReversedEdgeRestorer,
    EndLabelPostprocessor,
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
    IntermediateProcessorStrategy::EndLabelSorter => "END_LABEL_SORTER"
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
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor =>
      "HIGH_DEGREE_NODE_LAYER_PROCESSOR"
    IntermediateProcessorStrategy::SelfLoopPostprocessor =>
      "SELF_LOOP_POSTPROCESSOR"
    IntermediateProcessorStrategy::SelfLoopPortRestorer =>
      "SELF_LOOP_PORT_RESTORER"
    IntermediateProcessorStrategy::AlternatingLayerUnzipper =>
      "ALTERNATING_LAYER_UNZIPPER"
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
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor =>
      "HIERARCHICAL_PORT_POSITION_PROCESSOR"
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter =>
      "HIERARCHICAL_PORT_ORTHOGONAL_EDGE_ROUTER"
    IntermediateProcessorStrategy::HypernodeProcessor => "HYPERNODE_PROCESSOR"
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      "EDGE_AND_LAYER_CONSTRAINT_EDGE_REVERSER"
    IntermediateProcessorStrategy::NodePromotion => "NODE_PROMOTION"
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor =>
      "SEMI_INTERACTIVE_CROSSMIN_PROCESSOR"
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
    IntermediateProcessorStrategy::InLayerConstraintProcessor =>
      new_in_layer_constraint_processor_layout_processor()
    IntermediateProcessorStrategy::LongEdgeJoiner =>
      new_long_edge_joiner_layout_processor()
    IntermediateProcessorStrategy::PortListSorter =>
      new_port_list_sorter_layout_processor()
    IntermediateProcessorStrategy::EndLabelSorter =>
      new_end_label_sorter_layout_processor()
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      new_reversed_edge_restorer_layout_processor()
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner =>
      new_interactive_external_port_positioner_layout_processor()
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator =>
      new_final_spline_bendpoints_calculator_layout_processor()
    IntermediateProcessorStrategy::InvertedPortProcessor =>
      new_inverted_port_processor_layout_processor()
    IntermediateProcessorStrategy::SelfLoopPreprocessor =>
      new_self_loop_pre_processor_layout_processor()
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor =>
      new_high_degree_node_layering_processor_layout_processor()
    IntermediateProcessorStrategy::SelfLoopPostprocessor =>
      new_self_loop_post_processor_layout_processor()
    IntermediateProcessorStrategy::SelfLoopPortRestorer =>
      new_self_loop_port_restorer_layout_processor()
    IntermediateProcessorStrategy::AlternatingLayerUnzipper =>
      new_alternating_layer_unzipper_layout_processor()
    IntermediateProcessorStrategy::SelfLoopRouter =>
      new_self_loop_router_layout_processor()
    IntermediateProcessorStrategy::LabelDummyInserter =>
      new_label_dummy_inserter_layout_processor()
    IntermediateProcessorStrategy::LabelDummySwitcher =>
      new_label_dummy_switcher_layout_processor()
    IntermediateProcessorStrategy::LabelSideSelector =>
      new_label_side_selector_layout_processor()
    IntermediateProcessorStrategy::LabelDummyRemover =>
      new_label_dummy_remover_layout_processor()
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor =>
      new_north_south_port_preprocessor_layout_processor()
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor =>
      new_north_south_port_postprocessor_layout_processor()
    IntermediateProcessorStrategy::EndLabelPreprocessor =>
      new_end_label_preprocessor_layout_processor()
    IntermediateProcessorStrategy::HyperedgeDummyMerger =>
      new_hyperedge_dummy_merger_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor =>
      new_hierarchical_port_constraint_processor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor =>
      new_hierarchical_port_dummy_size_processor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor =>
      new_hierarchical_port_position_processor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter =>
      new_hierarchical_port_orthogonal_edge_router_layout_processor()
    IntermediateProcessorStrategy::HypernodeProcessor =>
      new_hypernodes_processor_layout_processor()
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      new_edge_and_layer_constraint_edge_reverser_layout_processor()
    IntermediateProcessorStrategy::NodePromotion =>
      new_node_promotion_layout_processor()
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor =>
      new_semi_interactive_cross_min_processor_layout_processor()
    IntermediateProcessorStrategy::EndLabelPostprocessor =>
      new_end_label_postprocessor_layout_processor()
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
