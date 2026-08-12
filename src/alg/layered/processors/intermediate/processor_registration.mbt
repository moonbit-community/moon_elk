///|
fn create_processor(
  strategy : @runtime.IntermediateProcessorStrategy,
  state : @runtime.LayeredRunState,
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  match strategy {
    DirectionPreprocessor => new_direction_preprocessor_layout_processor()
    EdgeAndLayerConstraintEdgeReverser =>
      new_edge_and_layer_constraint_edge_reverser_layout_processor()
    InteractiveExternalPortPositioner =>
      new_interactive_external_port_positioner_layout_processor()
    LabelDummyInserter => new_label_dummy_inserter_layout_processor()
    LayerConstraintPreprocessor =>
      new_layer_constraint_preprocessor_layout_processor()
    HighDegreeNodeLayerProcessor =>
      new_high_degree_node_layering_processor_layout_processor()
    NodePromotion => new_node_promotion_layout_processor()
    LayerConstraintPostprocessor =>
      new_layer_constraint_postprocessor_layout_processor()
    HierarchicalPortConstraintProcessor =>
      new_hierarchical_port_constraint_processor_layout_processor()
    SemiInteractiveCrossMinProcessor =>
      new_semi_interactive_cross_min_processor_layout_processor()
    BreakingPointInserter =>
      new_breaking_point_inserter_layout_processor(state~)
    LongEdgeSplitter => new_long_edge_splitter_layout_processor()
    PortSideProcessor => new_port_side_processor_layout_processor()
    InvertedPortProcessor => new_inverted_port_processor_layout_processor()
    PortListSorter => new_port_list_sorter_layout_processor()
    SortByInputOrderOfModel =>
      new_sort_by_input_model_processor_layout_processor()
    NorthSouthPortPreprocessor =>
      new_north_south_port_preprocessor_layout_processor()
    BreakingPointProcessor =>
      new_breaking_point_processor_layout_processor(state~)
    AlternatingLayerUnzipper =>
      new_alternating_layer_unzipper_layout_processor()
    SingleEdgeGraphWrapper => new_single_edge_graph_wrapper_layout_processor()
    InLayerConstraintProcessor =>
      new_in_layer_constraint_processor_layout_processor()
    EndNodePortLabelManagementProcessor =>
      new_label_management_processor_layout_processor(false)
    EndLabelPreprocessor => new_end_label_preprocessor_layout_processor(state~)
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
    HypernodeProcessor => new_hypernodes_processor_layout_processor()
    LongEdgeJoiner => new_long_edge_joiner_layout_processor()
    BreakingPointRemover => new_breaking_point_remover_layout_processor(state~)
    NorthSouthPortPostprocessor =>
      new_north_south_port_postprocessor_layout_processor()
    HorizontalCompactor =>
      new_horizontal_graph_compactor_layout_processor(state~)
    EndLabelSorter => new_end_label_sorter_layout_processor()
    ReversedEdgeRestorer => new_reversed_edge_restorer_layout_processor()
    EndLabelPostprocessor =>
      new_end_label_postprocessor_layout_processor(state~)
    HierarchicalNodeResizer =>
      new_hierarchical_node_resizing_processor_layout_processor()
    DirectionPostprocessor => new_direction_postprocessor_layout_processor()
    _ => {
      abort(
        "Intermediate processor belongs to another layered package: " +
        @runtime.intermediate_processor_strategy_to_string(strategy),
      )
      @core.new_layout_processor((_, _) => ())
    }
  }
}

///|
pub fn processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
  state? : @runtime.LayeredRunState = @runtime.new_layered_run_state(),
) -> @core.LayoutProcessorFactory {
  let ordinal = @runtime.intermediate_processor_strategy_ordinal(strategy)
  @core.new_layout_processor_factory(23000 + ordinal, ordinal, graph, () => {
    create_processor(strategy, state)
  })
}

///|
pub fn register_processors(registry : @runtime.LayeredPhaseRegistry) -> Unit {
  for strategy in @runtime.intermediate_processor_strategy_values() {
    match strategy {
      CommentPreprocessor
      | CommentNodeMarginCalculator
      | CommentPostprocessor
      | PartitionPreprocessor
      | PartitionMidprocessor
      | PartitionPostprocessor
      | OneSidedGreedySwitch
      | TwoSidedGreedySwitch
      | LabelAndNodeSizeProcessor
      | InnermostNodeMarginCalculator
      | SelfLoopPreprocessor
      | SelfLoopPortRestorer
      | SelfLoopRouter
      | SelfLoopPostprocessor
      | HierarchicalPortOrthogonalEdgeRouter
      | LabelDummyRemover
      | FinalSplineBendpointsCalculator => ()
      _ =>
        registry.register_stateful_intermediate_processor(strategy, state => {
          create_processor(strategy, state)
        })
    }
  }
}
