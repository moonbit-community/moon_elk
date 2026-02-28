///|
pub enum PortType {
  Undefined
  Input
  Output
}

///|
pub fn port_type_values() -> Array[PortType] {
  [PortType::Undefined, PortType::Input, PortType::Output]
}
