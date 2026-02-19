///|
pub type LayeredOneDimensionalCompactor = OneDimensionalCompactor

///|
pub type LayeredILockFunction = (LayeredCNode, Direction) -> Bool

///|
pub fn new_layered_one_dimensional_compactor(
  c_graph : LayeredCGraph,
) -> LayeredOneDimensionalCompactor {
  let compactor = new_one_dimensional_compactor(c_graph)
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
pub fn LayeredOneDimensionalCompactor::set_locking_strategy(
  self : LayeredOneDimensionalCompactor,
  strategy : LayeredILockFunction,
) -> LayeredOneDimensionalCompactor {
  self.set_lock_function(Some(strategy))
}

///|
pub fn LayeredOneDimensionalCompactor::apply_locking_strategy(
  self : LayeredOneDimensionalCompactor,
) -> LayeredOneDimensionalCompactor {
  self
}

///|
pub fn LayeredOneDimensionalCompactor::apply_locking_strategy_with_direction(
  self : LayeredOneDimensionalCompactor,
  _dir : Direction,
) -> LayeredOneDimensionalCompactor {
  self
}
