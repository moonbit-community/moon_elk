///|
/// Import this package when constructing the complete layered algorithm.
///
/// The engine package is the composition root for concrete phase packages.
/// Keeping this dependency out of the shared layered package lets each phase
/// depend on the shared graph model without creating an import cycle.
pub let layered_engine_linked : Bool = @cycle.cycle_phase_linked &&
  @layering.layering_phase_linked &&
  @placement.placement_phase_linked
