///|
pub struct DotResourceSetProvider[R] {
  resource_set_provider : () -> R
}

///|
pub fn[R] new_dot_resource_set_provider(
  resource_set_provider : () -> R,
) -> DotResourceSetProvider[R] {
  { resource_set_provider, }
}

///|
pub fn[R] DotResourceSetProvider::create_resource_set(
  self : DotResourceSetProvider[R],
) -> R {
  (self.resource_set_provider)()
}
