///|
/// Stable, algorithm-local ordinal for one coarse pipeline phase.
pub type PhaseId = Int

///|
pub(all) struct PhaseDescriptor {
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
