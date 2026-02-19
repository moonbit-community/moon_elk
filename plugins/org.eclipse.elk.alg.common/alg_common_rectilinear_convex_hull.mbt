///|
pub struct RectilinearConvexHull {
  hull : Array[Point]
  mut x_max1 : Point?
  mut x_max2 : Point?
  mut x_min1 : Point?
  mut x_min2 : Point?
  mut y_max1 : Point?
  mut y_max2 : Point?
  mut y_min1 : Point?
  mut y_min2 : Point?
}

///|
pub fn new_rectilinear_convex_hull() -> RectilinearConvexHull {
  {
    hull: [],
    x_max1: None,
    x_max2: None,
    x_min1: None,
    x_min2: None,
    y_max1: None,
    y_max2: None,
    y_min1: None,
    y_min2: None,
  }
}

///|
fn compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn min_double(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn quadrant_order(quadrant : Quadrant) -> Int {
  match quadrant {
    Q1 => 0
    Q4 => 1
    Q2 => 2
    Q3 => 3
  }
}

///|
fn point_quadrant_or_abort(point : Point) -> Quadrant {
  match point.quadrant {
    Some(quadrant) => quadrant
    None => abort("Point quadrant is required")
  }
}

///|
fn reverse_points(points : Array[Point]) -> Array[Point] {
  let result = []
  for i in 0..<points.length() {
    result.push(points[points.length() - 1 - i])
  }
  result
}

///|
fn right_high_first(left : Point, right : Point) -> Int {
  if left.x == right.x {
    compare_double(right.y, left.y)
  } else {
    compare_double(left.x, right.x)
  }
}

///|
fn right_low_first(left : Point, right : Point) -> Int {
  if left.x == right.x {
    compare_double(left.y, right.y)
  } else {
    compare_double(left.x, right.x)
  }
}

///|
fn left_high_first(left : Point, right : Point) -> Int {
  if left.x == right.x {
    compare_double(right.y, left.y)
  } else {
    compare_double(right.x, left.x)
  }
}

///|
fn left_low_first(left : Point, right : Point) -> Int {
  if left.x == right.x {
    compare_double(left.y, right.y)
  } else {
    compare_double(right.x, left.x)
  }
}

///|
fn right_special_order(left : Point, right : Point) -> Int {
  if left.x != right.x {
    return compare_double(left.x, right.x)
  }
  let left_quadrant = point_quadrant_or_abort(left)
  let right_quadrant = point_quadrant_or_abort(right)
  if quadrant_eq(left_quadrant, right_quadrant) ||
    is_both_left_or_both_right(left_quadrant, right_quadrant) {
    let val = if left_quadrant.is_left() { 1 } else { -1 }
    if left.convex && !right.convex {
      return val
    }
    if !left.convex && right.convex {
      return -val
    }
  }
  quadrant_order(left_quadrant) - quadrant_order(right_quadrant)
}

///|
fn hull_add_concave_corners(points : Array[Point], quadrant : Quadrant) -> Unit {
  if points.length() <= 1 {
    return
  }
  let rebuilt = []
  let mut last = points[0]
  rebuilt.push(last)
  for i in 1..<points.length() {
    let next = points[i]
    let concave = new_point_in_quadrant(next.x, last.y, quadrant)
    concave.convex = false
    rebuilt.push(concave)
    rebuilt.push(next)
    last = next
  }
  points.clear()
  for point in rebuilt {
    points.push(point)
  }
}

///|
fn maximal_elements(
  points : Array[Point],
  comparator : (Point, Point) -> Int,
  quadrant : Quadrant,
) -> Array[Point] {
  let result = []
  let mut maximal_y = if quadrant_eq(quadrant, Q1) || quadrant_eq(quadrant, Q2) {
    1.0e20
  } else {
    -1.0e20
  }
  let handler = (point : Point) => {
    let should_add = if quadrant_eq(quadrant, Q1) || quadrant_eq(quadrant, Q2) {
      point.y < maximal_y
    } else {
      point.y > maximal_y
    }
    if should_add {
      result.push(new_point_in_quadrant(point.x, point.y, quadrant))
      maximal_y = point.y
    }
  }
  scanline_execute_single(points, comparator, handler)
  result
}

///|
pub fn rectilinear_convex_hull_of(
  points : Array[Point],
) -> RectilinearConvexHull {
  let hull = new_rectilinear_convex_hull()
  for point in points {
    let max1_x = match hull.x_max1 {
      Some(value) => value.x
      None => -1.0e20
    }
    if hull.x_max1 is None || point.x >= max1_x {
      hull.x_max2 = hull.x_max1
      hull.x_max1 = Some(point)
    }
    let min1_x = match hull.x_min1 {
      Some(value) => value.x
      None => 1.0e20
    }
    if hull.x_min1 is None || point.x <= min1_x {
      hull.x_min2 = hull.x_min1
      hull.x_min1 = Some(point)
    }
    let max1_y = match hull.y_max1 {
      Some(value) => value.y
      None => -1.0e20
    }
    if hull.y_max1 is None || point.y >= max1_y {
      hull.y_max2 = hull.y_max1
      hull.y_max1 = Some(point)
    }
    let min1_y = match hull.y_min1 {
      Some(value) => value.y
      None => 1.0e20
    }
    if hull.y_min1 is None || point.y <= min1_y {
      hull.y_min2 = hull.y_min1
      hull.y_min1 = Some(point)
    }
  }
  let q1 = maximal_elements(points, right_low_first, Q1)
  let q4 = maximal_elements(points, right_high_first, Q4)
  let q2 = maximal_elements(points, left_low_first, Q2)
  let q3 = maximal_elements(points, left_high_first, Q3)
  hull_add_concave_corners(q1, Q1)
  hull_add_concave_corners(q2, Q2)
  hull_add_concave_corners(q3, Q3)
  hull_add_concave_corners(q4, Q4)
  hull.hull.clear()
  for point in q1 {
    hull.hull.push(point)
  }
  for point in reverse_points(q2) {
    hull.hull.push(point)
  }
  for point in q3 {
    hull.hull.push(point)
  }
  for point in reverse_points(q4) {
    hull.hull.push(point)
  }
  hull
}

///|
pub fn RectilinearConvexHull::get_hull(
  self : RectilinearConvexHull,
) -> Array[Point] {
  self.hull
}

///|
pub struct HullRectangleEventState {
  rects : Array[ElkRectangle]
  mut min_y : Point?
  mut max_y : Point?
  mut last_x : Double
  mut queued : ElkRectangle?
  mut queued_point : Point?
}

///|
fn new_hull_rectangle_event_state(
  leftmost_x : Double,
) -> HullRectangleEventState {
  {
    rects: [],
    min_y: None,
    max_y: None,
    last_x: leftmost_x,
    queued: None,
    queued_point: None,
  }
}

///|
fn hull_rectangle_event_handle(
  state : HullRectangleEventState,
  point : Point,
) -> Unit {
  match (state.queued, state.queued_point) {
    (Some(queued), Some(queued_point)) =>
      if point.x != queued_point.x ||
        is_one_left_one_right(
          point_quadrant_or_abort(queued_point),
          point_quadrant_or_abort(point),
        ) {
        state.rects.push(queued)
        state.last_x = queued.x + queued.width
        state.queued = None
        state.queued_point = None
      }
    _ => ()
  }
  let quadrant = point_quadrant_or_abort(point)
  if quadrant.is_upper() {
    state.min_y = Some(point)
  } else {
    state.max_y = Some(point)
  }
  let should_queue = (quadrant_eq(quadrant, Q1) && !point.convex) ||
    (quadrant_eq(quadrant, Q2) && point.convex) ||
    (quadrant_eq(quadrant, Q3) && point.convex) ||
    (quadrant_eq(quadrant, Q4) && !point.convex)
  if !should_queue {
    return
  }
  match (state.min_y, state.max_y) {
    (Some(min_y), Some(max_y)) => {
      let rect = new_elk_rectangle_xywh(
        state.last_x,
        min_y.y,
        point.x - state.last_x,
        max_y.y - min_y.y,
      )
      state.queued = Some(rect)
      state.queued_point = Some(point)
    }
    _ => ()
  }
}

///|
pub fn RectilinearConvexHull::split_into_rectangles(
  self : RectilinearConvexHull,
) -> Array[ElkRectangle] {
  let left1 = match self.x_min1 {
    Some(point) => point.x
    None => 0.0
  }
  let left2 = match self.x_min2 {
    Some(point) => point.x
    None => left1
  }
  let state = new_hull_rectangle_event_state(min_double(left1, left2))
  scanline_execute_single(self.hull, right_special_order, point => {
    hull_rectangle_event_handle(state, point)
  })
  match state.queued {
    Some(rect) => state.rects.push(rect)
    None => ()
  }
  state.rects
}
