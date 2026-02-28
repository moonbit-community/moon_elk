///|
pub(all) struct ISplineInterpolator {
  interpolate_points_fn : (Array[KVector]) -> BezierSpline
}

///|
pub fn new_spline_interpolator(
  interpolate_points_fn : (Array[KVector]) -> BezierSpline,
) -> ISplineInterpolator {
  { interpolate_points_fn, }
}

///|
pub fn ISplineInterpolator::interpolate_points(
  self : ISplineInterpolator,
  points : Array[KVector],
) -> BezierSpline {
  (self.interpolate_points_fn)(points)
}

///|
pub fn cubic_spline_interpolator_as_spline_interpolator(
  interpolator : CubicSplineInterpolator,
) -> ISplineInterpolator {
  new_spline_interpolator(points => interpolator.interpolate_points(points))
}
