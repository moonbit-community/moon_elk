///|
fn utils_min_double(left : Double, right : Double) -> Double {
  if left < right {
    left
  } else {
    right
  }
}

///|
pub fn overlap(r1 : ElkRectangle, r2 : ElkRectangle) -> Double {
  let horizontal_overlap = utils_min_double(
    (r1.x - (r2.x + r2.width)).abs(),
    (r1.x + r1.width - r2.x).abs(),
  )
  let vertical_overlap = utils_min_double(
    (r1.y - (r2.y + r2.height)).abs(),
    (r1.y + r1.height - r2.y).abs(),
  )
  let horizontal_center_distance = (r1.x +
  r1.width / 2.0 -
  (r2.x + r2.width / 2.0)).abs()
  if horizontal_center_distance > r1.width / 2.0 + r2.width / 2.0 {
    return 1.0
  }
  let vertical_center_distance = (r1.y +
  r1.height / 2.0 -
  (r2.y + r2.height / 2.0)).abs()
  if vertical_center_distance > r1.height / 2.0 + r2.height / 2.0 {
    return 1.0
  }
  if horizontal_center_distance == 0.0 && vertical_center_distance == 0.0 {
    return 0.0
  }
  if horizontal_center_distance == 0.0 {
    return vertical_overlap / vertical_center_distance + 1.0
  }
  if vertical_center_distance == 0.0 {
    return horizontal_overlap / horizontal_center_distance + 1.0
  }
  utils_min_double(
    horizontal_overlap / horizontal_center_distance,
    vertical_overlap / vertical_center_distance,
  ) +
  1.0
}

///|
pub fn get_rect_edges(r : ElkRectangle) -> Array[TEdge] {
  [
    new_tedge(r.get_top_left(), r.get_top_right()),
    new_tedge(r.get_top_left(), r.get_bottom_left()),
    new_tedge(r.get_bottom_right(), r.get_top_right()),
    new_tedge(r.get_bottom_right(), r.get_bottom_left()),
  ]
}
