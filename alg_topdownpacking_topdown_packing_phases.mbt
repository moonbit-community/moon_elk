///|
pub enum TopdownPackingPhases {
  P1_NODE_ARRANGEMENT
  P2_WHITESPACE_ELIMINATION
}

///|
fn topdownpacking_phase_ordinal(phase : TopdownPackingPhases) -> Int {
  match phase {
    P1_NODE_ARRANGEMENT => 0
    P2_WHITESPACE_ELIMINATION => 1
  }
}

///|
pub let topdownpacking_phase_descriptor : PhaseDescriptor[TopdownPackingPhases] = new_phase_descriptor(
  [
    TopdownPackingPhases::P1_NODE_ARRANGEMENT,
    TopdownPackingPhases::P2_WHITESPACE_ELIMINATION,
  ],
  topdownpacking_phase_ordinal,
)
