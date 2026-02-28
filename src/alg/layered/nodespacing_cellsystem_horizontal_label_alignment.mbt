///|
pub enum HorizontalLabelAlignment {
  Left
  Center
  Right
}

///|
pub fn horizontal_label_alignment_values() -> Array[HorizontalLabelAlignment] {
  [Left, Center, Right]
}

///|
pub fn horizontal_label_alignment_left() -> HorizontalLabelAlignment {
  Left
}

///|
pub fn horizontal_label_alignment_center() -> HorizontalLabelAlignment {
  Center
}

///|
pub fn horizontal_label_alignment_right() -> HorizontalLabelAlignment {
  Right
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
