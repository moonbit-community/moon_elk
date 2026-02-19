///|
pub struct PhaseDescriptor[P] {
  phases : Array[P]
  ordinal : (P) -> Int
}

///|
pub fn[P] new_phase_descriptor(
  phases : Array[P],
  ordinal : (P) -> Int,
) -> PhaseDescriptor[P] {
  { phases: phases.copy(), ordinal }
}

///|
pub fn[P] PhaseDescriptor::phases(self : PhaseDescriptor[P]) -> Array[P] {
  self.phases.copy()
}

///|
pub fn[P] PhaseDescriptor::ordinal_of(
  self : PhaseDescriptor[P],
  phase : P,
) -> Int {
  (self.ordinal)(phase)
}

///|
pub fn[P] PhaseDescriptor::size(self : PhaseDescriptor[P]) -> Int {
  self.phases.length()
}
