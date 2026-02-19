///|
pub struct DCElement {
  shape : KVectorChain
  bounds : ElkRectangle
  mut cp : DCComponent?
  mut coords : Array[Double]?
  mut parent_coords : KVector?
  extensions : Array[DCExtension]
}

///|
pub fn new_dc_element(poly_path : KVectorChain) -> DCElement {
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
  let bounds = new_elk_rectangle()
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
pub fn DCElement::get_offset(self : DCElement) -> KVector {
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
pub fn DCElement::get_bounds(self : DCElement) -> ElkRectangle {
  self.bounds
}

///|
pub fn DCElement::set_parent_coords(self : DCElement, coords : KVector) -> Unit {
  self.parent_coords = Some(coords)
}

///|
pub fn DCElement::get_parent_coords(self : DCElement) -> KVector? {
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
pub fn DCElement::intersects(self : DCElement, rect : ElkRectangle) -> Bool {
  intersects_rect_path(rect, self.shape) || contains_rect_path(rect, self.shape)
}
