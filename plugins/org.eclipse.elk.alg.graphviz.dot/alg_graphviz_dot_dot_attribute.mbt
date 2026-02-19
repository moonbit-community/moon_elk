///|
pub struct DotAttribute {
  mut name : String?
  mut value : String?
}

///|
pub fn dot_create_attribute() -> DotAttribute {
  { name: None, value: None }
}

///|
pub fn DotAttribute::get_name(self : DotAttribute) -> String? {
  self.name
}

///|
pub fn DotAttribute::set_name(self : DotAttribute, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotAttribute::get_value(self : DotAttribute) -> String? {
  self.value
}

///|
pub fn DotAttribute::set_value(self : DotAttribute, value : String?) -> Unit {
  self.value = value
}
