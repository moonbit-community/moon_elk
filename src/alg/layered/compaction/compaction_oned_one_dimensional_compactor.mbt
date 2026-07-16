///|
pub type LayeredOneDimensionalCompactor = @common.OneDimensionalCompactor

///|
pub type LayeredILockFunction = (LayeredCNode, @core.Direction) -> Bool

///|
pub fn new_layered_one_dimensional_compactor(
  c_graph : LayeredCGraph,
) -> LayeredOneDimensionalCompactor {
  let compactor = @common.new_one_dimensional_compactor(c_graph)
  ignore(
    compactor.set_compaction_algorithm(
      layered_one_dimensional_compactor_longest_path_compaction,
    ),
  )
  ignore(
    compactor.set_constraint_algorithm(
      layered_one_dimensional_compactor_scanline_constraints,
    ),
  )
  compactor
}

///|
pub fn layered_compactor_set_locking_strategy(
  compactor : LayeredOneDimensionalCompactor,
  strategy : LayeredILockFunction,
) -> LayeredOneDimensionalCompactor {
  compactor.set_lock_function(Some(strategy))
}

///|
pub fn layered_compactor_apply_locking_strategy(
  compactor : LayeredOneDimensionalCompactor,
) -> LayeredOneDimensionalCompactor {
  compactor
}

///|
pub fn layered_compactor_apply_locking_strategy_with_direction(
  compactor : LayeredOneDimensionalCompactor,
  _dir : @core.Direction,
) -> LayeredOneDimensionalCompactor {
  compactor
}
