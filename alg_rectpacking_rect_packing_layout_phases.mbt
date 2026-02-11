///|
pub enum RectPackingLayoutPhases {
  P1_WIDTH_APPROXIMATION
  P2_PACKING
  P3_WHITESPACE_ELIMINATION
}

///|
fn rectpacking_layout_phase_ordinal(phase : RectPackingLayoutPhases) -> Int {
  match phase {
    P1_WIDTH_APPROXIMATION => 0
    P2_PACKING => 1
    P3_WHITESPACE_ELIMINATION => 2
  }
}

///|
pub let rectpacking_phase_descriptor : PhaseDescriptor[RectPackingLayoutPhases] = new_phase_descriptor(
  [
    RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
    RectPackingLayoutPhases::P2_PACKING,
    RectPackingLayoutPhases::P3_WHITESPACE_ELIMINATION,
  ],
  rectpacking_layout_phase_ordinal,
)
