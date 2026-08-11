///|
pub type TopdownPackingPhases = @core.PhaseId

///|
pub const P1_NODE_ARRANGEMENT : TopdownPackingPhases = 0

///|
pub const P2_WHITESPACE_ELIMINATION : TopdownPackingPhases = 1

///|
pub let topdownpacking_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1_NODE_ARRANGEMENT,
    P2_WHITESPACE_ELIMINATION,
  ],
)
