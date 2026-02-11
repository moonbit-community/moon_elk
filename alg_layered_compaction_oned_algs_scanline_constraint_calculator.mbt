///|
pub fn layered_scanline_constraint_calculation(
  compactor : LayeredOneDimensionalCompactor,
) -> Unit {
  scanline_constraint_calculation(compactor)
}

///|
pub let layered_one_dimensional_compactor_scanline_constraints : LayeredIConstraintCalculationAlgorithm =
  layered_scanline_constraint_calculation
