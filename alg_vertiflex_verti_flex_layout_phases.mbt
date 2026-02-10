///|
pub enum VertiFlexLayoutPhases {
  P1_NODE_Y_PLACEMENT
  P2_NODE_RELATIVE_PLACEMENT
  P3_NODE_ABSOLUTE_PLACEMENT
  P4_EDGE_ROUTING
}

///|
fn vertiflex_layout_phase_ordinal(phase : VertiFlexLayoutPhases) -> Int {
  match phase {
    P1_NODE_Y_PLACEMENT => 0
    P2_NODE_RELATIVE_PLACEMENT => 1
    P3_NODE_ABSOLUTE_PLACEMENT => 2
    P4_EDGE_ROUTING => 3
  }
}

///|
pub let vertiflex_layout_phase_descriptor : PhaseDescriptor[
  VertiFlexLayoutPhases,
] = new_phase_descriptor(
  [
    VertiFlexLayoutPhases::P1_NODE_Y_PLACEMENT,
    VertiFlexLayoutPhases::P2_NODE_RELATIVE_PLACEMENT,
    VertiFlexLayoutPhases::P3_NODE_ABSOLUTE_PLACEMENT,
    VertiFlexLayoutPhases::P4_EDGE_ROUTING,
  ],
  vertiflex_layout_phase_ordinal,
)
