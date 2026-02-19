///|
pub(all) enum Alignment {
  Automatic
  Left
  Right
  Top
  Bottom
  Center
}

///|
pub fn alignment_to_string(value : Alignment) -> String {
  match value {
    Automatic => "AUTOMATIC"
    Left => "LEFT"
    Right => "RIGHT"
    Top => "TOP"
    Bottom => "BOTTOM"
    Center => "CENTER"
  }
}
