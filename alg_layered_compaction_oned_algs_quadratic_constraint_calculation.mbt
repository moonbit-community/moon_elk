///|
pub fn layered_quadratic_constraint_calculation(
  compactor : LayeredOneDimensionalCompactor,
) -> Unit {
  quadratic_constraint_calculation(compactor)
}

///|
pub let layered_one_dimensional_compactor_quadratic_constraints : LayeredIConstraintCalculationAlgorithm = layered_quadratic_constraint_calculation
