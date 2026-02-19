///|
pub enum LayeredQuadrant {
  LQ1
  LQ4
  LQ2
  LQ3
}

///|
pub struct LayeredPoint {
  x : Double
  y : Double
  quadrant : LayeredQuadrant?
  mut convex : Bool
}

///|
pub fn new_layered_point(x : Double, y : Double) -> LayeredPoint {
  { x, y, quadrant: None, convex: true }
}

///|
pub fn new_layered_point_in_quadrant(
  x : Double,
  y : Double,
  quadrant : LayeredQuadrant,
) -> LayeredPoint {
  { x, y, quadrant: Some(quadrant), convex: true }
}

///|
pub fn layered_quadrant_eq(
  left : LayeredQuadrant,
  right : LayeredQuadrant,
) -> Bool {
  match (left, right) {
    (LQ1, LQ1) => true
    (LQ4, LQ4) => true
    (LQ2, LQ2) => true
    (LQ3, LQ3) => true
    _ => false
  }
}

///|
pub fn layered_point_from_kvector(vector : KVector) -> LayeredPoint {
  new_layered_point(vector.x, vector.y)
}

///|
pub fn LayeredQuadrant::is_upper(self : LayeredQuadrant) -> Bool {
  layered_quadrant_eq(self, LQ1) || layered_quadrant_eq(self, LQ2)
}

///|
pub fn LayeredQuadrant::is_left(self : LayeredQuadrant) -> Bool {
  layered_quadrant_eq(self, LQ1) || layered_quadrant_eq(self, LQ4)
}

///|
pub fn layered_is_both_left_or_both_right(
  q1 : LayeredQuadrant,
  q2 : LayeredQuadrant,
) -> Bool {
  (layered_quadrant_eq(q1, LQ1) && layered_quadrant_eq(q2, LQ4)) ||
  (layered_quadrant_eq(q1, LQ4) && layered_quadrant_eq(q2, LQ1)) ||
  (layered_quadrant_eq(q1, LQ3) && layered_quadrant_eq(q2, LQ2)) ||
  (layered_quadrant_eq(q1, LQ2) && layered_quadrant_eq(q2, LQ3))
}

///|
pub fn layered_is_one_left_one_right(
  q1 : LayeredQuadrant,
  q2 : LayeredQuadrant,
) -> Bool {
  (layered_quadrant_eq(q1, LQ1) && layered_quadrant_eq(q2, LQ2)) ||
  (layered_quadrant_eq(q1, LQ1) && layered_quadrant_eq(q2, LQ3)) ||
  (layered_quadrant_eq(q1, LQ4) && layered_quadrant_eq(q2, LQ3)) ||
  (layered_quadrant_eq(q1, LQ4) && layered_quadrant_eq(q2, LQ2))
}

///|
pub fn layered_point_with_quadrant(
  point : LayeredPoint,
  quadrant : LayeredQuadrant,
) -> LayeredPoint {
  { x: point.x, y: point.y, quadrant: Some(quadrant), convex: point.convex }
}
