///|
pub(all) enum PortType {
  Undefined
  Input
  Output
}

///|
pub fn port_type_values() -> Array[PortType] {
  [Undefined, Input, Output]
}
