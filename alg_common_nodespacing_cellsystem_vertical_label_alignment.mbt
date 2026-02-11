///|
pub enum VerticalLabelAlignment {
  Top
  Center
  Bottom
}

///|
pub fn vertical_label_alignment_values() -> Array[VerticalLabelAlignment] {
  [Top, Center, Bottom]
}

///|
pub fn vertical_label_alignment_to_string(
  value : VerticalLabelAlignment,
) -> String {
  match value {
    Top => "TOP"
    Center => "CENTER"
    Bottom => "BOTTOM"
  }
}
