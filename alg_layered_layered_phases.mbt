///|
pub enum LayeredPhases {
  P1CycleBreaking
  P2Layering
  P3NodeOrdering
  P4NodePlacement
  P5EdgeRouting
}

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
