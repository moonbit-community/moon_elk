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
pub fn vertical_label_alignment_top() -> VerticalLabelAlignment {
  Top
}

///|
pub fn vertical_label_alignment_center() -> VerticalLabelAlignment {
  Center
}

///|
pub fn vertical_label_alignment_bottom() -> VerticalLabelAlignment {
  Bottom
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
