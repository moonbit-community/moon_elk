///|
pub type LayeredPhases = @core.PhaseId

///|
pub const P1CycleBreaking : LayeredPhases = 0

///|
pub const P2Layering : LayeredPhases = 1

///|
pub const P3NodeOrdering : LayeredPhases = 2

///|
pub const P4NodePlacement : LayeredPhases = 3

///|
pub const P5EdgeRouting : LayeredPhases = 4

///|
pub fn layered_phase_constants() -> Array[LayeredPhases] {
  [P1CycleBreaking, P2Layering, P3NodeOrdering, P4NodePlacement, P5EdgeRouting]
}

///|
pub let layered_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor(
  layered_phase_constants(),
)

///|
pub fn layered_phases_to_string(value : LayeredPhases) -> String {
  if value == P1CycleBreaking {
    "P1_CYCLE_BREAKING"
  } else if value == P2Layering {
    "P2_LAYERING"
  } else if value == P3NodeOrdering {
    "P3_NODE_ORDERING"
  } else if value == P4NodePlacement {
    "P4_NODE_PLACEMENT"
  } else {
    "P5_EDGE_ROUTING"
  }
}

///|
pub fn layered_phase_values() -> Array[String] {
  layered_phase_constants().map(layered_phases_to_string)
}
