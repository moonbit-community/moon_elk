///|
pub fn processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
  state : @runtime.LayeredRunState?,
) -> @core.LayoutProcessorFactory {
  let ordinal = @runtime.intermediate_processor_strategy_ordinal(strategy)
  @core.new_layout_processor_factory(23000 + ordinal, ordinal, graph, () => {
    match strategy {
      SelfLoopPreprocessor =>
        new_self_loop_pre_processor_layout_processor(
          state=routing_require_state(strategy, state),
        )
      SelfLoopPortRestorer =>
        new_self_loop_port_restorer_layout_processor(
          state=routing_require_state(strategy, state),
        )
      SelfLoopRouter =>
        new_self_loop_router_layout_processor(
          state=routing_require_state(strategy, state),
        )
      SelfLoopPostprocessor =>
        new_self_loop_post_processor_layout_processor(
          state=routing_require_state(strategy, state),
        )
      HierarchicalPortOrthogonalEdgeRouter =>
        new_hierarchical_port_orthogonal_edge_router_layout_processor(
          state=routing_require_state(strategy, state),
        )
      LabelDummyRemover => new_label_dummy_remover_layout_processor()
      FinalSplineBendpointsCalculator =>
        new_final_spline_bendpoints_calculator_layout_processor(
          state=routing_require_state(strategy, state),
        )
      _ => {
        @core.layout_runtime_raise_unsupported_configuration(
          "Processor is not implemented by edge routing: " +
          @runtime.intermediate_processor_strategy_to_string(strategy),
        )
        @core.new_layout_processor((_, _) => ())
      }
    }
  })
}

///|
fn routing_require_state(
  strategy : @runtime.IntermediateProcessorStrategy,
  state : @runtime.LayeredRunState?,
) -> @runtime.LayeredRunState raise {
  match state {
    Some(value) => value
    None => {
      @core.layout_runtime_raise_unsupported_configuration(
        "Layered run state is required for routing processor " +
        @runtime.intermediate_processor_strategy_to_string(strategy),
      )
      @runtime.new_layered_run_state()
    }
  }
}

///|
fn layered_intermediate_processor_factory(
  graph : @runtime.LGraph,
  strategy : @runtime.IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  match strategy {
    SelfLoopPreprocessor
    | SelfLoopPortRestorer
    | SelfLoopPostprocessor
    | LabelDummyRemover
    | FinalSplineBendpointsCalculator =>
      processor_factory(graph, strategy, None)
    _ => @intermediate.processor_factory(graph, strategy)
  }
}

///|
fn layered_stateful_intermediate_processor_factory(
  graph : @runtime.LGraph,
  state : @runtime.LayeredRunState,
  strategy : @runtime.IntermediateProcessorStrategy,
) -> @core.LayoutProcessorFactory {
  match strategy {
    SelfLoopPreprocessor
    | SelfLoopPortRestorer
    | SelfLoopRouter
    | SelfLoopPostprocessor
    | HierarchicalPortOrthogonalEdgeRouter
    | LabelDummyRemover
    | FinalSplineBendpointsCalculator =>
      processor_factory(graph, strategy, Some(state))
    _ => @intermediate.processor_factory(graph, strategy, state~)
  }
}
