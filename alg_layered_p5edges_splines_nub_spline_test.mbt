///|
let nub_spline_test_tolerance : Double = 0.0001

///|
fn nub_spline_test_assert_close(actual : Double, expected : Double) -> Unit {
  let diff = (actual - expected).abs()
  if diff > nub_spline_test_tolerance {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
test "nub spline constructor builds expected clamped-uniform basics" {
  let spline = new_nub_spline(true, 3, [
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(10.0, 0.0),
    new_kvector_xy(20.0, 10.0),
    new_kvector_xy(30.0, 10.0),
  ])

  assert_eq(spline.get_dim(), 3)
  assert_eq(spline.get_control_points_size(), 4)

  let knot_vector = spline.get_knot_vector()
  assert_eq(knot_vector.length(), 6)
  for i in 0..<3 {
    nub_spline_test_assert_close(knot_vector[i], 0.0)
  }
  for i in 3..<6 {
    nub_spline_test_assert_close(knot_vector[i], 1.0)
  }
}

///|
test "nub spline derived and inverted generators keep expected shape metadata" {
  let spline = new_nub_spline(true, 3, [
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(10.0, 0.0),
    new_kvector_xy(20.0, 10.0),
    new_kvector_xy(30.0, 10.0),
  ])

  let derived = nub_spline_generate_derived(spline)
  assert_eq(derived.get_dim(), 2)
  assert_eq(derived.get_control_points_size(), 3)
  let first_derived_cp = derived.get_control_point(0)
  nub_spline_test_assert_close(first_derived_cp.x, 30.0)
  nub_spline_test_assert_close(first_derived_cp.y, 0.0)

  let inverted = nub_spline_generate_inverted(spline)
  assert_eq(inverted.get_dim(), 3)
  assert_eq(inverted.get_control_points_size(), 4)
  let first_inverted_cp = inverted.get_control_point(0)
  nub_spline_test_assert_close(first_inverted_cp.x, 30.0)
  nub_spline_test_assert_close(first_inverted_cp.y, 10.0)
}
