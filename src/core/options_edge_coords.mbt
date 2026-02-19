///|
pub(all) enum EdgeCoords {
  Inherit
  Container
  Parent
  Root
}

///|
pub fn edge_coords_to_string(value : EdgeCoords) -> String {
  match value {
    Inherit => "INHERIT"
    Container => "CONTAINER"
    Parent => "PARENT"
    Root => "ROOT"
  }
}
