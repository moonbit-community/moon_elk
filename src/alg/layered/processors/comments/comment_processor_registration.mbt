///|
fn register_comment_processor(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : @runtime.IntermediateProcessorStrategy,
  create : () -> @core.ILayoutProcessor[@runtime.LayeredPhases, @runtime.LGraph] raise?,
) -> Unit {
  let ordinal = @runtime.intermediate_processor_strategy_ordinal(strategy)
  registry.register_intermediate_processor(
    strategy,
    @core.new_layout_processor_factory(23000 + ordinal, ordinal, fn() raise {
      create()
    }),
  )
}

///|
pub fn register_comment_processors(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  register_comment_processor(
    registry,
    CommentPreprocessor,
    new_comment_preprocessor_layout_processor,
  )
  register_comment_processor(
    registry,
    CommentNodeMarginCalculator,
    new_comment_node_margin_calculator_layout_processor,
  )
  register_comment_processor(
    registry,
    CommentPostprocessor,
    new_comment_postprocessor_layout_processor,
  )
}
