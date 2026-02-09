///|
pub enum Quadrant {
  Q1
  Q4
  Q2
  Q3
}

///|
pub struct Point {
  x : Double
  y : Double
  quadrant : Quadrant?
  mut convex : Bool
}

///|
pub fn new_point(x : Double, y : Double) -> Point {
  { x, y, quadrant: None, convex: true }
}

///|
pub fn new_point_in_quadrant(
  x : Double,
  y : Double,
  quadrant : Quadrant,
) -> Point {
  { x, y, quadrant: Some(quadrant), convex: true }
}

///|
pub fn quadrant_eq(left : Quadrant, right : Quadrant) -> Bool {
  match (left, right) {
    (Q1, Q1) => true
    (Q4, Q4) => true
    (Q2, Q2) => true
    (Q3, Q3) => true
    _ => false
  }
}

///|
pub fn point_from_kvector(vector : KVector) -> Point {
  new_point(vector.x, vector.y)
}

///|
pub fn Quadrant::is_upper(self : Quadrant) -> Bool {
  quadrant_eq(self, Q1) || quadrant_eq(self, Q2)
}

///|
pub fn Quadrant::is_left(self : Quadrant) -> Bool {
  quadrant_eq(self, Q1) || quadrant_eq(self, Q4)
}

///|
pub fn is_both_left_or_both_right(q1 : Quadrant, q2 : Quadrant) -> Bool {
  (quadrant_eq(q1, Q1) && quadrant_eq(q2, Q4)) ||
  (quadrant_eq(q1, Q4) && quadrant_eq(q2, Q1)) ||
  (quadrant_eq(q1, Q3) && quadrant_eq(q2, Q2)) ||
  (quadrant_eq(q1, Q2) && quadrant_eq(q2, Q3))
}

///|
pub fn is_one_left_one_right(q1 : Quadrant, q2 : Quadrant) -> Bool {
  (quadrant_eq(q1, Q1) && quadrant_eq(q2, Q2)) ||
  (quadrant_eq(q1, Q1) && quadrant_eq(q2, Q3)) ||
  (quadrant_eq(q1, Q4) && quadrant_eq(q2, Q3)) ||
  (quadrant_eq(q1, Q4) && quadrant_eq(q2, Q2))
}

///|
pub fn point_with_quadrant(point : Point, quadrant : Quadrant) -> Point {
  { x: point.x, y: point.y, quadrant: Some(quadrant), convex: point.convex }
}
