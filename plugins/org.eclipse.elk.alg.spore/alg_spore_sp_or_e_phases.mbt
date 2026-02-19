///|
pub enum SPOrEPhases {
  P1_STRUCTURE
  P2_PROCESSING_ORDER
  P3_EXECUTION
}

///|
fn spore_phase_ordinal(phase : SPOrEPhases) -> Int {
  match phase {
    P1_STRUCTURE => 0
    P2_PROCESSING_ORDER => 1
    P3_EXECUTION => 2
  }
}

///|
pub let spore_phase_descriptor : PhaseDescriptor[SPOrEPhases] = new_phase_descriptor(
  [
    SPOrEPhases::P1_STRUCTURE,
    SPOrEPhases::P2_PROCESSING_ORDER,
    SPOrEPhases::P3_EXECUTION,
  ],
  spore_phase_ordinal,
)
