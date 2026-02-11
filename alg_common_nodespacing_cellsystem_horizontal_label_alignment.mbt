///|
pub(all) enum HorizontalLabelAlignment {
  Left
  Center
  Right
}

///|
pub fn horizontal_label_alignment_values() -> Array[HorizontalLabelAlignment] {
  [Left, Center, Right]
}

///|
pub fn horizontal_label_alignment_to_string(
  value : HorizontalLabelAlignment,
) -> String {
  match value {
    Left => "LEFT"
    Center => "CENTER"
    Right => "RIGHT"
  }
}
