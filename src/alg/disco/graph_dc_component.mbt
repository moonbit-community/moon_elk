///|
pub struct DCComponent {
  mut offset : @core.KVector
  shapes : Array[DCElement]
  mut changed : Bool
  mut bounds : @core.KVector
  mut min_corner_of_bounding_rectangle : @core.KVector
  mut id : Int
}

///|
pub fn new_dc_component() -> DCComponent {
  let offset = @core.new_kvector()
  let bounds = @core.new_kvector()
  let corner = @core.new_kvector()
  {
    offset,
    shapes: [],
    changed: true,
    bounds,
    min_corner_of_bounding_rectangle: corner,
    id: -1,
  }
}

///|
pub fn DCComponent::set_offset(
  self : DCComponent,
  offset : @core.KVector,
) -> Unit {
  self.changed = true
  self.offset = offset
}

///|
pub fn DCComponent::get_offset(self : DCComponent) -> @core.KVector {
  self.offset
}

///|
pub fn DCComponent::get_elements(self : DCComponent) -> Array[DCElement] {
  self.shapes
}

///|
pub fn DCComponent::get_dimensions_of_bounding_rectangle(
  self : DCComponent,
) -> @core.KVector {
  if self.changed {
    self.update()
  }
  self.bounds
}

///|
pub fn DCComponent::get_min_corner(self : DCComponent) -> @core.KVector {
  if self.changed {
    self.update()
  }
  self.min_corner_of_bounding_rectangle
}

///|
pub fn DCComponent::intersects(
  self : DCComponent,
  rect : @core.ElkRectangle,
) -> Bool {
  for elem in self.shapes {
    if elem.intersects(rect) {
      return true
    }
  }
  false
}

///|
pub fn DCComponent::add_element(
  self : DCComponent,
  element : DCElement,
) -> Unit {
  self.changed = true
  self.shapes.push(element)
  element.set_component(self)
}

///|
pub fn DCComponent::add_elements(
  self : DCComponent,
  elements : Array[DCElement],
) -> Unit {
  for elem in elements {
    self.add_element(elem)
  }
}

///|
fn DCComponent::update(self : DCComponent) -> Unit {
  self.changed = false

  if self.shapes.is_empty() {
    self.bounds = @core.new_kvector()
    self.min_corner_of_bounding_rectangle = self.offset
    return
  }

  let mut min_x = @double.infinity
  let mut max_x = -@double.infinity
  let mut min_y = @double.infinity
  let mut max_y = -@double.infinity

  for elem in self.shapes {
    let elem_bounds = elem.get_bounds()
    min_x = if elem_bounds.x < min_x { elem_bounds.x } else { min_x }
    max_x = if elem_bounds.x + elem_bounds.width > max_x {
      elem_bounds.x + elem_bounds.width
    } else {
      max_x
    }
    min_y = if elem_bounds.y < min_y { elem_bounds.y } else { min_y }
    max_y = if elem_bounds.y + elem_bounds.height > max_y {
      elem_bounds.y + elem_bounds.height
    } else {
      max_y
    }

    for ext in elem.get_extensions() {
      let dir = ext.get_direction()
      let mut min_pos = 0.0
      let mut max_pos = 0.0
      if dir.is_horizontal() {
        min_pos = elem_bounds.y + ext.get_offset().y
        max_pos = min_pos + ext.get_width()
        min_y = if min_pos < min_y { min_pos } else { min_y }
        max_y = if max_pos > max_y { max_pos } else { max_y }
      } else {
        min_pos = elem_bounds.x + ext.get_offset().x
        max_pos = min_pos + ext.get_width()
        min_x = if min_pos < min_x { min_pos } else { min_x }
        max_x = if max_pos > max_x { max_pos } else { max_x }
      }
    }
  }

  let bounds = @core.new_kvector()
  ignore(bounds.set_xy(max_x - min_x, max_y - min_y))
  self.bounds = bounds

  let corner = @core.new_kvector()
  ignore(corner.set_xy(min_x + self.offset.x, min_y + self.offset.y))
  self.min_corner_of_bounding_rectangle = corner
}

///|
pub fn DCComponent::get_id(self : DCComponent) -> Int {
  self.id
}

///|
pub fn DCComponent::set_id(self : DCComponent, id : Int) -> Unit {
  self.id = id
}
