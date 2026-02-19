///|
pub struct DotAttributeStatement {
  mut type_ : DotAttributeType
  attributes : Array[DotAttribute]
}

///|
pub fn dot_create_attribute_statement() -> DotAttributeStatement {
  { type_: DotAttributeTypeGraph, attributes: [] }
}

///|
pub fn DotAttributeStatement::get_type(
  self : DotAttributeStatement,
) -> DotAttributeType {
  self.type_
}

///|
pub fn DotAttributeStatement::set_type(
  self : DotAttributeStatement,
  value : DotAttributeType?,
) -> Unit {
  match value {
    Some(v) => self.type_ = v
    None => self.type_ = DotAttributeTypeGraph
  }
}

///|
pub fn DotAttributeStatement::get_attributes(
  self : DotAttributeStatement,
) -> Array[DotAttribute] {
  self.attributes
}
