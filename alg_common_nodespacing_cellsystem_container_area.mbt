///|
pub(all) enum ContainerArea {
  Begin
  Center
  End
}

///|
pub fn container_area_values() -> Array[ContainerArea] {
  [Begin, Center, End]
}

///|
pub fn container_area_to_string(value : ContainerArea) -> String {
  match value {
    Begin => "BEGIN"
    Center => "CENTER"
    End => "END"
  }
}
