///|
pub struct BezierCurve {
  start : KVector
  fst_control_pnt : KVector
  snd_control_pnt : KVector
  end : KVector
}

///|
pub fn new_bezier_curve(
  start_pnt : KVector,
  fst_ctr_pnt : KVector,
  snd_ctr_pnt : KVector,
  end_pnt : KVector,
) -> BezierCurve {
  {
    start: start_pnt,
    fst_control_pnt: fst_ctr_pnt,
    snd_control_pnt: snd_ctr_pnt,
    end: end_pnt,
  }
}

///|
pub fn BezierCurve::as_vector_list(self : BezierCurve) -> Array[KVector] {
  [self.start, self.fst_control_pnt, self.snd_control_pnt, self.end]
}

///|
pub fn BezierCurve::as_array(self : BezierCurve) -> Array[KVector] {
  [self.start, self.fst_control_pnt, self.snd_control_pnt, self.end]
}

///|
pub struct BezierSpline {
  curves : Array[BezierCurve]
}

///|
pub fn new_bezier_spline() -> BezierSpline {
  { curves: [] }
}

///|
pub fn BezierSpline::add_curve(
  self : BezierSpline,
  curve : BezierCurve,
) -> Unit {
  self.curves.push(curve)
}

///|
pub fn BezierSpline::add_spline(
  self : BezierSpline,
  spline : BezierSpline,
  beginning : Bool,
) -> Unit {
  if !beginning {
    for curve in spline.curves {
      self.curves.push(curve)
    }
  } else {
    let mut i = 0
    while i < spline.curves.length() {
      self.curves.insert(i, spline.curves[i])
      i = i + 1
    }
  }
}

///|
pub fn BezierSpline::add_curve_points(
  self : BezierSpline,
  start_pnt : KVector,
  fst_ctr_pnt : KVector,
  snd_ctr_pnt : KVector,
  end_pnt : KVector,
) -> Unit {
  self.curves.push(
    new_bezier_curve(start_pnt, fst_ctr_pnt, snd_ctr_pnt, end_pnt),
  )
}

///|
pub fn BezierSpline::get_start_point(self : BezierSpline) -> KVector {
  self.curves[0].start
}

///|
pub fn BezierSpline::get_end_point(self : BezierSpline) -> KVector {
  self.curves[self.curves.length() - 1].end
}

///|
pub fn BezierSpline::get_inner_points(self : BezierSpline) -> Array[KVector] {
  if self.curves.is_empty() {
    return []
  }
  let points = []
  let mut i = 0
  while i < self.curves.length() {
    let curve = self.curves[i]
    points.push(curve.fst_control_pnt)
    points.push(curve.snd_control_pnt)
    if i + 1 < self.curves.length() {
      points.push(curve.end)
    }
    i = i + 1
  }
  points
}

///|
pub fn BezierSpline::get_base_points(self : BezierSpline) -> Array[KVector] {
  let points = []
  points.push(self.curves[0].start)
  for curve in self.curves {
    points.push(curve.end)
  }
  points
}

///|
pub fn BezierSpline::get_polyline_apprx(
  self : BezierSpline,
  accuracy : Int,
) -> Array[KVector] {
  let apprx = []
  apprx.push(self.curves[0].start)
  for curve in self.curves {
    let pts = approximate_bezier_segment(accuracy, curve.as_array())
    for p in pts {
      apprx.push(p.clone())
    }
  }
  apprx
}

///|
pub fn BezierSpline::get_curves(self : BezierSpline) -> Array[BezierCurve] {
  self.curves.copy()
}

///|
pub fn BezierSpline::to_string(self : BezierSpline) -> String {
  let buffer = @buffer.new()
  for curve in self.curves {
    buffer.write_string(
      "\{curve.start.to_string()} -> \{curve.fst_control_pnt.to_string()} -> \{curve.snd_control_pnt.to_string()} -> \{curve.end.to_string()}\n",
    )
  }
  buffer.to_string()
}
