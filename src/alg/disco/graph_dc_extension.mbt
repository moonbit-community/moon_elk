///|
pub struct DCExtension {
  parent : DCElement
  direction : DCDirection
  offset : @core.KVector
  width : Double
}

///|
pub fn new_dc_extension(
  parent : DCElement,
  direction : DCDirection,
  middle_pos : @core.KVector,
  width : Double,
) -> DCExtension {
  let bounds = parent.get_bounds()
  let offset = @core.new_kvector()
  ignore(offset.set_xy(-bounds.x, -bounds.y))
  ignore(offset.add(middle_pos))
  let half_width = width / 2.0
  if direction.is_horizontal() {
    ignore(offset.sub_xy(0.0, half_width))
  } else {
    ignore(offset.sub_xy(half_width, 0.0))
  }

  let extension = { parent, direction, offset, width }
  parent.add_extension(extension)
  extension
}

///|
pub fn DCExtension::get_parent(self : DCExtension) -> DCElement {
  self.parent
}

///|
pub fn DCExtension::get_direction(self : DCExtension) -> DCDirection {
  self.direction
}

///|
pub fn DCExtension::get_offset(self : DCExtension) -> @core.KVector {
  self.offset
}

///|
pub fn DCExtension::get_width(self : DCExtension) -> Double {
  self.width
}
