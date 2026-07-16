///|
pub enum SporeRootSelection {
  FIXED
  CENTER_NODE
}

///|
pub fn spore_root_selection_from_string(value : String) -> SporeRootSelection {
  if value == "FIXED" {
    FIXED
  } else {
    CENTER_NODE
  }
}
