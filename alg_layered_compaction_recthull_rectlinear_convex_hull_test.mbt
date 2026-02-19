///|
fn layered_point_xy(points : Array[LayeredPoint]) -> Array[(Double, Double)] {
  let result = []
  for point in points {
    result.push((point.x, point.y))
  }
  result
}

///|
fn layered_rect_xywh(
  rectangles : Array[ElkRectangle],
) -> Array[(Double, Double, Double, Double)] {
  let result = []
  for rect in rectangles {
    result.push((rect.x, rect.y, rect.width, rect.height))
  }
  result
}

///|
test "LayeredRectilinearConvexHull cross" {
  let points = [
    new_layered_point(0.0, 1.0),
    new_layered_point(1.0, 1.0),
    new_layered_point(1.0, 0.0),
    new_layered_point(2.0, 0.0),
    new_layered_point(2.0, 1.0),
    new_layered_point(3.0, 1.0),
    new_layered_point(3.0, 2.0),
    new_layered_point(2.0, 2.0),
    new_layered_point(2.0, 3.0),
    new_layered_point(1.0, 3.0),
    new_layered_point(1.0, 2.0),
    new_layered_point(0.0, 2.0),
  ]
  let hull = layered_rectilinear_convex_hull_of(points)
  assert_eq(layered_point_xy(hull.get_hull()), layered_point_xy(points))
  let expected_rectangles = [
    new_elk_rectangle_xywh(0.0, 1.0, 1.0, 1.0),
    new_elk_rectangle_xywh(1.0, 0.0, 1.0, 3.0),
    new_elk_rectangle_xywh(2.0, 1.0, 1.0, 1.0),
  ]
  assert_eq(
    layered_rect_xywh(hull.split_into_rectangles()),
    layered_rect_xywh(expected_rectangles),
  )
}

///|
test "LayeredRectilinearConvexHull little robot" {
  let points = [
    new_layered_point(0.0, 2.0),
    new_layered_point(1.0, 2.0),
    new_layered_point(1.0, 1.0),
    new_layered_point(2.0, 1.0),
    new_layered_point(2.0, 0.0),
    new_layered_point(2.0, 0.0),
    new_layered_point(2.0, 1.0),
    new_layered_point(3.0, 1.0),
    new_layered_point(3.0, 2.0),
    new_layered_point(4.0, 2.0),
    new_layered_point(4.0, 2.0),
    new_layered_point(3.0, 2.0),
    new_layered_point(3.0, 3.0),
    new_layered_point(2.0, 3.0),
    new_layered_point(2.0, 4.0),
    new_layered_point(2.0, 4.0),
    new_layered_point(2.0, 3.0),
    new_layered_point(1.0, 3.0),
    new_layered_point(1.0, 2.0),
    new_layered_point(0.0, 2.0),
  ]
  let hull = layered_rectilinear_convex_hull_of(points)
  assert_eq(layered_point_xy(hull.get_hull()), layered_point_xy(points))
  let expected_rectangles = [
    new_elk_rectangle_xywh(0.0, 2.0, 1.0, 0.0),
    new_elk_rectangle_xywh(1.0, 1.0, 1.0, 2.0),
    new_elk_rectangle_xywh(2.0, 0.0, 0.0, 4.0),
    new_elk_rectangle_xywh(2.0, 1.0, 1.0, 2.0),
    new_elk_rectangle_xywh(3.0, 2.0, 1.0, 0.0),
  ]
  assert_eq(
    layered_rect_xywh(hull.split_into_rectangles()),
    layered_rect_xywh(expected_rectangles),
  )
}
