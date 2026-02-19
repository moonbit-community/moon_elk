///|
pub struct DCElement {
  shape : @core.KVectorChain
  bounds : @core.ElkRectangle
  mut cp : DCComponent?
  mut coords : Array[Double]?
  mut parent_coords : @core.KVector?
  extensions : Array[DCExtension]
}

///|
pub fn new_dc_element(poly_path : @core.KVectorChain) -> DCElement {
  let vertices = poly_path.to_array()
  let mut min_x = @double.infinity
  let mut min_y = @double.infinity
  let mut max_x = -@double.infinity
  let mut max_y = -@double.infinity
  for vertex in vertices {
    min_x = if vertex.x < min_x { vertex.x } else { min_x }
    min_y = if vertex.y < min_y { vertex.y } else { min_y }
    max_x = if vertex.x > max_x { vertex.x } else { max_x }
    max_y = if vertex.y > max_y { vertex.y } else { max_y }
  }
  let bounds = @core.new_elk_rectangle()
  bounds.set_rect(min_x, min_y, max_x - min_x, max_y - min_y)
  {
    shape: poly_path,
    bounds,
    cp: None,
    coords: None,
    parent_coords: None,
    extensions: [],
  }
}

///|
pub fn DCElement::get_offset(self : DCElement) -> @core.KVector {
  match self.cp {
    Some(component) => component.get_offset()
    None => abort("Offset hasn't been set, yet.")
  }
}

///|
pub fn DCElement::get_coords(self : DCElement) -> Array[Double] {
  match self.coords {
    Some(coords) => coords
    None => {
      let vectors = self.shape.to_array()
      let coords : Array[Double] = []
      for vector in vectors {
        coords.push(vector.x)
        coords.push(vector.y)
      }
      self.coords = Some(coords)
      coords
    }
  }
}

///|
pub fn DCElement::add_extension(
  self : DCElement,
  extension : DCExtension,
) -> Unit {
  self.extensions.push(extension)
}

///|
pub fn DCElement::get_extensions(self : DCElement) -> Array[DCExtension] {
  self.extensions
}

///|
pub fn DCElement::get_bounds(self : DCElement) -> @core.ElkRectangle {
  self.bounds
}

///|
pub fn DCElement::set_parent_coords(
  self : DCElement,
  coords : @core.KVector,
) -> Unit {
  self.parent_coords = Some(coords)
}

///|
pub fn DCElement::get_parent_coords(self : DCElement) -> @core.KVector? {
  self.parent_coords
}

///|
pub fn DCElement::set_component(
  self : DCElement,
  component : DCComponent,
) -> Unit {
  self.cp = Some(component)
}

///|
pub fn DCElement::intersects(
  self : DCElement,
  rect : @core.ElkRectangle,
) -> Bool {
  @core.intersects_rect_path(rect, self.shape) ||
  @core.contains_rect_path(rect, self.shape)
}
