///|
pub type RectPackingLayoutPhases = @core.PhaseId

///|
pub const P1_WIDTH_APPROXIMATION : RectPackingLayoutPhases = 0

///|
pub const P2_PACKING : RectPackingLayoutPhases = 1

///|
pub const P3_WHITESPACE_ELIMINATION : RectPackingLayoutPhases = 2

///|
pub let rectpacking_phase_descriptor : @core.PhaseDescriptor = @core.new_phase_descriptor([
    P1_WIDTH_APPROXIMATION,
    P2_PACKING,
    P3_WHITESPACE_ELIMINATION,
  ],
)
