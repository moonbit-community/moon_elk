///|
pub struct IPropertyValueProxy[T] {
  resolve_value_fn : (IProperty[T]) -> T?
}

///|
pub fn[T] new_property_value_proxy(
  resolve_value_fn : (IProperty[T]) -> T?,
) -> IPropertyValueProxy[T] {
  { resolve_value_fn, }
}

///|
pub fn[T] IPropertyValueProxy::resolve_value(
  self : IPropertyValueProxy[T],
  property : IProperty[T],
) -> T? {
  (self.resolve_value_fn)(property)
}
