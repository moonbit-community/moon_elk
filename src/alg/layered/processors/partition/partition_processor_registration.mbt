///|
fn register_partition_processor(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : @runtime.IntermediateProcessorStrategy,
  create : () -> @core.TypedLayoutProcessor[@runtime.LGraph],
) -> Unit {
  registry.register_intermediate_processor(strategy, create)
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
