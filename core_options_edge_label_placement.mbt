///|
pub enum EdgeLabelPlacement {
  Centered
  Head
  Tail
}

///|
pub fn edge_label_placement_to_string(placement : EdgeLabelPlacement) -> String {
  match placement {
    Centered => "CENTER"
    Head => "HEAD"
    Tail => "TAIL"
  }
}

///|
pub fn EdgeLabelPlacement::is_end_label_placement(
  self : EdgeLabelPlacement,
) -> Bool {
  match self {
    Head => true
    Tail => true
    _ => false
  }
}
