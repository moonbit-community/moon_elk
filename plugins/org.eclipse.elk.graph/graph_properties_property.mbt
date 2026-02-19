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
