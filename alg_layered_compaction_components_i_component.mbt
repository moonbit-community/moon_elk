///|
pub struct IComponent[N, E] {
  _instance_id : Int
  get_hull_fn : () -> Array[ElkRectangle]
  get_external_extensions_fn : () -> Array[IExternalExtension[E]]
  get_external_extension_sides_fn : () -> Array[PortSide]
}

///|
let component_next_instance_id : Ref[Int] = Ref::new(0)

///|
fn new_component_instance_id() -> Int {
  let id = component_next_instance_id.val
  component_next_instance_id.val = id + 1
  id
}

///|
pub fn[N, E] new_component(
  get_hull : () -> Array[ElkRectangle],
  get_external_extensions : () -> Array[IExternalExtension[E]],
  get_external_extension_sides : () -> Array[PortSide],
) -> IComponent[N, E] {
  {
    _instance_id: new_component_instance_id(),
    get_hull_fn: get_hull,
    get_external_extensions_fn: get_external_extensions,
    get_external_extension_sides_fn: get_external_extension_sides,
  }
}

///|
pub fn[N, E] IComponent::get_hull(self : IComponent[N, E]) -> Array[ElkRectangle] {
  (self.get_hull_fn)()
}

///|
pub fn[N, E] IComponent::get_external_extensions(
  self : IComponent[N, E],
) -> Array[IExternalExtension[E]] {
  (self.get_external_extensions_fn)()
}

///|
pub fn[N, E] IComponent::get_external_extension_sides(
  self : IComponent[N, E],
) -> Array[PortSide] {
  (self.get_external_extension_sides_fn)()
}
