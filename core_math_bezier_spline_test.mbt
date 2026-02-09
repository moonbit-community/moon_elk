///|
fn init_bezier_curve_horizontal() -> (
  BezierSpline,
  KVector,
  KVector,
  KVector,
  KVector,
) {
  let start_pnt = new_kvector_xy(0.0, 50.0)
  let fst_ctr_pnt = new_kvector_xy(10.0, 50.0)
  let snd_ctr_pnt = new_kvector_xy(20.0, 50.0)
  let end_pnt = new_kvector_xy(30.0, 50.0)
  let bs = new_bezier_spline()
  bs.add_curve_points(start_pnt, fst_ctr_pnt, snd_ctr_pnt, end_pnt)
  (bs, start_pnt, fst_ctr_pnt, snd_ctr_pnt, end_pnt)
}

///|
fn init_bezier_curve_vertical() -> (
  BezierSpline,
  KVector,
  KVector,
  KVector,
  KVector,
) {
  let start_pnt = new_kvector_xy(50.0, 0.0)
  let fst_ctr_pnt = new_kvector_xy(50.0, 20.0)
  let snd_ctr_pnt = new_kvector_xy(50.0, 40.0)
  let end_pnt = new_kvector_xy(50.0, 50.0)
  let bs = new_bezier_spline()
  bs.add_curve_points(start_pnt, fst_ctr_pnt, snd_ctr_pnt, end_pnt)
  (bs, start_pnt, fst_ctr_pnt, snd_ctr_pnt, end_pnt)
}

///|
test "BezierSpline testGetStartPoint" {
  let (bs1, start1, _, _, _) = init_bezier_curve_vertical()
  let v1 = bs1.get_start_point()
  assert_double_eq(start1.x, v1.x, 0.0)
  assert_double_eq(start1.y, v1.y, 0.0)
  let (bs2, start2, _, _, _) = init_bezier_curve_horizontal()
  let v2 = bs2.get_start_point()
  assert_double_eq(start2.x, v2.x, 0.0)
  assert_double_eq(start2.y, v2.y, 0.0)
}

///|
test "BezierSpline testGetEndPoint" {
  let (bs1, _, _, _, end1) = init_bezier_curve_vertical()
  let v1 = bs1.get_end_point()
  assert_double_eq(end1.x, v1.x, 0.0)
  assert_double_eq(end1.y, v1.y, 0.0)
  let (bs2, _, _, _, end2) = init_bezier_curve_horizontal()
  let v2 = bs2.get_end_point()
  assert_double_eq(end2.x, v2.x, 0.0)
  assert_double_eq(end2.y, v2.y, 0.0)
}

///|
test "BezierSpline testGetInnerPoints" {
  let (vertical, start_vertical, _, _, _) = init_bezier_curve_vertical()
  let vectors_v = vertical.get_inner_points()
  for v in vectors_v {
    assert_double_eq(start_vertical.x, v.x, 0.00000001)
  }
  let (horizontal, start_horizontal, _, _, _) = init_bezier_curve_horizontal()
  let vectors_h = horizontal.get_inner_points()
  for v in vectors_h {
    assert_double_eq(start_horizontal.y, v.y, 0.00000001)
  }
}

///|
test "BezierSpline testGetBasePoints" {
  let (vertical, start_vertical, _, _, _) = init_bezier_curve_vertical()
  let vectors_v = vertical.get_base_points()
  for v in vectors_v {
    assert_double_eq(start_vertical.x, v.x, 0.00000001)
  }
  let (horizontal, start_horizontal, _, _, _) = init_bezier_curve_horizontal()
  let vectors_h = horizontal.get_base_points()
  for v in vectors_h {
    assert_double_eq(start_horizontal.y, v.y, 0.00000001)
  }
}

///|
test "BezierSpline testGetPolylineApprx" {
  let (vertical, start_vertical, _, _, _) = init_bezier_curve_vertical()
  let vectors_v = vertical.get_polyline_apprx(50)
  for v in vectors_v {
    assert_double_eq(start_vertical.x, v.x, 0.00000001)
  }
  let (horizontal, start_horizontal, _, _, _) = init_bezier_curve_horizontal()
  let vectors_h = horizontal.get_polyline_apprx(50)
  for v in vectors_h {
    assert_double_eq(start_horizontal.y, v.y, 0.00000001)
  }
}
