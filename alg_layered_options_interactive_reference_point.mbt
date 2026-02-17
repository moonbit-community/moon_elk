///|
pub enum InteractiveReferencePoint {
  Center
  TopLeft
}

///|
pub fn interactive_reference_point_to_string(
  value : InteractiveReferencePoint,
) -> String {
  match value {
    Center => "CENTER"
    TopLeft => "TOP_LEFT"
  }
}

///|
pub fn interactive_reference_point_values() -> Array[String] {
  [
    interactive_reference_point_to_string(Center),
    interactive_reference_point_to_string(TopLeft),
  ]
}
