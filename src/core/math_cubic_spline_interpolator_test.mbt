///|
test "CubicSplineInterpolator calculateClosedBezierSplineTest" {
  let v0 = new_kvector_xy(5.0, 50.0)
  let v1 = new_kvector_xy(10.0, 70.0)
  let v2 = new_kvector_xy(30.0, 100.0)
  let v3 = new_kvector_xy(60.0, 70.0)
  let v4 = new_kvector_xy(70.0, 40.0)
  let vectors = [v0, v1, v2, v3, v4]
  let interpolator = new_cubic_spline_interpolator()
  let b = interpolator.calculate_closed_bezier_spline(vectors)
  assert_true(v0.equals(b.get_end_point()))
  let h0 = new_kvector_xy(5.0, 50.0)
  let h1 = new_kvector_xy(10.0, 50.0)
  let h2 = new_kvector_xy(30.0, 50.0)
  let h3 = new_kvector_xy(60.0, 50.0)
  let h4 = new_kvector_xy(70.0, 50.0)
  let vectors_h = [h0, h1, h2, h3, h4]
  let bh = interpolator.calculate_closed_bezier_spline(vectors_h)
  assert_double_eq(50.0, bh.get_start_point().y, 0.0)
  assert_double_eq(50.0, bh.get_end_point().y, 0.0)
  for v in bh.get_inner_points() {
    assert_double_eq(50.0, v.y, 0.0)
  }
  let vv0 = new_kvector_xy(100.0, 10.0)
  let vv1 = new_kvector_xy(100.0, 50.0)
  let vv2 = new_kvector_xy(100.0, 100.0)
  let vv3 = new_kvector_xy(100.0, 120.0)
  let vv4 = new_kvector_xy(100.0, 200.0)
  let vectors_v = [vv0, vv1, vv2, vv3, vv4]
  let bv = interpolator.calculate_closed_bezier_spline(vectors_v)
  assert_double_eq(100.0, bv.get_start_point().x, 0.0)
  assert_double_eq(100.0, bv.get_end_point().x, 0.0)
  for v in bv.get_inner_points() {
    assert_double_eq(100.0, v.x, 0.0)
  }
}
