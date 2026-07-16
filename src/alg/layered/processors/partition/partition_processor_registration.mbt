///|
fn register_partition_processor(
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
  register_partition_processor(
    @layered.PartitionPreprocessor,
    new_partition_preprocessor_layout_processor,
  )
  register_partition_processor(
    @layered.PartitionMidprocessor,
    new_partition_midprocessor_layout_processor,
  )
  register_partition_processor(
    @layered.PartitionPostprocessor,
    new_partition_postprocessor_layout_processor,
  )
}

///|
pub let partition_processors_linked : Bool = true
