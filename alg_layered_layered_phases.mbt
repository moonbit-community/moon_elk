///|
pub enum LayeredPhases {
  P1CycleBreaking
  P2Layering
  P3NodeOrdering
  P4NodePlacement
  P5EdgeRouting
}

///|
fn layered_phase_ordinal(phase : LayeredPhases) -> Int {
  match phase {
    P1CycleBreaking => 0
    P2Layering => 1
    P3NodeOrdering => 2
    P4NodePlacement => 3
    P5EdgeRouting => 4
  }
}

///|
pub fn layered_phase_constants() -> Array[LayeredPhases] {
  [
    LayeredPhases::P1CycleBreaking,
    LayeredPhases::P2Layering,
    LayeredPhases::P3NodeOrdering,
    LayeredPhases::P4NodePlacement,
    LayeredPhases::P5EdgeRouting,
  ]
}

///|
pub let layered_phase_descriptor : PhaseDescriptor[LayeredPhases] = new_phase_descriptor(
  layered_phase_constants(),
  layered_phase_ordinal,
)

///|
pub fn layered_phases_to_string(value : LayeredPhases) -> String {
  match value {
    P1CycleBreaking => "P1_CYCLE_BREAKING"
    P2Layering => "P2_LAYERING"
    P3NodeOrdering => "P3_NODE_ORDERING"
    P4NodePlacement => "P4_NODE_PLACEMENT"
    P5EdgeRouting => "P5_EDGE_ROUTING"
  }
}

///|
pub fn layered_phase_values() -> Array[String] {
  [
    layered_phases_to_string(P1CycleBreaking),
    layered_phases_to_string(P2Layering),
    layered_phases_to_string(P3NodeOrdering),
    layered_phases_to_string(P4NodePlacement),
    layered_phases_to_string(P5EdgeRouting),
  ]
}
