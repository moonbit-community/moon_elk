///|
pub type ElkBendPointImpl = ElkBendPoint

///|
pub fn new_elk_bend_point_impl(
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> ElkBendPointImpl {
  new_elk_bend_point(x~, y~)
}
