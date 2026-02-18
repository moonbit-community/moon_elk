///|
pub struct ElkBendPoint {
  mut x : Double
  mut y : Double
}

///|
pub fn new_elk_bend_point(x? : Double = 0.0, y? : Double = 0.0) -> ElkBendPoint {
  { x, y }
}

///|
pub fn ElkBendPoint::get_x(self : ElkBendPoint) -> Double {
  self.x
}

///|
pub fn ElkBendPoint::set_x(self : ElkBendPoint, x : Double) -> Unit {
  self.x = x
}

///|
pub fn ElkBendPoint::get_y(self : ElkBendPoint) -> Double {
  self.y
}

///|
pub fn ElkBendPoint::set_y(self : ElkBendPoint, y : Double) -> Unit {
  self.y = y
}

///|
pub fn ElkBendPoint::set(self : ElkBendPoint, x : Double, y : Double) -> Unit {
  self.set_x(x)
  self.set_y(y)
}
