///|
test "ElkMath testPointContains" {
  let rect = new_elk_rectangle_xywh(23.0, 14.0, 20.0, 20.0)
  let contained = new_kvector_xy(26.0, 19.0)
  assert_true(contains_rect_point(rect, contained))
  let not_contained = new_kvector_xy(10.0, 9.0)
  assert_false(contains_rect_point(rect, not_contained))
  let on_border = new_kvector_xy(23.0, 20.0)
  assert_false(contains_rect_point(rect, on_border))
  let on_corner = new_kvector_xy(23.0, 14.0)
  assert_false(contains_rect_point(rect, on_corner))
}

///|
test "ElkMath testLineContains" {
  let rect = new_elk_rectangle_xywh(23.0, 14.0, 20.0, 20.0)
  let line11 = new_kvector_xy(24.0, 20.0)
  let line12 = new_kvector_xy(40.0, 32.0)
  assert_true(contains_rect_line(rect, line11, line12))
  let line21 = new_kvector_xy(10.0, 10.0)
  let line22 = new_kvector_xy(40.0, 32.0)
  assert_false(contains_rect_line(rect, line21, line22))
}

///|
test "ElkMath testPathContains" {
  let rect = new_elk_rectangle_xywh(23.0, 14.0, 20.0, 20.0)
  let path = new_kvector_chain()
  path.add_xy(24.0, 15.0)
  path.add_xy(27.0, 20.0)
  path.add_xy(39.0, 30.0)
  path.add_xy(29.0, 19.0)
  assert_true(contains_rect_path(rect, path))
  let path2 = new_kvector_chain_copy(path)
  path2.add_xy(23.0, 14.0)
  assert_false(contains_rect_path(rect, path2))
  path.add_xy(10.0, 10.0)
  assert_false(contains_rect_path(rect, path))
}

///|
test "ElkMath testLineLineIntersect" {
  let l11 = new_kvector_xy(10.0, 10.0)
  let l12 = new_kvector_xy(20.0, 20.0)
  let l21 = new_kvector_xy(11.0, 21.0)
  let l22 = new_kvector_xy(21.0, 11.0)
  assert_true(intersects_line(l11, l12, l21, l22))
  let touch1 = new_kvector_xy(10.0, 10.0)
  let touch2 = new_kvector_xy(15.0, 10.0)
  assert_false(intersects_line(l11, l12, touch1, touch2))
  let no_cross1 = new_kvector_xy(1.0, 2.0)
  let no_cross2 = new_kvector_xy(2.0, 1.0)
  assert_false(intersects_line(l11, l12, no_cross1, no_cross2))
  assert_false(intersects_line(l11, l12, l11.clone(), l12.clone()))
  assert_false(intersects_line(l11, l12, l12.clone(), l11.clone()))
  let parallel1 = new_kvector_xy(11.0, 1.0)
  let parallel2 = new_kvector_xy(21.0, 21.0)
  assert_false(intersects_line(l11, l12, parallel1, parallel2))
}

///|
test "ElkMath testPathIntersects" {
  let rect = new_elk_rectangle_xywh(23.0, 14.0, 20.0, 20.0)
  let path = new_kvector_chain()
  path.add_xy(24.0, 15.0)
  path.add_xy(27.0, 20.0)
  path.add_xy(39.0, 30.0)
  path.add_xy(29.0, 19.0)
  assert_false(intersects_rect_path(rect, path))
  let path2 = new_kvector_chain_copy(path)
  path2.add_xy(23.0, 14.0)
  assert_false(intersects_rect_path(rect, path2))
  path.add_xy(10.0, 10.0)
  assert_true(intersects_rect_path(rect, path))
}

///|
test "ElkMath testFactl" {
  assert_eq(factl(0), Int64::from_int(1))
  assert_eq(factl(1), Int64::from_int(1))
  let expected_20 = try @string.parse_int64("2432902008176640000") catch {
    _ => abort("failed to parse int64 literal")
  } noraise {
    value => value
  }
  assert_eq(factl(20), expected_20)
}

///|
test "ElkMath testFactlLittleIllegalArgumentException" {
  @core.layout_runtime_clear_error()
  ignore(factl(-50))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: The input must be between 0 and 21",
    ),
  )
}

///|
test "ElkMath testFactlBigIllegalArgumentException" {
  @core.layout_runtime_clear_error()
  ignore(factl(21))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: The input must be between 0 and 21",
    ),
  )
}

///|
test "ElkMath testFactd" {
  assert_double_eq(factd(0), 1.0, 0.0)
  assert_double_eq(factd(1), 1.0, 0.0)
}

///|
test "ElkMath testFactdLittleIllegalArgumentException" {
  @core.layout_runtime_clear_error()
  ignore(factd(-1))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: The input must be positive",
    ),
  )
}

///|
test "ElkMath testBinomiall" {
  assert_eq(binomiall(2, 0), Int64::from_int(1))
  assert_eq(binomiall(20, 20), Int64::from_int(1))
  assert_eq(binomiall(2, 1), Int64::from_int(2))
}

///|
test "ElkMath testBinomiallLittleIllegalArgumentException" {
  @core.layout_runtime_clear_error()
  ignore(binomiall(-1, 1))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: k and n must be positive",
    ),
  )
}

///|
test "ElkMath testBinomiald" {
  assert_double_eq(binomiald(2, 0), 1.0, 0.0)
  assert_double_eq(binomiald(20, 20), 1.0, 0.0)
  assert_double_eq(binomiald(2, 1), 2.0, 0.0)
}

///|
test "ElkMath testBinomialdLittleIllegalArgumentException" {
  @core.layout_runtime_clear_error()
  ignore(binomiald(-1, 1))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: k and n must be positive",
    ),
  )
}

///|
test "ElkMath testPow" {
  let ad = 10.0
  assert_double_eq(powd(ad, 0), 1.0, 0.0)
  assert_double_eq(powf(ad, 0), 1.0, 0.0)
  assert_double_eq(powd(ad, 2), 100.0, 0.0)
  assert_double_eq(powf(ad, 2), 100.0, 0.0)
}

///|
test "ElkMath testCalcBezierPoints" {
  let kvector1 = new_kvector_xy(10.0, 10.0)
  let kvector2 = new_kvector_xy(20.0, 20.0)
  let kvector3 = new_kvector_xy(30.0, 30.0)
  let kvector4 = new_kvector_xy(50.0, 50.0)
  let result = approximate_bezier_segment(20, [
    kvector1, kvector2, kvector3, kvector4,
  ])
  assert_double_eq(kvector4.x, result[result.length() - 1].x, 0.000000001)
  assert_double_eq(kvector4.y, result[result.length() - 1].y, 0.000000001)
  let h1 = new_kvector_xy(50.0, 10.0)
  let h2 = new_kvector_xy(70.0, 10.0)
  let h3 = new_kvector_xy(80.0, 10.0)
  let h4 = new_kvector_xy(100.0, 10.0)
  let result_h = approximate_bezier_segment(20, [h1, h2, h3, h4])
  for k in result_h {
    assert_double_eq(10.0, k.y, 0.000000001)
  }
}

///|
test "ElkMath testApproximateSpline" {
  let kvector1 = new_kvector_xy(10.0, 10.0)
  let kvector2 = new_kvector_xy(20.0, 20.0)
  let kvector3 = new_kvector_xy(30.0, 30.0)
  let kvector4 = new_kvector_xy(50.0, 50.0)
  let vectors = approximate_bezier_segment(20, [
    kvector1, kvector2, kvector3, kvector4,
  ])
  let control_points = new_kvector_chain_from_array(vectors)
  let result = approximate_bezier_spline(control_points)
  let k = result.get(result.size() - 1)
  assert_double_eq(kvector4.x, k.x, 0.000000001)
  assert_double_eq(kvector4.y, k.y, 0.000000001)
  let h1 = new_kvector_xy(50.0, 10.0)
  let h2 = new_kvector_xy(70.0, 10.0)
  let h3 = new_kvector_xy(80.0, 10.0)
  let h4 = new_kvector_xy(100.0, 10.0)
  let vectors_h = approximate_bezier_segment(20, [h1, h2, h3, h4])
  let control_points_h = new_kvector_chain_from_array(vectors_h)
  let result_h = approximate_bezier_spline(control_points_h)
  for kv in result_h.to_array() {
    assert_double_eq(10.0, kv.y, 0.000000001)
  }
}

///|
test "ElkMath testDistanceFromSpline" {
  let kvector1 = new_kvector_xy(10.0, 10.0)
  let kvector2 = new_kvector_xy(20.0, 20.0)
  let kvector3 = new_kvector_xy(30.0, 30.0)
  let kvector4 = new_kvector_xy(50.0, 50.0)
  let result1 = distance_from_bezier_segment(
    kvector1, kvector2, kvector3, kvector4, kvector4,
  )
  assert_double_eq(result1, 0.0, 0.01)
  let result2 = distance_from_bezier_segment(
    kvector1, kvector2, kvector3, kvector4, kvector3,
  )
  assert_double_eq(result2, 0.0, 0.01)
  let result3 = distance_from_bezier_segment(
    kvector1, kvector2, kvector3, kvector4, kvector2,
  )
  assert_double_eq(result3, 0.0, 0.01)
  let result4 = distance_from_bezier_segment(
    kvector1, kvector2, kvector3, kvector4, kvector1,
  )
  assert_double_eq(result4, 0.0, 0.01)
}

///|
test "ElkMath testMax" {
  assert_eq(maxi([1, 7, 5, 6]), 7)
  assert_double_eq(maxf([1.0, 7.0, 5.0, 6.0]), 7.0, 0.0)
  assert_double_eq(maxd([1.0, 7.0, 5.0, 6.0]), 7.0, 0.0)
}

///|
test "ElkMath testMin" {
  assert_eq(mini([1, 7, 5, 6]), 1)
  assert_eq(mini([8, 1, 9, 0]), 0)
  assert_eq(mini([8, 8, 8, 8]), 8)
  assert_double_eq(minf([1.0, 7.0, 5.0, 6.0]), 1.0, 0.0)
  assert_double_eq(minf([8.0, 1.0, 9.0, 0.0]), 0.0, 0.0)
  assert_double_eq(minf([8.0, 8.0, 8.0, 8.0]), 8.0, 0.0)
  assert_double_eq(mind([1.0, 7.0, 5.0, 6.0]), 1.0, 0.0)
  assert_double_eq(mind([8.0, 1.0, 9.0, 0.0]), 0.0, 0.0)
  assert_double_eq(mind([8.0, 8.0, 8.0, 8.0]), 8.0, 0.0)
}

///|
test "ElkMath testAverage" {
  assert_eq(
    averagel([
      Int64::from_int(5),
      Int64::from_int(8),
      Int64::from_int(2),
      Int64::from_int(1),
    ]),
    Int64::from_int(4),
  )
  assert_eq(
    averagel([
      Int64::from_int(5),
      Int64::from_int(0),
      Int64::from_int(2),
      Int64::from_int(1),
    ]),
    Int64::from_int(2),
  )
  assert_double_eq(averagef([5.0, 8.0, 2.0, 1.0]), 4.0, 0.0)
  assert_double_eq(averagef([5.0, 0.0, 2.0, 1.0]), 2.0, 0.0)
  assert_double_eq(averaged([5.0, 8.0, 2.0, 1.0]), 4.0, 0.0)
  assert_double_eq(averaged([5.0, 0.0, 2.0, 1.0]), 2.0, 0.0)
}
