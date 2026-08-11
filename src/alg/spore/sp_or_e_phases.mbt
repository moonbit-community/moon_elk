///|
pub type SPOrEPhases = @core.PhaseId

///|
pub const P1_STRUCTURE : SPOrEPhases = 0

///|
pub const P2_PROCESSING_ORDER : SPOrEPhases = 1

///|
pub const P3_EXECUTION : SPOrEPhases = 2

///|
pub let spore_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1_STRUCTURE,
    P2_PROCESSING_ORDER,
    P3_EXECUTION,
  ],
)
