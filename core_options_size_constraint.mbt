///|
pub enum SizeConstraint {
  Ports
  PortLabels
  NodeLabels
  MinimumSize
}

///|
pub fn size_constraint_to_string(constraint : SizeConstraint) -> String {
  match constraint {
    Ports => "PORTS"
    PortLabels => "PORT_LABELS"
    NodeLabels => "NODE_LABELS"
    MinimumSize => "MINIMUM_SIZE"
  }
}

///|
pub fn size_constraint_fixed() -> Array[SizeConstraint] {
  []
}

///|
pub fn size_constraint_minimum_size() -> Array[SizeConstraint] {
  [MinimumSize]
}

///|
pub fn size_constraint_minimum_size_with_ports() -> Array[SizeConstraint] {
  [Ports, MinimumSize]
}

///|
pub fn size_constraint_free() -> Array[SizeConstraint] {
  [Ports, PortLabels, NodeLabels, MinimumSize]
}
