///|
test "ISplineInterpolator delegates to cubic interpolator" {
  let cubic = new_cubic_spline_interpolator()
  let interpolator = cubic_spline_interpolator_as_spline_interpolator(cubic)
  let points = [
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(10.0, 0.0),
    new_kvector_xy(20.0, 0.0),
  ]
  let spline = interpolator.interpolate_points(points)
  inspect(spline.get_curves().length(), content="2")
}
