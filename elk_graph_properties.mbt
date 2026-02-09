///|
pub struct IProperty[T] {
  id : String
  default_value : T
  clone_required : Bool
  clone_default_fn : ((T) -> T?)?
}

///|
pub fn[T] new_property(id : String, default_value : T) -> IProperty[T] {
  { id, default_value, clone_required: false, clone_default_fn: None }
}

///|
pub fn[T] new_property_cloneable(
  id : String,
  default_value : T,
  clone_default_fn : (T) -> T?,
) -> IProperty[T] {
  {
    id,
    default_value,
    clone_required: true,
    clone_default_fn: Some(clone_default_fn),
  }
}

///|
pub fn[T] new_property_cloneable_without_clone(
  id : String,
  default_value : T,
) -> IProperty[T] {
  { id, default_value, clone_required: true, clone_default_fn: None }
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
          None => abort("Couldn't clone property")
        }
      None => abort("Couldn't clone property")
    }
  } else {
    self.default_value
  }
}
