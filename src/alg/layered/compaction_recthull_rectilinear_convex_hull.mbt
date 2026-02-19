///|
pub struct LayeredRectilinearConvexHull {
  hull : Array[LayeredPoint]
  mut x_max1 : LayeredPoint?
  mut x_max2 : LayeredPoint?
  mut x_min1 : LayeredPoint?
  mut x_min2 : LayeredPoint?
  mut y_max1 : LayeredPoint?
  mut y_max2 : LayeredPoint?
  mut y_min1 : LayeredPoint?
  mut y_min2 : LayeredPoint?
}

///|
pub fn new_layered_rectilinear_convex_hull() -> LayeredRectilinearConvexHull {
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
fn layered_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn layered_min_double(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
fn layered_quadrant_order(quadrant : LayeredQuadrant) -> Int {
  match quadrant {
    LQ1 => 0
    LQ4 => 1
    LQ2 => 2
    LQ3 => 3
  }
}

///|
fn layered_point_quadrant_or_abort(point : LayeredPoint) -> LayeredQuadrant {
  match point.quadrant {
    Some(quadrant) => quadrant
    None => abort("LayeredPoint quadrant is required")
  }
}

///|
fn layered_reverse_points(points : Array[LayeredPoint]) -> Array[LayeredPoint] {
  let result = []
  for i in 0..<points.length() {
    result.push(points[points.length() - 1 - i])
  }
  result
}

///|
fn layered_right_high_first(left : LayeredPoint, right : LayeredPoint) -> Int {
  if left.x == right.x {
    layered_compare_double(right.y, left.y)
  } else {
    layered_compare_double(left.x, right.x)
  }
}

///|
fn layered_right_low_first(left : LayeredPoint, right : LayeredPoint) -> Int {
  if left.x == right.x {
    layered_compare_double(left.y, right.y)
  } else {
    layered_compare_double(left.x, right.x)
  }
}

///|
fn layered_left_high_first(left : LayeredPoint, right : LayeredPoint) -> Int {
  if left.x == right.x {
    layered_compare_double(right.y, left.y)
  } else {
    layered_compare_double(right.x, left.x)
  }
}

///|
fn layered_left_low_first(left : LayeredPoint, right : LayeredPoint) -> Int {
  if left.x == right.x {
    layered_compare_double(left.y, right.y)
  } else {
    layered_compare_double(right.x, left.x)
  }
}

///|
fn layered_right_special_order(
  left : LayeredPoint,
  right : LayeredPoint,
) -> Int {
  if left.x != right.x {
    return layered_compare_double(left.x, right.x)
  }
  let left_quadrant = layered_point_quadrant_or_abort(left)
  let right_quadrant = layered_point_quadrant_or_abort(right)
  if layered_quadrant_eq(left_quadrant, right_quadrant) ||
    layered_is_both_left_or_both_right(left_quadrant, right_quadrant) {
    let val = if left_quadrant.is_left() { 1 } else { -1 }
    if left.convex && !right.convex {
      return val
    }
    if !left.convex && right.convex {
      return -val
    }
  }
  layered_quadrant_order(left_quadrant) - layered_quadrant_order(right_quadrant)
}

///|
fn layered_hull_add_concave_corners(
  points : Array[LayeredPoint],
  quadrant : LayeredQuadrant,
) -> Unit {
  if points.length() <= 1 {
    return
  }
  let rebuilt = []
  let mut last = points[0]
  rebuilt.push(last)
  for i in 1..<points.length() {
    let next = points[i]
    let concave = new_layered_point_in_quadrant(next.x, last.y, quadrant)
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
fn layered_maximal_elements(
  points : Array[LayeredPoint],
  comparator : (LayeredPoint, LayeredPoint) -> Int,
  quadrant : LayeredQuadrant,
) -> Array[LayeredPoint] {
  let result = []
  let mut maximal_y = if layered_quadrant_eq(quadrant, LQ1) ||
    layered_quadrant_eq(quadrant, LQ2) {
    1.0e20
  } else {
    -1.0e20
  }
  let handler = (point : LayeredPoint) => {
    let should_add = if layered_quadrant_eq(quadrant, LQ1) ||
      layered_quadrant_eq(quadrant, LQ2) {
      point.y < maximal_y
    } else {
      point.y > maximal_y
    }
    if should_add {
      result.push(new_layered_point_in_quadrant(point.x, point.y, quadrant))
      maximal_y = point.y
    }
  }
  layered_scanline_execute_single(points, comparator, handler)
  result
}

///|
pub fn layered_rectilinear_convex_hull_of(
  points : Array[LayeredPoint],
) -> LayeredRectilinearConvexHull {
  let hull = new_layered_rectilinear_convex_hull()
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
  let q1 = layered_maximal_elements(points, layered_right_low_first, LQ1)
  let q4 = layered_maximal_elements(points, layered_right_high_first, LQ4)
  let q2 = layered_maximal_elements(points, layered_left_low_first, LQ2)
  let q3 = layered_maximal_elements(points, layered_left_high_first, LQ3)
  layered_hull_add_concave_corners(q1, LQ1)
  layered_hull_add_concave_corners(q2, LQ2)
  layered_hull_add_concave_corners(q3, LQ3)
  layered_hull_add_concave_corners(q4, LQ4)
  hull.hull.clear()
  for point in q1 {
    hull.hull.push(point)
  }
  for point in layered_reverse_points(q2) {
    hull.hull.push(point)
  }
  for point in q3 {
    hull.hull.push(point)
  }
  for point in layered_reverse_points(q4) {
    hull.hull.push(point)
  }
  hull
}

///|
pub fn LayeredRectilinearConvexHull::get_hull(
  self : LayeredRectilinearConvexHull,
) -> Array[LayeredPoint] {
  self.hull
}

///|
pub struct LayeredHullRectangleEventState {
  rects : Array[@core.ElkRectangle]
  mut min_y : LayeredPoint?
  mut max_y : LayeredPoint?
  mut last_x : Double
  mut queued : @core.ElkRectangle?
  mut queued_point : LayeredPoint?
}

///|
fn new_layered_hull_rectangle_event_state(
  leftmost_x : Double,
) -> LayeredHullRectangleEventState {
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
fn layered_hull_rectangle_event_handle(
  state : LayeredHullRectangleEventState,
  point : LayeredPoint,
) -> Unit {
  match (state.queued, state.queued_point) {
    (Some(queued), Some(queued_point)) =>
      if point.x != queued_point.x ||
        layered_is_one_left_one_right(
          layered_point_quadrant_or_abort(queued_point),
          layered_point_quadrant_or_abort(point),
        ) {
        state.rects.push(queued)
        state.last_x = queued.x + queued.width
        state.queued = None
        state.queued_point = None
      }
    _ => ()
  }
  let quadrant = layered_point_quadrant_or_abort(point)
  if quadrant.is_upper() {
    state.min_y = Some(point)
  } else {
    state.max_y = Some(point)
  }
  let should_queue = (layered_quadrant_eq(quadrant, LQ1) && !point.convex) ||
    (layered_quadrant_eq(quadrant, LQ2) && point.convex) ||
    (layered_quadrant_eq(quadrant, LQ3) && point.convex) ||
    (layered_quadrant_eq(quadrant, LQ4) && !point.convex)
  if !should_queue {
    return
  }
  match (state.min_y, state.max_y) {
    (Some(min_y), Some(max_y)) => {
      let rect = @core.new_elk_rectangle_xywh(
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
pub fn LayeredRectilinearConvexHull::split_into_rectangles(
  self : LayeredRectilinearConvexHull,
) -> Array[@core.ElkRectangle] {
  let left1 = match self.x_min1 {
    Some(point) => point.x
    None => 0.0
  }
  let left2 = match self.x_min2 {
    Some(point) => point.x
    None => left1
  }
  let state = new_layered_hull_rectangle_event_state(
    layered_min_double(left1, left2),
  )
  layered_scanline_execute_single(self.hull, layered_right_special_order, point => {
    layered_hull_rectangle_event_handle(state, point)
  })
  match state.queued {
    Some(rect) => state.rects.push(rect)
    None => ()
  }
  state.rects
}
