///|
pub type ElkPadding = Spacing

///|
pub fn new_elk_padding() -> ElkPadding {
  new_spacing()
}

///|
pub fn new_elk_padding_any(any : Double) -> ElkPadding {
  new_spacing_values(any, any, any, any)
}

///|
pub fn new_elk_padding_left_right_top_bottom(
  left_right : Double,
  top_bottom : Double,
) -> ElkPadding {
  new_spacing_values(top_bottom, left_right, top_bottom, left_right)
}

///|
pub fn new_elk_padding_values(
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
) -> ElkPadding {
  new_spacing_values(top, right, bottom, left)
}

///|
pub fn new_elk_padding_copy(other : ElkPadding) -> ElkPadding {
  new_spacing_values(other.top, other.right, other.bottom, other.left)
}

///|
pub fn elk_padding_clone(padding : ElkPadding) -> ElkPadding {
  new_elk_padding_copy(padding)
}
