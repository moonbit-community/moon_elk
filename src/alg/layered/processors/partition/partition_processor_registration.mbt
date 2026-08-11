///|
fn register_partition_processor(
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
pub fn register_partition_processors(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  register_partition_processor(
    registry,
    PartitionPreprocessor,
    new_partition_preprocessor_layout_processor,
  )
  register_partition_processor(
    registry,
    PartitionMidprocessor,
    new_partition_midprocessor_layout_processor,
  )
  register_partition_processor(
    registry,
    PartitionPostprocessor,
    new_partition_postprocessor_layout_processor,
  )
}
