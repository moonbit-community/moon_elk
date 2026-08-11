///|
pub struct IProperty[T] {
  id : String
  priv property_id : PropertyId
  default_value : T
  clone_required : Bool
  clone_default_fn : ((T) -> T?)?
}

///|
pub fn[T] IProperty::get_property_id(self : IProperty[T]) -> PropertyId {
  self.property_id
}

///|
pub fn[T] IProperty::get_id(self : IProperty[T]) -> String {
  self.id
}

///|
pub fn[T] IProperty::get_default(self : IProperty[T]) -> T {
  if self.clone_required {
    match self.clone_default_fn {
      Some(clone_default) =>
        match clone_default(self.default_value) {
          Some(cloned) => cloned
          None => self.default_value
        }
      None => self.default_value
    }
  } else {
    self.default_value
  }
}
