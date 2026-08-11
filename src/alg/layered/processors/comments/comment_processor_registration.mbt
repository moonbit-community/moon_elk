///|
fn register_comment_processor(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : @runtime.IntermediateProcessorStrategy,
  create : () -> @core.TypedLayoutProcessor[@runtime.LGraph],
) -> Unit {
  registry.register_intermediate_processor(strategy, create)
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
