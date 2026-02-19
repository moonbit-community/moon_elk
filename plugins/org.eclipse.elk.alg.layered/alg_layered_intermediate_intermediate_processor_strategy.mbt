///|
pub enum IntermediateProcessorStrategy {
  DirectionPreprocessor
  CommentPreprocessor
  EdgeAndLayerConstraintEdgeReverser
  InteractiveExternalPortPositioner
  PartitionPreprocessor
  LabelDummyInserter
  SelfLoopPreprocessor
  LayerConstraintPreprocessor
  PartitionMidprocessor
  HighDegreeNodeLayerProcessor
  NodePromotion
  LayerConstraintPostprocessor
  PartitionPostprocessor
  HierarchicalPortConstraintProcessor
  SemiInteractiveCrossMinProcessor
  BreakingPointInserter
  LongEdgeSplitter
  PortSideProcessor
  InvertedPortProcessor
  PortListSorter
  SortByInputOrderOfModel
  NorthSouthPortPreprocessor
  BreakingPointProcessor
  OneSidedGreedySwitch
  TwoSidedGreedySwitch
  SelfLoopPortRestorer
  AlternatingLayerUnzipper
  SingleEdgeGraphWrapper
  InLayerConstraintProcessor
  EndNodePortLabelManagementProcessor
  LabelAndNodeSizeProcessor
  InnermostNodeMarginCalculator
  SelfLoopRouter
  CommentNodeMarginCalculator
  EndLabelPreprocessor
  LabelDummySwitcher
  CenterLabelManagementProcessor
  LabelSideSelector
  HyperedgeDummyMerger
  HierarchicalPortDummySizeProcessor
  LayerSizeAndGraphHeightCalculator
  HierarchicalPortPositionProcessor
  ConstraintsPostprocessor
  CommentPostprocessor
  HypernodeProcessor
  HierarchicalPortOrthogonalEdgeRouter
  LongEdgeJoiner
  SelfLoopPostprocessor
  BreakingPointRemover
  NorthSouthPortPostprocessor
  HorizontalCompactor
  LabelDummyRemover
  FinalSplineBendpointsCalculator
  EndLabelSorter
  ReversedEdgeRestorer
  EndLabelPostprocessor
  HierarchicalNodeResizer
  DirectionPostprocessor
}

///|
fn intermediate_processor_strategy_ordinal(
  strategy : IntermediateProcessorStrategy,
) -> Int {
  match strategy {
    IntermediateProcessorStrategy::DirectionPreprocessor => 0
    IntermediateProcessorStrategy::CommentPreprocessor => 1
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser => 2
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner => 3
    IntermediateProcessorStrategy::PartitionPreprocessor => 4
    IntermediateProcessorStrategy::LabelDummyInserter => 5
    IntermediateProcessorStrategy::SelfLoopPreprocessor => 6
    IntermediateProcessorStrategy::LayerConstraintPreprocessor => 7
    IntermediateProcessorStrategy::PartitionMidprocessor => 8
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor => 9
    IntermediateProcessorStrategy::NodePromotion => 10
    IntermediateProcessorStrategy::LayerConstraintPostprocessor => 11
    IntermediateProcessorStrategy::PartitionPostprocessor => 12
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor => 13
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor => 14
    IntermediateProcessorStrategy::BreakingPointInserter => 15
    IntermediateProcessorStrategy::LongEdgeSplitter => 16
    IntermediateProcessorStrategy::PortSideProcessor => 17
    IntermediateProcessorStrategy::InvertedPortProcessor => 18
    IntermediateProcessorStrategy::PortListSorter => 19
    IntermediateProcessorStrategy::SortByInputOrderOfModel => 20
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor => 21
    IntermediateProcessorStrategy::BreakingPointProcessor => 22
    IntermediateProcessorStrategy::OneSidedGreedySwitch => 23
    IntermediateProcessorStrategy::TwoSidedGreedySwitch => 24
    IntermediateProcessorStrategy::SelfLoopPortRestorer => 25
    IntermediateProcessorStrategy::AlternatingLayerUnzipper => 26
    IntermediateProcessorStrategy::SingleEdgeGraphWrapper => 27
    IntermediateProcessorStrategy::InLayerConstraintProcessor => 28
    IntermediateProcessorStrategy::EndNodePortLabelManagementProcessor => 29
    IntermediateProcessorStrategy::LabelAndNodeSizeProcessor => 30
    IntermediateProcessorStrategy::InnermostNodeMarginCalculator => 31
    IntermediateProcessorStrategy::SelfLoopRouter => 32
    IntermediateProcessorStrategy::CommentNodeMarginCalculator => 33
    IntermediateProcessorStrategy::EndLabelPreprocessor => 34
    IntermediateProcessorStrategy::LabelDummySwitcher => 35
    IntermediateProcessorStrategy::CenterLabelManagementProcessor => 36
    IntermediateProcessorStrategy::LabelSideSelector => 37
    IntermediateProcessorStrategy::HyperedgeDummyMerger => 38
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor => 39
    IntermediateProcessorStrategy::LayerSizeAndGraphHeightCalculator => 40
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor => 41
    IntermediateProcessorStrategy::ConstraintsPostprocessor => 42
    IntermediateProcessorStrategy::CommentPostprocessor => 43
    IntermediateProcessorStrategy::HypernodeProcessor => 44
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter => 45
    IntermediateProcessorStrategy::LongEdgeJoiner => 46
    IntermediateProcessorStrategy::SelfLoopPostprocessor => 47
    IntermediateProcessorStrategy::BreakingPointRemover => 48
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor => 49
    IntermediateProcessorStrategy::HorizontalCompactor => 50
    IntermediateProcessorStrategy::LabelDummyRemover => 51
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator => 52
    IntermediateProcessorStrategy::EndLabelSorter => 53
    IntermediateProcessorStrategy::ReversedEdgeRestorer => 54
    IntermediateProcessorStrategy::EndLabelPostprocessor => 55
    IntermediateProcessorStrategy::HierarchicalNodeResizer => 56
    IntermediateProcessorStrategy::DirectionPostprocessor => 57
  }
}

///|
pub fn intermediate_processor_strategy_values() -> Array[
  IntermediateProcessorStrategy,
] {
  [
    DirectionPreprocessor,
    CommentPreprocessor,
    EdgeAndLayerConstraintEdgeReverser,
    InteractiveExternalPortPositioner,
    PartitionPreprocessor,
    LabelDummyInserter,
    SelfLoopPreprocessor,
    LayerConstraintPreprocessor,
    PartitionMidprocessor,
    HighDegreeNodeLayerProcessor,
    NodePromotion,
    LayerConstraintPostprocessor,
    PartitionPostprocessor,
    HierarchicalPortConstraintProcessor,
    SemiInteractiveCrossMinProcessor,
    BreakingPointInserter,
    LongEdgeSplitter,
    PortSideProcessor,
    InvertedPortProcessor,
    PortListSorter,
    SortByInputOrderOfModel,
    NorthSouthPortPreprocessor,
    BreakingPointProcessor,
    OneSidedGreedySwitch,
    TwoSidedGreedySwitch,
    SelfLoopPortRestorer,
    AlternatingLayerUnzipper,
    SingleEdgeGraphWrapper,
    InLayerConstraintProcessor,
    EndNodePortLabelManagementProcessor,
    LabelAndNodeSizeProcessor,
    InnermostNodeMarginCalculator,
    SelfLoopRouter,
    CommentNodeMarginCalculator,
    EndLabelPreprocessor,
    LabelDummySwitcher,
    CenterLabelManagementProcessor,
    LabelSideSelector,
    HyperedgeDummyMerger,
    HierarchicalPortDummySizeProcessor,
    LayerSizeAndGraphHeightCalculator,
    HierarchicalPortPositionProcessor,
    ConstraintsPostprocessor,
    CommentPostprocessor,
    HypernodeProcessor,
    HierarchicalPortOrthogonalEdgeRouter,
    LongEdgeJoiner,
    SelfLoopPostprocessor,
    BreakingPointRemover,
    NorthSouthPortPostprocessor,
    HorizontalCompactor,
    LabelDummyRemover,
    FinalSplineBendpointsCalculator,
    EndLabelSorter,
    ReversedEdgeRestorer,
    EndLabelPostprocessor,
    HierarchicalNodeResizer,
    DirectionPostprocessor,
  ]
}

///|
pub fn intermediate_processor_strategy_to_string(
  strategy : IntermediateProcessorStrategy,
) -> String {
  match strategy {
    IntermediateProcessorStrategy::DirectionPreprocessor =>
      "DIRECTION_PREPROCESSOR"
    IntermediateProcessorStrategy::CommentPreprocessor => "COMMENT_PREPROCESSOR"
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      "EDGE_AND_LAYER_CONSTRAINT_EDGE_REVERSER"
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner =>
      "INTERACTIVE_EXTERNAL_PORT_POSITIONER"
    IntermediateProcessorStrategy::PartitionPreprocessor =>
      "PARTITION_PREPROCESSOR"
    IntermediateProcessorStrategy::LabelDummyInserter => "LABEL_DUMMY_INSERTER"
    IntermediateProcessorStrategy::SelfLoopPreprocessor =>
      "SELF_LOOP_PREPROCESSOR"
    IntermediateProcessorStrategy::LayerConstraintPreprocessor =>
      "LAYER_CONSTRAINT_PREPROCESSOR"
    IntermediateProcessorStrategy::PartitionMidprocessor =>
      "PARTITION_MIDPROCESSOR"
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor =>
      "HIGH_DEGREE_NODE_LAYER_PROCESSOR"
    IntermediateProcessorStrategy::NodePromotion => "NODE_PROMOTION"
    IntermediateProcessorStrategy::LayerConstraintPostprocessor =>
      "LAYER_CONSTRAINT_POSTPROCESSOR"
    IntermediateProcessorStrategy::PartitionPostprocessor =>
      "PARTITION_POSTPROCESSOR"
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor =>
      "HIERARCHICAL_PORT_CONSTRAINT_PROCESSOR"
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor =>
      "SEMI_INTERACTIVE_CROSSMIN_PROCESSOR"
    IntermediateProcessorStrategy::BreakingPointInserter =>
      "BREAKING_POINT_INSERTER"
    IntermediateProcessorStrategy::LongEdgeSplitter => "LONG_EDGE_SPLITTER"
    IntermediateProcessorStrategy::PortSideProcessor => "PORT_SIDE_PROCESSOR"
    IntermediateProcessorStrategy::InvertedPortProcessor =>
      "INVERTED_PORT_PROCESSOR"
    IntermediateProcessorStrategy::PortListSorter => "PORT_LIST_SORTER"
    IntermediateProcessorStrategy::SortByInputOrderOfModel =>
      "SORT_BY_INPUT_ORDER_OF_MODEL"
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor =>
      "NORTH_SOUTH_PORT_PREPROCESSOR"
    IntermediateProcessorStrategy::BreakingPointProcessor =>
      "BREAKING_POINT_PROCESSOR"
    IntermediateProcessorStrategy::OneSidedGreedySwitch =>
      "ONE_SIDED_GREEDY_SWITCH"
    IntermediateProcessorStrategy::TwoSidedGreedySwitch =>
      "TWO_SIDED_GREEDY_SWITCH"
    IntermediateProcessorStrategy::SelfLoopPortRestorer =>
      "SELF_LOOP_PORT_RESTORER"
    IntermediateProcessorStrategy::AlternatingLayerUnzipper =>
      "ALTERNATING_LAYER_UNZIPPER"
    IntermediateProcessorStrategy::SingleEdgeGraphWrapper =>
      "SINGLE_EDGE_GRAPH_WRAPPER"
    IntermediateProcessorStrategy::InLayerConstraintProcessor =>
      "IN_LAYER_CONSTRAINT_PROCESSOR"
    IntermediateProcessorStrategy::EndNodePortLabelManagementProcessor =>
      "END_NODE_PORT_LABEL_MANAGEMENT_PROCESSOR"
    IntermediateProcessorStrategy::LabelAndNodeSizeProcessor =>
      "LABEL_AND_NODE_SIZE_PROCESSOR"
    IntermediateProcessorStrategy::InnermostNodeMarginCalculator =>
      "INNERMOST_NODE_MARGIN_CALCULATOR"
    IntermediateProcessorStrategy::SelfLoopRouter => "SELF_LOOP_ROUTER"
    IntermediateProcessorStrategy::CommentNodeMarginCalculator =>
      "COMMENT_NODE_MARGIN_CALCULATOR"
    IntermediateProcessorStrategy::EndLabelPreprocessor =>
      "END_LABEL_PREPROCESSOR"
    IntermediateProcessorStrategy::LabelDummySwitcher => "LABEL_DUMMY_SWITCHER"
    IntermediateProcessorStrategy::CenterLabelManagementProcessor =>
      "CENTER_LABEL_MANAGEMENT_PROCESSOR"
    IntermediateProcessorStrategy::LabelSideSelector => "LABEL_SIDE_SELECTOR"
    IntermediateProcessorStrategy::HyperedgeDummyMerger =>
      "HYPEREDGE_DUMMY_MERGER"
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor =>
      "HIERARCHICAL_PORT_DUMMY_SIZE_PROCESSOR"
    IntermediateProcessorStrategy::LayerSizeAndGraphHeightCalculator =>
      "LAYER_SIZE_AND_GRAPH_HEIGHT_CALCULATOR"
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor =>
      "HIERARCHICAL_PORT_POSITION_PROCESSOR"
    IntermediateProcessorStrategy::ConstraintsPostprocessor =>
      "CONSTRAINTS_POSTPROCESSOR"
    IntermediateProcessorStrategy::CommentPostprocessor =>
      "COMMENT_POSTPROCESSOR"
    IntermediateProcessorStrategy::HypernodeProcessor => "HYPERNODE_PROCESSOR"
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter =>
      "HIERARCHICAL_PORT_ORTHOGONAL_EDGE_ROUTER"
    IntermediateProcessorStrategy::LongEdgeJoiner => "LONG_EDGE_JOINER"
    IntermediateProcessorStrategy::SelfLoopPostprocessor =>
      "SELF_LOOP_POSTPROCESSOR"
    IntermediateProcessorStrategy::BreakingPointRemover =>
      "BREAKING_POINT_REMOVER"
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor =>
      "NORTH_SOUTH_PORT_POSTPROCESSOR"
    IntermediateProcessorStrategy::HorizontalCompactor => "HORIZONTAL_COMPACTOR"
    IntermediateProcessorStrategy::LabelDummyRemover => "LABEL_DUMMY_REMOVER"
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator =>
      "FINAL_SPLINE_BENDPOINTS_CALCULATOR"
    IntermediateProcessorStrategy::EndLabelSorter => "END_LABEL_SORTER"
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      "REVERSED_EDGE_RESTORER"
    IntermediateProcessorStrategy::EndLabelPostprocessor =>
      "END_LABEL_POSTPROCESSOR"
    IntermediateProcessorStrategy::HierarchicalNodeResizer =>
      "HIERARCHICAL_NODE_RESIZER"
    IntermediateProcessorStrategy::DirectionPostprocessor =>
      "DIRECTION_POSTPROCESSOR"
  }
}

///|
fn intermediate_processor_new_greedy_switch_layout_processor(
  cross_min_type : CrossMinType,
) -> ILayoutProcessor[LayeredPhases, LGraph] {
  let minimizer = new_layer_sweep_crossing_minimizer(cross_min_type)
  new_layout_processor((graph, monitor) => {
    minimizer.process(graph, progress_monitor=monitor)
  })
}

///|
fn intermediate_processor_create(
  strategy : IntermediateProcessorStrategy,
) -> ILayoutProcessor[LayeredPhases, LGraph] {
  match strategy {
    IntermediateProcessorStrategy::DirectionPreprocessor =>
      new_direction_preprocessor_layout_processor()
    IntermediateProcessorStrategy::CommentPreprocessor =>
      new_comment_preprocessor_layout_processor()
    IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser =>
      new_edge_and_layer_constraint_edge_reverser_layout_processor()
    IntermediateProcessorStrategy::InteractiveExternalPortPositioner =>
      new_interactive_external_port_positioner_layout_processor()
    IntermediateProcessorStrategy::PartitionPreprocessor =>
      new_partition_preprocessor_layout_processor()
    IntermediateProcessorStrategy::LabelDummyInserter =>
      new_label_dummy_inserter_layout_processor()
    IntermediateProcessorStrategy::SelfLoopPreprocessor =>
      new_self_loop_pre_processor_layout_processor()
    IntermediateProcessorStrategy::LayerConstraintPreprocessor =>
      new_layer_constraint_preprocessor_layout_processor()
    IntermediateProcessorStrategy::PartitionMidprocessor =>
      new_partition_midprocessor_layout_processor()
    IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor =>
      new_high_degree_node_layering_processor_layout_processor()
    IntermediateProcessorStrategy::NodePromotion =>
      new_node_promotion_layout_processor()
    IntermediateProcessorStrategy::LayerConstraintPostprocessor =>
      new_layer_constraint_postprocessor_layout_processor()
    IntermediateProcessorStrategy::PartitionPostprocessor =>
      new_partition_postprocessor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor =>
      new_hierarchical_port_constraint_processor_layout_processor()
    IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor =>
      new_semi_interactive_cross_min_processor_layout_processor()
    IntermediateProcessorStrategy::BreakingPointInserter =>
      new_breaking_point_inserter_layout_processor()
    IntermediateProcessorStrategy::LongEdgeSplitter =>
      new_long_edge_splitter_layout_processor()
    IntermediateProcessorStrategy::PortSideProcessor =>
      new_port_side_processor_layout_processor()
    IntermediateProcessorStrategy::InvertedPortProcessor =>
      new_inverted_port_processor_layout_processor()
    IntermediateProcessorStrategy::PortListSorter =>
      new_port_list_sorter_layout_processor()
    IntermediateProcessorStrategy::SortByInputOrderOfModel =>
      new_sort_by_input_model_processor_layout_processor()
    IntermediateProcessorStrategy::NorthSouthPortPreprocessor =>
      new_north_south_port_preprocessor_layout_processor()
    IntermediateProcessorStrategy::BreakingPointProcessor =>
      new_breaking_point_processor_layout_processor()
    IntermediateProcessorStrategy::OneSidedGreedySwitch =>
      intermediate_processor_new_greedy_switch_layout_processor(
        CrossMinType::OneSidedGreedySwitch,
      )
    IntermediateProcessorStrategy::TwoSidedGreedySwitch =>
      intermediate_processor_new_greedy_switch_layout_processor(
        CrossMinType::TwoSidedGreedySwitch,
      )
    IntermediateProcessorStrategy::SelfLoopPortRestorer =>
      new_self_loop_port_restorer_layout_processor()
    IntermediateProcessorStrategy::AlternatingLayerUnzipper =>
      new_alternating_layer_unzipper_layout_processor()
    IntermediateProcessorStrategy::SingleEdgeGraphWrapper =>
      new_single_edge_graph_wrapper_layout_processor()
    IntermediateProcessorStrategy::InLayerConstraintProcessor =>
      new_in_layer_constraint_processor_layout_processor()
    IntermediateProcessorStrategy::EndNodePortLabelManagementProcessor =>
      new_label_management_processor_layout_processor(false)
    IntermediateProcessorStrategy::LabelAndNodeSizeProcessor =>
      new_label_and_node_size_processor_layout_processor()
    IntermediateProcessorStrategy::InnermostNodeMarginCalculator =>
      new_innermost_node_margin_calculator_layout_processor()
    IntermediateProcessorStrategy::SelfLoopRouter =>
      new_self_loop_router_layout_processor()
    IntermediateProcessorStrategy::CommentNodeMarginCalculator =>
      new_comment_node_margin_calculator_layout_processor()
    IntermediateProcessorStrategy::EndLabelPreprocessor =>
      new_end_label_preprocessor_layout_processor()
    IntermediateProcessorStrategy::LabelDummySwitcher =>
      new_label_dummy_switcher_layout_processor()
    IntermediateProcessorStrategy::CenterLabelManagementProcessor =>
      new_label_management_processor_layout_processor(true)
    IntermediateProcessorStrategy::LabelSideSelector =>
      new_label_side_selector_layout_processor()
    IntermediateProcessorStrategy::HyperedgeDummyMerger =>
      new_hyperedge_dummy_merger_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor =>
      new_hierarchical_port_dummy_size_processor_layout_processor()
    IntermediateProcessorStrategy::LayerSizeAndGraphHeightCalculator =>
      new_layer_size_and_graph_height_calculator_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortPositionProcessor =>
      new_hierarchical_port_position_processor_layout_processor()
    IntermediateProcessorStrategy::ConstraintsPostprocessor =>
      new_constraints_postprocessor_layout_processor()
    IntermediateProcessorStrategy::CommentPostprocessor =>
      new_comment_postprocessor_layout_processor()
    IntermediateProcessorStrategy::HypernodeProcessor =>
      new_hypernodes_processor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter =>
      new_hierarchical_port_orthogonal_edge_router_layout_processor()
    IntermediateProcessorStrategy::LongEdgeJoiner =>
      new_long_edge_joiner_layout_processor()
    IntermediateProcessorStrategy::SelfLoopPostprocessor =>
      new_self_loop_post_processor_layout_processor()
    IntermediateProcessorStrategy::BreakingPointRemover =>
      new_breaking_point_remover_layout_processor()
    IntermediateProcessorStrategy::NorthSouthPortPostprocessor =>
      new_north_south_port_postprocessor_layout_processor()
    IntermediateProcessorStrategy::HorizontalCompactor =>
      new_horizontal_graph_compactor_layout_processor()
    IntermediateProcessorStrategy::LabelDummyRemover =>
      new_label_dummy_remover_layout_processor()
    IntermediateProcessorStrategy::FinalSplineBendpointsCalculator =>
      new_final_spline_bendpoints_calculator_layout_processor()
    IntermediateProcessorStrategy::EndLabelSorter =>
      new_end_label_sorter_layout_processor()
    IntermediateProcessorStrategy::ReversedEdgeRestorer =>
      new_reversed_edge_restorer_layout_processor()
    IntermediateProcessorStrategy::EndLabelPostprocessor =>
      new_end_label_postprocessor_layout_processor()
    IntermediateProcessorStrategy::HierarchicalNodeResizer =>
      new_hierarchical_node_resizing_processor_layout_processor()
    IntermediateProcessorStrategy::DirectionPostprocessor =>
      new_direction_postprocessor_layout_processor()
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
