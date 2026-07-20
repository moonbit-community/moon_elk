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

///|
fn intermediate_processor_new_greedy_switch_layout_processor(
  cross_min_type : CrossMinType,
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  let minimizer = new_layer_sweep_crossing_minimizer(cross_min_type)
  let long_edge_splitter_factory = @core.new_layout_processor_factory(
    23000 + intermediate_processor_strategy_ordinal(LongEdgeSplitter),
    intermediate_processor_strategy_ordinal(LongEdgeSplitter),
    () => new_long_edge_splitter_layout_processor(),
  )
  let in_layer_constraint_factory = @core.new_layout_processor_factory(
    23000 + intermediate_processor_strategy_ordinal(InLayerConstraintProcessor),
    intermediate_processor_strategy_ordinal(InLayerConstraintProcessor),
    () => new_in_layer_constraint_processor_layout_processor(),
  )
  let long_edge_joiner_factory = @core.new_layout_processor_factory(
    23000 + intermediate_processor_strategy_ordinal(LongEdgeJoiner),
    intermediate_processor_strategy_ordinal(LongEdgeJoiner),
    () => new_long_edge_joiner_layout_processor(),
  )
  let port_list_sorter_factory = @core.new_layout_processor_factory(
    23000 + intermediate_processor_strategy_ordinal(PortListSorter),
    intermediate_processor_strategy_ordinal(PortListSorter),
    () => new_port_list_sorter_layout_processor(),
  )
  @core.new_hierarchy_aware_layout_phase(
    (graph, monitor) => minimizer.process(graph, progress_monitor=monitor),
    graph => {
      ignore(graph)
      let configuration = @core.layout_processor_configuration_create(
        layered_phase_descriptor,
      )
      ignore(
        configuration.add_before(P3NodeOrdering, long_edge_splitter_factory),
      )
      ignore(
        configuration.add_before(P4NodePlacement, in_layer_constraint_factory),
      )
      ignore(configuration.after(P5EdgeRouting))
      ignore(configuration.add(long_edge_joiner_factory))
      ignore(configuration.add_before(P3NodeOrdering, port_list_sorter_factory))
      Some(configuration)
    },
  )
}

///|
fn intermediate_processor_create(
  strategy : IntermediateProcessorStrategy,
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  match strategy {
    DirectionPreprocessor => new_direction_preprocessor_layout_processor()
    CommentPreprocessor => layered_registered_intermediate_processor(strategy)
    EdgeAndLayerConstraintEdgeReverser =>
      new_edge_and_layer_constraint_edge_reverser_layout_processor()
    InteractiveExternalPortPositioner =>
      new_interactive_external_port_positioner_layout_processor()
    PartitionPreprocessor => layered_registered_intermediate_processor(strategy)
    LabelDummyInserter => new_label_dummy_inserter_layout_processor()
    SelfLoopPreprocessor => new_self_loop_pre_processor_layout_processor()
    LayerConstraintPreprocessor =>
      new_layer_constraint_preprocessor_layout_processor()
    PartitionMidprocessor => layered_registered_intermediate_processor(strategy)
    HighDegreeNodeLayerProcessor =>
      new_high_degree_node_layering_processor_layout_processor()
    NodePromotion => new_node_promotion_layout_processor()
    LayerConstraintPostprocessor =>
      new_layer_constraint_postprocessor_layout_processor()
    PartitionPostprocessor =>
      layered_registered_intermediate_processor(strategy)
    HierarchicalPortConstraintProcessor =>
      new_hierarchical_port_constraint_processor_layout_processor()
    SemiInteractiveCrossMinProcessor =>
      new_semi_interactive_cross_min_processor_layout_processor()
    BreakingPointInserter => new_breaking_point_inserter_layout_processor()
    LongEdgeSplitter => new_long_edge_splitter_layout_processor()
    PortSideProcessor => new_port_side_processor_layout_processor()
    InvertedPortProcessor => new_inverted_port_processor_layout_processor()
    PortListSorter => new_port_list_sorter_layout_processor()
    SortByInputOrderOfModel =>
      new_sort_by_input_model_processor_layout_processor()
    NorthSouthPortPreprocessor =>
      new_north_south_port_preprocessor_layout_processor()
    BreakingPointProcessor => new_breaking_point_processor_layout_processor()
    OneSidedGreedySwitch =>
      intermediate_processor_new_greedy_switch_layout_processor(
        OneSidedGreedySwitch,
      )
    TwoSidedGreedySwitch =>
      intermediate_processor_new_greedy_switch_layout_processor(
        TwoSidedGreedySwitch,
      )
    SelfLoopPortRestorer => new_self_loop_port_restorer_layout_processor()
    AlternatingLayerUnzipper =>
      new_alternating_layer_unzipper_layout_processor()
    SingleEdgeGraphWrapper => new_single_edge_graph_wrapper_layout_processor()
    InLayerConstraintProcessor =>
      new_in_layer_constraint_processor_layout_processor()
    EndNodePortLabelManagementProcessor =>
      new_label_management_processor_layout_processor(false)
    LabelAndNodeSizeProcessor =>
      new_label_and_node_size_processor_layout_processor()
    InnermostNodeMarginCalculator =>
      new_innermost_node_margin_calculator_layout_processor()
    SelfLoopRouter => new_self_loop_router_layout_processor()
    CommentNodeMarginCalculator =>
      layered_registered_intermediate_processor(strategy)
    EndLabelPreprocessor => new_end_label_preprocessor_layout_processor()
    LabelDummySwitcher => new_label_dummy_switcher_layout_processor()
    CenterLabelManagementProcessor =>
      new_label_management_processor_layout_processor(true)
    LabelSideSelector => new_label_side_selector_layout_processor()
    HyperedgeDummyMerger => new_hyperedge_dummy_merger_layout_processor()
    HierarchicalPortDummySizeProcessor =>
      new_hierarchical_port_dummy_size_processor_layout_processor()
    LayerSizeAndGraphHeightCalculator =>
      new_layer_size_and_graph_height_calculator_layout_processor()
    HierarchicalPortPositionProcessor =>
      new_hierarchical_port_position_processor_layout_processor()
    ConstraintsPostprocessor => new_constraints_postprocessor_layout_processor()
    CommentPostprocessor => layered_registered_intermediate_processor(strategy)
    HypernodeProcessor => new_hypernodes_processor_layout_processor()
    HierarchicalPortOrthogonalEdgeRouter =>
      new_hierarchical_port_orthogonal_edge_router_layout_processor()
    LongEdgeJoiner => new_long_edge_joiner_layout_processor()
    SelfLoopPostprocessor => new_self_loop_post_processor_layout_processor()
    BreakingPointRemover => new_breaking_point_remover_layout_processor()
    NorthSouthPortPostprocessor =>
      new_north_south_port_postprocessor_layout_processor()
    HorizontalCompactor => new_horizontal_graph_compactor_layout_processor()
    LabelDummyRemover => new_label_dummy_remover_layout_processor()
    FinalSplineBendpointsCalculator =>
      new_final_spline_bendpoints_calculator_layout_processor()
    EndLabelSorter => new_end_label_sorter_layout_processor()
    ReversedEdgeRestorer => new_reversed_edge_restorer_layout_processor()
    EndLabelPostprocessor => new_end_label_postprocessor_layout_processor()
    HierarchicalNodeResizer =>
      new_hierarchical_node_resizing_processor_layout_processor()
    DirectionPostprocessor => new_direction_postprocessor_layout_processor()
  }
}

///|
pub fn layered_intermediate_processor_factory(
  strategy : IntermediateProcessorStrategy,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  let ordinal = intermediate_processor_strategy_ordinal(strategy)
  @core.new_layout_processor_factory(23000 + ordinal, ordinal, () => {
    intermediate_processor_create(strategy)
  })
}
