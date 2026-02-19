///|
pub fn layered_longest_path_compaction(
  compactor : LayeredOneDimensionalCompactor,
) -> Unit {
  @common.longest_path_compaction(compactor)
}

///|
pub let layered_one_dimensional_compactor_longest_path_compaction : LayeredICompactionAlgorithm = layered_longest_path_compaction
