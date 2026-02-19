///|
pub type ElkMargin = Spacing

///|
pub fn new_elk_margin() -> ElkMargin {
  new_spacing()
}

///|
pub fn new_elk_margin_any(any : Double) -> ElkMargin {
  new_spacing_values(any, any, any, any)
}

///|
pub fn new_elk_margin_left_right_top_bottom(
  left_right : Double,
  top_bottom : Double,
) -> ElkMargin {
  new_spacing_values(top_bottom, left_right, top_bottom, left_right)
}

///|
pub fn new_elk_margin_values(
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
) -> ElkMargin {
  new_spacing_values(top, right, bottom, left)
}

///|
pub fn new_elk_margin_copy(other : ElkMargin) -> ElkMargin {
  new_spacing_values(other.top, other.right, other.bottom, other.left)
}

///|
pub fn elk_margin_clone(margin : ElkMargin) -> ElkMargin {
  new_elk_margin_copy(margin)
}
