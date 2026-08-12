///|
/// Stable, zero-based algorithm-local ordinal for one coarse pipeline phase.
pub type PhaseId = Int

///|
/// Declares every phase ordinal once, in execution order.
///
/// The assembler validates that the sequence is exactly `[0, 1, ..., n - 1]`
/// before allocating ordinal-indexed storage. Keeping the representation opaque
/// prevents callers from bypassing `new_phase_descriptor`'s defensive copy.
pub struct PhaseDescriptor {
  phases : Array[PhaseId]
}

///|
pub fn new_phase_descriptor(phases : Array[PhaseId]) -> PhaseDescriptor {
  { phases: phases.copy() }
}

///|
pub fn PhaseDescriptor::phases(self : PhaseDescriptor) -> Array[PhaseId] {
  self.phases.copy()
}

///|
pub fn PhaseDescriptor::size(self : PhaseDescriptor) -> Int {
  self.phases.length()
}

///|
fn PhaseDescriptor::validation_error(self : PhaseDescriptor) -> String? {
  for expected in 0..<self.phases.length() {
    let actual = self.phases[expected]
    if actual != expected {
      return Some(
        "Phase descriptor must contain consecutive zero-based ordinals in declaration order; expected phase \{expected}, found \{actual}.",
      )
    }
  }
  None
}
