///|
pub struct LGraphElement {
  mut id : Int
  mut origin_identifier : String?
}

///|
pub fn new_l_graph_element() -> LGraphElement {
  { id: 0, origin_identifier: None }
}

///|
pub fn LGraphElement::get_id(self : LGraphElement) -> Int {
  self.id
}

///|
pub fn LGraphElement::set_id(self : LGraphElement, id : Int) -> Unit {
  self.id = id
}

///|
pub fn LGraphElement::set_origin_identifier(
  self : LGraphElement,
  identifier : String?,
) -> Unit {
  self.origin_identifier = identifier
}

///|
pub fn LGraphElement::get_origin_identifier(self : LGraphElement) -> String? {
  self.origin_identifier
}

///|
pub fn LGraphElement::get_designation(self : LGraphElement) -> String? {
  match self.origin_identifier {
    Some(identifier) =>
      if identifier.length() > 0 {
        Some(identifier)
      } else {
        None
      }
    None => None
  }
}
