///|
pub(all) enum IntermediateProcessorStrategy {
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
pub fn intermediate_processor_strategy_ordinal(
  strategy : IntermediateProcessorStrategy,
) -> Int {
  match strategy {
    DirectionPreprocessor => 0
    CommentPreprocessor => 1
    EdgeAndLayerConstraintEdgeReverser => 2
    InteractiveExternalPortPositioner => 3
    PartitionPreprocessor => 4
    LabelDummyInserter => 5
    SelfLoopPreprocessor => 6
    LayerConstraintPreprocessor => 7
    PartitionMidprocessor => 8
    HighDegreeNodeLayerProcessor => 9
    NodePromotion => 10
    LayerConstraintPostprocessor => 11
    PartitionPostprocessor => 12
    HierarchicalPortConstraintProcessor => 13
    SemiInteractiveCrossMinProcessor => 14
    BreakingPointInserter => 15
    LongEdgeSplitter => 16
    PortSideProcessor => 17
    InvertedPortProcessor => 18
    PortListSorter => 19
    SortByInputOrderOfModel => 20
    NorthSouthPortPreprocessor => 21
    BreakingPointProcessor => 22
    OneSidedGreedySwitch => 23
    TwoSidedGreedySwitch => 24
    SelfLoopPortRestorer => 25
    AlternatingLayerUnzipper => 26
    SingleEdgeGraphWrapper => 27
    InLayerConstraintProcessor => 28
    EndNodePortLabelManagementProcessor => 29
    LabelAndNodeSizeProcessor => 30
    InnermostNodeMarginCalculator => 31
    SelfLoopRouter => 32
    CommentNodeMarginCalculator => 33
    EndLabelPreprocessor => 34
    LabelDummySwitcher => 35
    CenterLabelManagementProcessor => 36
    LabelSideSelector => 37
    HyperedgeDummyMerger => 38
    HierarchicalPortDummySizeProcessor => 39
    LayerSizeAndGraphHeightCalculator => 40
    HierarchicalPortPositionProcessor => 41
    ConstraintsPostprocessor => 42
    CommentPostprocessor => 43
    HypernodeProcessor => 44
    HierarchicalPortOrthogonalEdgeRouter => 45
    LongEdgeJoiner => 46
    SelfLoopPostprocessor => 47
    BreakingPointRemover => 48
    NorthSouthPortPostprocessor => 49
    HorizontalCompactor => 50
    LabelDummyRemover => 51
    FinalSplineBendpointsCalculator => 52
    EndLabelSorter => 53
    ReversedEdgeRestorer => 54
    EndLabelPostprocessor => 55
    HierarchicalNodeResizer => 56
    DirectionPostprocessor => 57
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
    DirectionPreprocessor => "DIRECTION_PREPROCESSOR"
    CommentPreprocessor => "COMMENT_PREPROCESSOR"
    EdgeAndLayerConstraintEdgeReverser =>
      "EDGE_AND_LAYER_CONSTRAINT_EDGE_REVERSER"
    InteractiveExternalPortPositioner => "INTERACTIVE_EXTERNAL_PORT_POSITIONER"
    PartitionPreprocessor => "PARTITION_PREPROCESSOR"
    LabelDummyInserter => "LABEL_DUMMY_INSERTER"
    SelfLoopPreprocessor => "SELF_LOOP_PREPROCESSOR"
    LayerConstraintPreprocessor => "LAYER_CONSTRAINT_PREPROCESSOR"
    PartitionMidprocessor => "PARTITION_MIDPROCESSOR"
    HighDegreeNodeLayerProcessor => "HIGH_DEGREE_NODE_LAYER_PROCESSOR"
    NodePromotion => "NODE_PROMOTION"
    LayerConstraintPostprocessor => "LAYER_CONSTRAINT_POSTPROCESSOR"
    PartitionPostprocessor => "PARTITION_POSTPROCESSOR"
    HierarchicalPortConstraintProcessor =>
      "HIERARCHICAL_PORT_CONSTRAINT_PROCESSOR"
    SemiInteractiveCrossMinProcessor => "SEMI_INTERACTIVE_CROSSMIN_PROCESSOR"
    BreakingPointInserter => "BREAKING_POINT_INSERTER"
    LongEdgeSplitter => "LONG_EDGE_SPLITTER"
    PortSideProcessor => "PORT_SIDE_PROCESSOR"
    InvertedPortProcessor => "INVERTED_PORT_PROCESSOR"
    PortListSorter => "PORT_LIST_SORTER"
    SortByInputOrderOfModel => "SORT_BY_INPUT_ORDER_OF_MODEL"
    NorthSouthPortPreprocessor => "NORTH_SOUTH_PORT_PREPROCESSOR"
    BreakingPointProcessor => "BREAKING_POINT_PROCESSOR"
    OneSidedGreedySwitch => "ONE_SIDED_GREEDY_SWITCH"
    TwoSidedGreedySwitch => "TWO_SIDED_GREEDY_SWITCH"
    SelfLoopPortRestorer => "SELF_LOOP_PORT_RESTORER"
    AlternatingLayerUnzipper => "ALTERNATING_LAYER_UNZIPPER"
    SingleEdgeGraphWrapper => "SINGLE_EDGE_GRAPH_WRAPPER"
    InLayerConstraintProcessor => "IN_LAYER_CONSTRAINT_PROCESSOR"
    EndNodePortLabelManagementProcessor =>
      "END_NODE_PORT_LABEL_MANAGEMENT_PROCESSOR"
    LabelAndNodeSizeProcessor => "LABEL_AND_NODE_SIZE_PROCESSOR"
    InnermostNodeMarginCalculator => "INNERMOST_NODE_MARGIN_CALCULATOR"
    SelfLoopRouter => "SELF_LOOP_ROUTER"
    CommentNodeMarginCalculator => "COMMENT_NODE_MARGIN_CALCULATOR"
    EndLabelPreprocessor => "END_LABEL_PREPROCESSOR"
    LabelDummySwitcher => "LABEL_DUMMY_SWITCHER"
    CenterLabelManagementProcessor => "CENTER_LABEL_MANAGEMENT_PROCESSOR"
    LabelSideSelector => "LABEL_SIDE_SELECTOR"
    HyperedgeDummyMerger => "HYPEREDGE_DUMMY_MERGER"
    HierarchicalPortDummySizeProcessor =>
      "HIERARCHICAL_PORT_DUMMY_SIZE_PROCESSOR"
    LayerSizeAndGraphHeightCalculator =>
      "LAYER_SIZE_AND_GRAPH_HEIGHT_CALCULATOR"
    HierarchicalPortPositionProcessor => "HIERARCHICAL_PORT_POSITION_PROCESSOR"
    ConstraintsPostprocessor => "CONSTRAINTS_POSTPROCESSOR"
    CommentPostprocessor => "COMMENT_POSTPROCESSOR"
    HypernodeProcessor => "HYPERNODE_PROCESSOR"
    HierarchicalPortOrthogonalEdgeRouter =>
      "HIERARCHICAL_PORT_ORTHOGONAL_EDGE_ROUTER"
    LongEdgeJoiner => "LONG_EDGE_JOINER"
    SelfLoopPostprocessor => "SELF_LOOP_POSTPROCESSOR"
    BreakingPointRemover => "BREAKING_POINT_REMOVER"
    NorthSouthPortPostprocessor => "NORTH_SOUTH_PORT_POSTPROCESSOR"
    HorizontalCompactor => "HORIZONTAL_COMPACTOR"
    LabelDummyRemover => "LABEL_DUMMY_REMOVER"
    FinalSplineBendpointsCalculator => "FINAL_SPLINE_BENDPOINTS_CALCULATOR"
    EndLabelSorter => "END_LABEL_SORTER"
    ReversedEdgeRestorer => "REVERSED_EDGE_RESTORER"
    EndLabelPostprocessor => "END_LABEL_POSTPROCESSOR"
    HierarchicalNodeResizer => "HIERARCHICAL_NODE_RESIZER"
    DirectionPostprocessor => "DIRECTION_POSTPROCESSOR"
  }
}
