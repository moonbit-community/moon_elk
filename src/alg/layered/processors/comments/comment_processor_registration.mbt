///|
fn register_comment_processor(
  strategy : @layered.IntermediateProcessorStrategy,
  create : () -> @core.ILayoutProcessor[@layered.LayeredPhases, @layered.LGraph],
) -> Unit {
  let ordinal = @layered.intermediate_processor_strategy_ordinal(strategy)
  @layered.register_layered_intermediate_processor(
    strategy,
    @core.new_layout_processor_factory(23000 + ordinal, ordinal, create),
  )
}

///|
fn init {
  register_comment_processor(
    @layered.CommentPreprocessor,
    new_comment_preprocessor_layout_processor,
  )
  register_comment_processor(
    @layered.CommentNodeMarginCalculator,
    new_comment_node_margin_calculator_layout_processor,
  )
  register_comment_processor(
    @layered.CommentPostprocessor,
    new_comment_postprocessor_layout_processor,
  )
}

///|
pub let comment_processors_linked : Bool = true
