///|
pub struct ElkPropertyToValueMapEntryImpl[T] {
  mut key : IProperty[T]?
  mut value : T?
}

///|
pub fn[T] new_elk_property_to_value_map_entry_impl(
  key? : IProperty[T]? = None,
  value? : T? = None,
) -> ElkPropertyToValueMapEntryImpl[T] {
  { key, value }
}

///|
pub fn[T] ElkPropertyToValueMapEntryImpl::get_typed_key(
  self : ElkPropertyToValueMapEntryImpl[T],
) -> IProperty[T]? {
  self.key
}

///|
pub fn[T] ElkPropertyToValueMapEntryImpl::set_typed_key(
  self : ElkPropertyToValueMapEntryImpl[T],
  key : IProperty[T]?,
) -> Unit {
  self.key = key
}

///|
pub fn[T] ElkPropertyToValueMapEntryImpl::get_typed_value(
  self : ElkPropertyToValueMapEntryImpl[T],
) -> T? {
  self.value
}

///|
pub fn[T] ElkPropertyToValueMapEntryImpl::set_typed_value(
  self : ElkPropertyToValueMapEntryImpl[T],
  value : T?,
) -> Unit {
  self.value = value
}
