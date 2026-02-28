///|
pub struct IExternalExtension[E] {
  _instance_id : Int
  get_representative_fn : () -> E
  get_representor_fn : () -> @core.ElkRectangle
  get_placeholder_fn : () -> @core.ElkRectangle?
  get_parent_fn : () -> @core.ElkRectangle
  get_direction_fn : () -> @core.Direction
}

///|
let external_extension_next_instance_id : Ref[Int] = Ref::new(0)

///|
fn new_external_extension_instance_id() -> Int {
  let id = external_extension_next_instance_id.val
  external_extension_next_instance_id.val = id + 1
  id
}

///|
pub fn[E] new_external_extension(
  get_representative : () -> E,
  get_representor : () -> @core.ElkRectangle,
  get_parent : () -> @core.ElkRectangle,
  get_direction : () -> @core.Direction,
  get_placeholder? : () -> @core.ElkRectangle? = () => None,
) -> IExternalExtension[E] {
  {
    _instance_id: new_external_extension_instance_id(),
    get_representative_fn: get_representative,
    get_representor_fn: get_representor,
    get_placeholder_fn: get_placeholder,
    get_parent_fn: get_parent,
    get_direction_fn: get_direction,
  }
}

///|
pub fn[E] IExternalExtension::get_representative(
  self : IExternalExtension[E],
) -> E {
  (self.get_representative_fn)()
}

///|
pub fn[E] IExternalExtension::get_representor(
  self : IExternalExtension[E],
) -> @core.ElkRectangle {
  (self.get_representor_fn)()
}

///|
pub fn[E] IExternalExtension::get_placeholder(
  self : IExternalExtension[E],
) -> @core.ElkRectangle? {
  (self.get_placeholder_fn)()
}

///|
pub fn[E] IExternalExtension::get_parent(
  self : IExternalExtension[E],
) -> @core.ElkRectangle {
  (self.get_parent_fn)()
}

///|
pub fn[E] IExternalExtension::get_direction(
  self : IExternalExtension[E],
) -> @core.Direction {
  (self.get_direction_fn)()
}
