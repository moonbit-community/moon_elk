///|
pub(all) enum ShapeCoords {
  Inherit
  Parent
  Root
}

///|
pub fn shape_coords_to_string(value : ShapeCoords) -> String {
  match value {
    Inherit => "INHERIT"
    Parent => "PARENT"
    Root => "ROOT"
  }
}
