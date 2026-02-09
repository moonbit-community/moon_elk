///|
fn point_xy(points : Array[Point]) -> Array[(Double, Double)] {
  let result = []
  for point in points {
    result.push((point.x, point.y))
  }
  result
}

///|
fn rect_xywh(
  rectangles : Array[ElkRectangle],
) -> Array[(Double, Double, Double, Double)] {
  let result = []
  for rect in rectangles {
    result.push((rect.x, rect.y, rect.width, rect.height))
  }
  result
}

///|
test "RectilinearConvexHull cross" {
  let points = [
    new_point(0.0, 1.0),
    new_point(1.0, 1.0),
    new_point(1.0, 0.0),
    new_point(2.0, 0.0),
    new_point(2.0, 1.0),
    new_point(3.0, 1.0),
    new_point(3.0, 2.0),
    new_point(2.0, 2.0),
    new_point(2.0, 3.0),
    new_point(1.0, 3.0),
    new_point(1.0, 2.0),
    new_point(0.0, 2.0),
  ]
  let hull = rectilinear_convex_hull_of(points)
  assert_eq(point_xy(hull.get_hull()), point_xy(points))
  let expected_rectangles = [
    new_elk_rectangle_xywh(0.0, 1.0, 1.0, 1.0),
    new_elk_rectangle_xywh(1.0, 0.0, 1.0, 3.0),
    new_elk_rectangle_xywh(2.0, 1.0, 1.0, 1.0),
  ]
  assert_eq(
    rect_xywh(hull.split_into_rectangles()),
    rect_xywh(expected_rectangles),
  )
}

///|
test "RectilinearConvexHull little robot" {
  let points = [
    new_point(0.0, 2.0),
    new_point(1.0, 2.0),
    new_point(1.0, 1.0),
    new_point(2.0, 1.0),
    new_point(2.0, 0.0),
    new_point(2.0, 0.0),
    new_point(2.0, 1.0),
    new_point(3.0, 1.0),
    new_point(3.0, 2.0),
    new_point(4.0, 2.0),
    new_point(4.0, 2.0),
    new_point(3.0, 2.0),
    new_point(3.0, 3.0),
    new_point(2.0, 3.0),
    new_point(2.0, 4.0),
    new_point(2.0, 4.0),
    new_point(2.0, 3.0),
    new_point(1.0, 3.0),
    new_point(1.0, 2.0),
    new_point(0.0, 2.0),
  ]
  let hull = rectilinear_convex_hull_of(points)
  assert_eq(point_xy(hull.get_hull()), point_xy(points))
  let expected_rectangles = [
    new_elk_rectangle_xywh(0.0, 2.0, 1.0, 0.0),
    new_elk_rectangle_xywh(1.0, 1.0, 1.0, 2.0),
    new_elk_rectangle_xywh(2.0, 0.0, 0.0, 4.0),
    new_elk_rectangle_xywh(2.0, 1.0, 1.0, 2.0),
    new_elk_rectangle_xywh(3.0, 2.0, 1.0, 0.0),
  ]
  assert_eq(
    rect_xywh(hull.split_into_rectangles()),
    rect_xywh(expected_rectangles),
  )
}
