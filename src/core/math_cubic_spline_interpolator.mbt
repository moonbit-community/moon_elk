///|
let interp_coef_even : Array[Array[Double]] = [
  [0.25],
  [0.2677, -0.0667],
  [0.2679, -0.0714, 0.0179],
  [0.2679, -0.0718, 0.0191, -0.0048],
  [0.2679, -0.0718, 0.0192, -0.0051, 0.0013],
  [0.2679, -0.0718, 0.0192, -0.0052, 0.0014, -0.0003],
  [0.2679, -0.0718, 0.0192, -0.0052, 0.0014, -0.0004, 0.0001],
]

///|
let interp_coef_odd : Array[Array[Double]] = [
  [0.3333],
  [0.2727, -0.0909],
  [0.2683, -0.0732, 0.0244],
  [0.2680, -0.0719, 0.0196, -0.0065],
  [0.2680, -0.0718, 0.0193, -0.0053, 0.0018],
  [0.2679, -0.0718, 0.0192, -0.0052, 0.0014, -0.0005],
  [0.2679, -0.0718, 0.0192, -0.0052, 0.0014, -0.0004, 0.0001],
]

///|
let max_k = 7

///|
let tangent_scale = 0.25

///|
pub(all) struct CubicSplineInterpolator {
  _dummy : Unit
}

///|
pub fn new_cubic_spline_interpolator() -> CubicSplineInterpolator {
  { _dummy: () }
}

///|
pub fn CubicSplineInterpolator::calculate_closed_bezier_spline(
  self : CubicSplineInterpolator,
  points : Array[KVector],
) -> BezierSpline {
  ignore(self)
  let spline = new_bezier_spline()
  let n = points.length()
  let even = n % 2 == 0
  let mut m = if even { (n - 2) / 2 } else { (n - 1) / 2 }
  m = if m < max_k { m } else { max_k }
  let d = Array::makei(n, _ => new_kvector())
  let mut i = 0
  while i < n {
    let di = new_kvector()
    let mut k = 1
    while k <= m {
      let a = if even {
        interp_coef_odd[if m - 1 < max_k - 1 { m - 1 } else { max_k - 1 }][if k -
          1 <
          max_k - 1 {
          k - 1
        } else {
          max_k - 1
        }]
      } else {
        interp_coef_even[if m - 1 < max_k - 1 { m - 1 } else { max_k - 1 }][if k -
          1 <
          max_k - 1 {
          k - 1
        } else {
          max_k - 1
        }]
      }
      di.x = di.x + a * (points[(i + k) % n].x - points[(i - k + n) % n].x)
      di.y = di.y + a * (points[(i + k) % n].y - points[(i - k + n) % n].y)
      k = k + 1
    }
    d[i] = di
    i = i + 1
  }
  i = 0
  while i < n {
    spline.add_curve_points(
      points[i],
      kvector_sum([d[i], points[i]]),
      points[(i + 1) % n].clone().sub(d[(i + 1) % n]),
      points[(i + 1) % n],
    )
    i = i + 1
  }
  spline
}

///|
fn calculate_open_bezier_spline(points : Array[KVector]) -> BezierSpline {
  calculate_open_bezier_spline_with_tangent(
    points,
    points[1].clone().sub(points[0]).normalize(),
    points[points.length() - 2]
    .clone()
    .sub(points[points.length() - 1])
    .normalize(),
    false,
  )
}

///|
fn calculate_open_bezier_spline_with_tangent(
  points : Array[KVector],
  start_tan : KVector,
  end_tan : KVector,
  tangent_scale_enabled : Bool,
) -> BezierSpline {
  let spline = new_bezier_spline()
  let n = points.length() - 1
  let t = Array::makei(2 * n, _ => new_kvector())
  let d = Array::makei(n + 1, _ => new_kvector())
  let mut start_scale = 1.0
  let mut end_scale = 1.0
  if tangent_scale_enabled {
    if points.length() == 2 {
      start_scale = points[0].distance(points[1]) * tangent_scale
      end_scale = start_scale
    } else {
      start_scale = points[0].distance(points[1]) * tangent_scale
      end_scale = points[n - 1].distance(points[n]) * tangent_scale
    }
  }
  d[0] = start_tan.clone().scale(start_scale)
  d[n] = end_tan.clone().scale(end_scale)
  t[0] = kvector_sum([points[0], d[0]])
  t[n] = points[n].clone().sub(d[n])
  let mut i = 1
  while i < n {
    t[i] = points[i]
    t[2 * n - i] = t[i]
    i = i + 1
  }
  let m = if n - 1 < max_k { n - 1 } else { max_k }
  i = 1
  while i < n {
    let di = new_kvector()
    let mut k = 1
    while k <= m {
      let a = interp_coef_even[m - 1][k - 1]
      let mirror = (i - k).abs()
      di.x = di.x + a * (t[i + k].x - t[mirror].x)
      di.y = di.y + a * (t[i + k].y - t[mirror].y)
      k = k + 1
    }
    d[i] = di
    i = i + 1
  }
  i = 0
  while i < n {
    let bend1 = kvector_sum([points[i], d[i]])
    let bend2 = points[i + 1].clone().sub(d[i + 1])
    spline.add_curve_points(points[i], bend1, bend2, points[i + 1])
    i = i + 1
  }
  spline
}

///|
pub fn CubicSplineInterpolator::interpolate_points(
  self : CubicSplineInterpolator,
  points : Array[KVector],
) -> BezierSpline {
  ignore(self)
  calculate_open_bezier_spline(points)
}

///|
pub fn CubicSplineInterpolator::interpolate_points_with_tangent(
  self : CubicSplineInterpolator,
  points : Array[KVector],
  start_vec : KVector,
  end_vec : KVector,
  tangent_scale : Bool,
) -> BezierSpline {
  ignore(self)
  calculate_open_bezier_spline_with_tangent(
    points, start_vec, end_vec, tangent_scale,
  )
}
