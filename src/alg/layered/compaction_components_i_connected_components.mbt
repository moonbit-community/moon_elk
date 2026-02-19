///|
pub struct IConnectedComponents[N, E] {
  get_components_fn : () -> Array[IComponent[N, E]]
  is_contains_external_extensions_fn : () -> Bool
}

///|
pub fn[N, E] new_connected_components(
  get_components : () -> Array[IComponent[N, E]],
  is_contains_external_extensions : () -> Bool,
) -> IConnectedComponents[N, E] {
  {
    get_components_fn: get_components,
    is_contains_external_extensions_fn: is_contains_external_extensions,
  }
}

///|
pub fn[N, E] IConnectedComponents::get_components(
  self : IConnectedComponents[N, E],
) -> Array[IComponent[N, E]] {
  (self.get_components_fn)()
}

///|
pub fn[N, E] IConnectedComponents::is_contains_external_extensions(
  self : IConnectedComponents[N, E],
) -> Bool {
  (self.is_contains_external_extensions_fn)()
}
