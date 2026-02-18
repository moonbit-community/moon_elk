///|
pub struct DotPort {
  mut name : String?
  mut compass_pt : String?
}

///|
pub fn dot_create_port() -> DotPort {
  { name: None, compass_pt: None }
}

///|
pub fn DotPort::get_name(self : DotPort) -> String? {
  self.name
}

///|
pub fn DotPort::set_name(self : DotPort, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotPort::get_compass_pt(self : DotPort) -> String? {
  self.compass_pt
}

///|
pub fn DotPort::set_compass_pt(self : DotPort, value : String?) -> Unit {
  self.compass_pt = value
}
