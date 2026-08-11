///|
pub type VertiFlexLayoutPhases = @core.PhaseId

///|
pub const P1_NODE_Y_PLACEMENT : VertiFlexLayoutPhases = 0

///|
pub const P2_NODE_RELATIVE_PLACEMENT : VertiFlexLayoutPhases = 1

///|
pub const P3_NODE_ABSOLUTE_PLACEMENT : VertiFlexLayoutPhases = 2

///|
pub const P4_EDGE_ROUTING : VertiFlexLayoutPhases = 3

///|
pub let vertiflex_layout_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1_NODE_Y_PLACEMENT,
    P2_NODE_RELATIVE_PLACEMENT,
    P3_NODE_ABSOLUTE_PLACEMENT,
    P4_EDGE_ROUTING,
  ],
)
