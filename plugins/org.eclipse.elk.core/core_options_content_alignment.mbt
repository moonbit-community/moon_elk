///|
pub enum ContentAlignment {
  HLeft
  HCenter
  HRight
  VTop
  VCenter
  VBottom
}

///|
pub fn content_alignment_to_string(value : ContentAlignment) -> String {
  match value {
    HLeft => "H_LEFT"
    HCenter => "H_CENTER"
    HRight => "H_RIGHT"
    VTop => "V_TOP"
    VCenter => "V_CENTER"
    VBottom => "V_BOTTOM"
  }
}

///|
pub fn content_alignment_values_to_strings(
  values : Array[ContentAlignment],
) -> Array[String] {
  let result = []
  for value in values {
    result.push(content_alignment_to_string(value))
  }
  result
}

///|
pub fn content_alignment_top_left() -> Array[ContentAlignment] {
  [VTop, HLeft]
}

///|
pub fn content_alignment_top_center() -> Array[ContentAlignment] {
  [VTop, HCenter]
}

///|
pub fn content_alignment_top_right() -> Array[ContentAlignment] {
  [VTop, HRight]
}

///|
pub fn content_alignment_center_left() -> Array[ContentAlignment] {
  [VCenter, HLeft]
}

///|
pub fn content_alignment_center_center() -> Array[ContentAlignment] {
  [VCenter, HCenter]
}

///|
pub fn content_alignment_center_right() -> Array[ContentAlignment] {
  [VCenter, HRight]
}

///|
pub fn content_alignment_bottom_left() -> Array[ContentAlignment] {
  [VBottom, HLeft]
}

///|
pub fn content_alignment_bottom_center() -> Array[ContentAlignment] {
  [VBottom, HCenter]
}

///|
pub fn content_alignment_bottom_right() -> Array[ContentAlignment] {
  [VBottom, HRight]
}
