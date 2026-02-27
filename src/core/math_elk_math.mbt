///|
let _fact_table_size = 21

///|
priv suberror ElkMathException {
  ElkMathException(String)
} derive(Show, ToJson)

///|
fn[T] elk_math_raise(message : String) -> T raise ElkMathException {
  raise ElkMathException(message)
}

///|
fn elk_math_exception_message(err : ElkMathException) -> String {
  match err {
    ElkMathException(message) => message
  }
}

///|
fn factl_impl(x : Int) -> Int64 raise ElkMathException {
  if x < 0 || x >= _fact_table_size {
    elk_math_raise("The input must be between 0 and \{_fact_table_size}")
  }
  let mut result = Int64::from_int(1)
  let mut i = 2
  while i <= x {
    result = result * Int64::from_int(i)
    i = i + 1
  }
  result
}

///|
pub fn factl(x : Int) -> Int64 {
  try factl_impl(x) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        elk_math_exception_message(err),
      )
      Int64::from_int(0)
    }
  } noraise {
    value => value
  }
}

///|
fn factd_impl(x : Int) -> Double raise ElkMathException {
  if x < 0 {
    elk_math_raise("The input must be positive")
  }
  if x < _fact_table_size {
    return factl_impl(x).to_double()
  }
  (2.0 * @math.PI * x.to_double()).sqrt() *
  (powf(x.to_double(), x) / powd(@math.exp(1.0), x))
}

///|
pub fn factd(x : Int) -> Double {
  try factd_impl(x) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        elk_math_exception_message(err),
      )
      0.0
    }
  } noraise {
    value => value
  }
}

///|
fn binomiall_impl(n : Int, k : Int) -> Int64 raise ElkMathException {
  if n < 0 || k < 0 {
    elk_math_raise("k and n must be positive")
  }
  if k > n {
    elk_math_raise("k must be smaller than n")
  }
  if k == 0 || k == n {
    return Int64::from_int(1)
  }
  if n == 0 {
    return Int64::from_int(0)
  }
  if n < _fact_table_size {
    return factl_impl(n) / (factl_impl(k) * factl_impl(n - k))
  }
  binomiall_impl(n - 1, k - 1) + binomiall_impl(n - 1, k)
}

///|
pub fn binomiall(n : Int, k : Int) -> Int64 {
  try binomiall_impl(n, k) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        elk_math_exception_message(err),
      )
      Int64::from_int(0)
    }
  } noraise {
    value => value
  }
}

///|
fn binomiald_impl(n : Int, k : Int) -> Double raise ElkMathException {
  if n < 0 || k < 0 {
    elk_math_raise("k and n must be positive")
  }
  if k > n {
    elk_math_raise("k must be smaller than n")
  }
  if k == 0 || k == n {
    return 1.0
  }
  if n == 0 {
    return 0.0
  }
  factd_impl(n) / (factd_impl(k) * factd_impl(n - k))
}

///|
pub fn binomiald(n : Int, k : Int) -> Double {
  try binomiald_impl(n, k) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        elk_math_exception_message(err),
      )
      0.0
    }
  } noraise {
    value => value
  }
}

///|
pub fn powd(a : Double, b : Int) -> Double {
  let mut result = 1.0
  let mut base = a
  let mut exp = if b >= 0 { b } else { -b }
  while exp > 0 {
    if exp % 2 == 0 {
      base = base * base
      exp = exp / 2
    } else {
      result = result * base
      exp = exp - 1
    }
  }
  if b < 0 {
    1.0 / result
  } else {
    result
  }
}

///|
pub fn powf(a : Double, b : Int) -> Double {
  let mut result = 1.0
  let mut base = a
  let mut exp = if b >= 0 { b } else { -b }
  while exp > 0 {
    if exp % 2 == 0 {
      base = base * base
      exp = exp / 2
    } else {
      result = result * base
      exp = exp - 1
    }
  }
  if b < 0 {
    1.0 / result
  } else {
    result
  }
}

///|
pub fn approximate_bezier_segment(
  result_size : Int,
  control_points : Array[KVector],
) -> Array[KVector] {
  if result_size <= 0 {
    return []
  }
  let result = []
  let dt = 1.0 / result_size.to_double()
  let mut t = 0.0
  let mut i = 0
  while i < result_size {
    t = t + dt
    result.push(get_point_on_bezier_segment(t, control_points))
    i = i + 1
  }
  result
}

///|
pub fn approximate_bezier_segment_auto(
  control_points : Array[KVector],
) -> Array[KVector] {
  let approximation_count = control_points.length() + 1
  approximate_bezier_segment(approximation_count, control_points)
}

///|
pub fn get_point_on_bezier_segment(
  t : Double,
  control_points : Array[KVector],
) -> KVector {
  let n = control_points.length() - 1
  let mut px = 0.0
  let mut py = 0.0
  let mut j = 0
  while j <= n {
    let p = control_points[j]
    let factor = binomiald(n, j) * powd(1.0 - t, n - j) * powd(t, j)
    px = px + p.x * factor
    py = py + p.y * factor
    j = j + 1
  }
  new_kvector_xy(px, py)
}

///|
pub fn approximate_bezier_spline(control_points : KVectorChain) -> KVectorChain {
  let ctrl_pt_count = control_points.size()
  let spline = new_kvector_chain()
  let mut index = 0
  let mut current_point = control_points.get(index)
  spline.add_vector(current_point)
  index = index + 1
  while index < ctrl_pt_count {
    let remaining_points = ctrl_pt_count - index
    if remaining_points == 1 {
      spline.add_vector(control_points.get(index))
      index = index + 1
    } else if remaining_points == 2 {
      let seg = approximate_bezier_segment_auto([
        current_point,
        control_points.get(index),
        control_points.get(index + 1),
      ])
      spline.add_all(seg)
      index = index + 2
    } else {
      let control1 = control_points.get(index)
      let control2 = control_points.get(index + 1)
      let next_point = control_points.get(index + 2)
      let seg = approximate_bezier_segment_auto([
        current_point, control1, control2, next_point,
      ])
      spline.add_all(seg)
      current_point = next_point
      index = index + 3
    }
  }
  spline
}

///|
let w_degree = 5

///|
let degree = 3

///|
let cubic_z : Array[Array[Double]] = [
  [1.0, 0.6, 0.3, 0.1],
  [0.4, 0.6, 0.6, 0.4],
  [0.1, 0.3, 0.6, 1.0],
]

///|
pub fn distance_from_bezier_segment(
  start : KVector,
  c1 : KVector,
  c2 : KVector,
  end : KVector,
  needle : KVector,
) -> Double {
  let t_candidate = Array::make(w_degree, 0.0)
  let v = [start, c1, c2, end]
  let w = convert_to_bezier_form(v, needle)
  let n_solutions = find_roots(w, w_degree, t_candidate, 0)
  let mut min_distance = needle.distance(start)
  let mut t = 0.0
  let mut i = 0
  while i < n_solutions {
    let p = bezier(v, degree, t_candidate[i], None, None)
    let distance = needle.distance(p)
    if distance < min_distance {
      min_distance = distance
      t = t_candidate[i]
    }
    i = i + 1
  }
  let distance_to_end = needle.distance(end)
  if distance_to_end < min_distance {
    t = 1.0
  }
  let pn = new_kvector_copy(bezier(v, degree, t, None, None))
  pn.distance(needle).sqrt()
}

///|
fn convert_to_bezier_form(v : Array[KVector], pa : KVector) -> Array[KVector] {
  let c = Array::makei(degree + 1, _ => new_kvector())
  let d = Array::makei(degree, _ => new_kvector())
  let cd_table = Array::makei(degree, _ => Array::make(degree + 1, 0.0))
  let w = Array::makei(w_degree + 1, _ => new_kvector())
  let mut i = 0
  while i <= degree {
    c[i] = new_kvector_xy(v[i].x - pa.x, v[i].y - pa.y)
    i = i + 1
  }
  let s = degree.to_double()
  i = 0
  while i <= degree - 1 {
    d[i] = new_kvector_xy(s * (v[i + 1].x - v[i].x), s * (v[i + 1].y - v[i].y))
    i = i + 1
  }
  let mut row = 0
  while row <= degree - 1 {
    let mut column = 0
    while column <= degree {
      cd_table[row][column] = d[row].x * c[column].x + d[row].y * c[column].y
      column = column + 1
    }
    row = row + 1
  }
  i = 0
  while i <= w_degree {
    w[i] = new_kvector_xy(i.to_double() / w_degree.to_double(), 0.0)
    i = i + 1
  }
  let n = degree
  let m = degree - 1
  let mut k = 0
  while k <= n + m {
    let lb = if 0 > k - m { 0 } else { k - m }
    let ub = if k < n { k } else { n }
    i = lb
    while i <= ub {
      let j = k - i
      let entry = w[i + j]
      entry.y = entry.y + cd_table[j][i] * cubic_z[j][i]
      w[i + j] = entry
      i = i + 1
    }
    k = k + 1
  }
  w
}

///|
let max_depth = 64

///|
fn find_roots(
  w : Array[KVector],
  degree : Int,
  t : Array[Double],
  depth : Int,
) -> Int {
  match crossing_count(w, degree) {
    0 => return 0
    1 => {
      if depth >= max_depth {
        t[0] = (w[0].x + w[w_degree].x) / 2.0
        return 1
      }
      if control_polygon_flat_enough(w, degree) {
        t[0] = compute_x_intercept(w, degree)
        return 1
      }
    }
    _ => ()
  }
  let left = Array::makei(w_degree + 1, _ => new_kvector())
  let right = Array::makei(w_degree + 1, _ => new_kvector())
  let left_t = Array::make(w_degree + 1, 0.0)
  let right_t = Array::make(w_degree + 1, 0.0)
  ignore(bezier(w, degree, 0.5, Some(left), Some(right)))
  let left_count = find_roots(left, degree, left_t, depth + 1)
  let right_count = find_roots(right, degree, right_t, depth + 1)
  let mut i = 0
  while i < left_count {
    t[i] = left_t[i]
    i = i + 1
  }
  i = 0
  while i < right_count {
    t[i + left_count] = right_t[i]
    i = i + 1
  }
  left_count + right_count
}

///|
let epsilon : Double = @math.pow(2.0, -max_depth.to_double() - 1.0)

///|
fn control_polygon_flat_enough(v : Array[KVector], degree : Int) -> Bool {
  let a = v[0].y - v[degree].y
  let b = v[degree].x - v[0].x
  let c = v[0].x * v[degree].y - v[degree].x * v[0].y
  let ab_squared = a * a + b * b
  let distance = Array::make(degree + 1, 0.0)
  let mut i = 1
  while i < degree {
    let mut di = a * v[i].x + b * v[i].y + c
    if di > 0.0 {
      di = di * di / ab_squared
    }
    if di < 0.0 {
      di = -(di * di / ab_squared)
    }
    distance[i] = di
    i = i + 1
  }
  let mut max_distance_above = 0.0
  let mut max_distance_below = 0.0
  i = 1
  while i < degree {
    if distance[i] < 0.0 {
      max_distance_below = if max_distance_below < distance[i] {
        max_distance_below
      } else {
        distance[i]
      }
    }
    if distance[i] > 0.0 {
      max_distance_above = if max_distance_above > distance[i] {
        max_distance_above
      } else {
        distance[i]
      }
    }
    i = i + 1
  }
  let a1 = 0.0
  let b1 = 1.0
  let c1 = 0.0
  let mut a2 = a
  let mut b2 = b
  let mut c2 = c + max_distance_above
  let mut det = a1 * b2 - a2 * b1
  let mut d_inv = 1.0 / det
  let intercept1 = (b1 * c2 - b2 * c1) * d_inv
  a2 = a
  b2 = b
  c2 = c + max_distance_below
  det = a1 * b2 - a2 * b1
  d_inv = 1.0 / det
  let intercept2 = (b1 * c2 - b2 * c1) * d_inv
  let left_intercept = if intercept1 < intercept2 {
    intercept1
  } else {
    intercept2
  }
  let right_intercept = if intercept1 > intercept2 {
    intercept1
  } else {
    intercept2
  }
  let error = (right_intercept - left_intercept) / 2.0
  error < epsilon
}

///|
fn compute_x_intercept(v : Array[KVector], degree : Int) -> Double {
  let xnm = v[degree].x - v[0].x
  let ynm = v[degree].y - v[0].y
  let xmk = v[0].x
  let ymk = v[0].y
  let det_inv = -1.0 / ynm
  (xnm * ymk - ynm * xmk) * det_inv
}

///|
fn crossing_count(v : Array[KVector], degree : Int) -> Int {
  let mut n_crossings = 0
  let mut sign = if v[0].y < 0.0 { -1 } else { 1 }
  let mut old_sign = sign
  let mut i = 1
  while i <= degree {
    sign = if v[i].y < 0.0 { -1 } else { 1 }
    if sign != old_sign {
      n_crossings = n_crossings + 1
    }
    old_sign = sign
    i = i + 1
  }
  n_crossings
}

///|
fn bezier(
  c : Array[KVector],
  degree : Int,
  t : Double,
  left : Array[KVector]?,
  right : Array[KVector]?,
) -> KVector {
  let p = Array::makei(w_degree + 1, _ => {
    Array::makei(w_degree + 1, _ => new_kvector())
  })
  let mut j = 0
  while j <= degree {
    p[0][j] = new_kvector_copy(c[j])
    j = j + 1
  }
  let mut i = 1
  while i <= degree {
    j = 0
    while j <= degree - i {
      p[i][j] = new_kvector_xy(
        (1.0 - t) * p[i - 1][j].x + t * p[i - 1][j + 1].x,
        (1.0 - t) * p[i - 1][j].y + t * p[i - 1][j + 1].y,
      )
      j = j + 1
    }
    i = i + 1
  }
  match left {
    Some(left_arr) => {
      j = 0
      while j <= degree {
        left_arr[j] = p[j][0]
        j = j + 1
      }
    }
    None => ()
  }
  match right {
    Some(right_arr) => {
      j = 0
      while j <= degree {
        right_arr[j] = p[degree - j][j]
        j = j + 1
      }
    }
    None => ()
  }
  p[degree][0]
}

///|
pub fn maxi(values : Array[Int]) -> Int {
  let mut max = @int.min_value
  for value in values {
    if value > max {
      max = value
    }
  }
  max
}

///|
pub fn mini(values : Array[Int]) -> Int {
  let mut min = @int.max_value
  for value in values {
    if value < min {
      min = value
    }
  }
  min
}

///|
pub fn averagei(values : Array[Int]) -> Int {
  let mut avg = 0
  for value in values {
    avg = avg + value
  }
  avg / values.length()
}

///|
pub fn maxl(values : Array[Int64]) -> Int64 {
  let mut max = Int64::from_int(@int.min_value)
  for value in values {
    if value > max {
      max = value
    }
  }
  max
}

///|
pub fn minl(values : Array[Int64]) -> Int64 {
  let mut min = Int64::from_int(@int.max_value)
  for value in values {
    if value < min {
      min = value
    }
  }
  min
}

///|
pub fn averagel(values : Array[Int64]) -> Int64 {
  let mut avg = Int64::from_int(0)
  for value in values {
    avg = avg + value
  }
  avg / Int64::from_int(values.length())
}

///|
pub fn maxf(values : Array[Double]) -> Double {
  let mut max = -@float.max_value.to_double()
  for value in values {
    if value > max {
      max = value
    }
  }
  max
}

///|
pub fn minf(values : Array[Double]) -> Double {
  let mut min = @float.max_value.to_double()
  for value in values {
    if value < min {
      min = value
    }
  }
  min
}

///|
pub fn averagef(values : Array[Double]) -> Double {
  let mut avg = 0.0
  for value in values {
    avg = avg + value
  }
  avg / values.length().to_double()
}

///|
pub fn maxd(values : Array[Double]) -> Double {
  let mut max = -@double.max_value
  for value in values {
    if value > max {
      max = value
    }
  }
  max
}

///|
pub fn mind(values : Array[Double]) -> Double {
  let mut min = @double.max_value
  for value in values {
    if value < min {
      min = value
    }
  }
  min
}

///|
pub fn averaged(values : Array[Double]) -> Double {
  let mut avg = 0.0
  for value in values {
    avg = avg + value
  }
  avg / values.length().to_double()
}

///|
pub fn boundi(x : Int, lower : Int, upper : Int) -> Int {
  if x <= lower {
    return lower
  }
  if x >= upper {
    return upper
  }
  x
}

///|
pub fn boundl(x : Int64, lower : Int64, upper : Int64) -> Int64 {
  if x <= lower {
    return lower
  }
  if x >= upper {
    return upper
  }
  x
}

///|
pub fn boundf(x : Double, lower : Double, upper : Double) -> Double {
  if x <= lower {
    return lower
  }
  if x >= upper {
    return upper
  }
  x
}

///|
pub fn boundd(x : Double, lower : Double, upper : Double) -> Double {
  if x <= lower {
    return lower
  }
  if x >= upper {
    return upper
  }
  x
}

///|
pub fn clip_vector(v : KVector, width : Double, height : Double) -> KVector {
  let wh = width / 2.0
  let hh = height / 2.0
  let absx = v.x.abs()
  let absy = v.y.abs()
  let mut xscale = 1.0
  let mut yscale = 1.0
  if absx > wh {
    xscale = wh / absx
  }
  if absy > hh {
    yscale = hh / absy
  }
  ignore(v.scale(if xscale < yscale { xscale } else { yscale }))
  v
}

///|
pub fn signum(x : Double) -> Int {
  if x < 0.0 {
    return -1
  }
  if x > 0.0 {
    return 1
  }
  0
}

///|
pub fn intersects_rect_path(rect : ElkRectangle, path : KVectorChain) -> Bool {
  if path.size() < 2 {
    return false
  }
  let first = path.get(0)
  let mut p1 = first
  let mut i = 1
  while i < path.size() {
    let p2 = path.get(i)
    if intersects_rect_line(rect, p1, p2) {
      return true
    }
    p1 = p2
    i = i + 1
  }
  if intersects_rect_line(rect, p1, first) {
    return true
  }
  false
}

///|
pub fn intersects_rect_line(
  rect : ElkRectangle,
  p1 : KVector,
  p2 : KVector,
) -> Bool {
  if contains_rect_line(rect, p1, p2) {
    return false
  }
  intersects_line(rect.get_top_left(), rect.get_top_right(), p1, p2) ||
  intersects_line(rect.get_top_right(), rect.get_bottom_right(), p1, p2) ||
  intersects_line(rect.get_bottom_right(), rect.get_bottom_left(), p1, p2) ||
  intersects_line(rect.get_bottom_left(), rect.get_top_left(), p1, p2)
}

///|
let double_eq_epsilon = 0.00001

///|
pub fn intersects_line(
  l11 : KVector,
  l12 : KVector,
  l21 : KVector,
  l22 : KVector,
) -> Bool {
  let u0 = l11
  let v0 = l12.clone().sub(l11)
  let u1 = l21
  let v1 = l22.clone().sub(l21)
  let x00 = u0.x
  let y00 = u0.y
  let x10 = u1.x
  let y10 = u1.y
  let x01 = v0.x
  let y01 = v0.y
  let x11 = v1.x
  let y11 = v1.y
  let d = x11 * y01 - x01 * y11
  if _fuzzy_equals(0.0, d, double_eq_epsilon) {
    return false
  }
  let s = 1.0 / d * ((x00 - x10) * y01 - (y00 - y10) * x01)
  let t = 1.0 / d * -(-(x00 - x10) * y11 + (y00 - y10) * x11)
  _fuzzy_compare(0.0, s, double_eq_epsilon) < 0 &&
  _fuzzy_compare(s, 1.0, double_eq_epsilon) < 0 &&
  _fuzzy_compare(0.0, t, double_eq_epsilon) < 0 &&
  _fuzzy_compare(t, 1.0, double_eq_epsilon) < 0
}

///|
pub fn intersects2(
  p : KVector,
  r : KVector,
  q : KVector,
  s : KVector,
) -> KVector? {
  let pq = q.clone().sub(p)
  let pq_x_r = kvector_cross_product(pq, r)
  let r_x_s = kvector_cross_product(r, s)
  let t = kvector_cross_product(pq, s) / r_x_s
  let u = pq_x_r / r_x_s
  if r_x_s == 0.0 {
    if pq_x_r == 0.0 {
      let center = q.clone().add(s.clone().scale(0.5))
      let d1 = p.distance(center)
      let d2 = p.clone().add(r).distance(center)
      let l = s.length() * 0.5
      if d1 < d2 && d1 <= l {
        return Some(p.clone())
      }
      if d2 <= l {
        return Some(p.clone().add(r))
      }
      return None
    }
    return None
  }
  if t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0 {
    Some(p.clone().add(r.clone().scale(t)))
  } else {
    None
  }
}

///|
pub fn distance(
  a1 : KVector,
  a2 : KVector,
  b1 : KVector,
  b2 : KVector,
  v : KVector,
) -> Double {
  let d1 = trace_rays(a1, a2, b1, b2, v)
  let d2 = trace_rays(b1, b2, a1, a2, v.clone().negate())
  if d1 < d2 {
    d1
  } else {
    d2
  }
}

///|
fn trace_rays(
  a1 : KVector,
  a2 : KVector,
  b1 : KVector,
  b2 : KVector,
  v : KVector,
) -> Double {
  let mut result = @double.infinity
  let mut endpoint_hit = false
  let edge_case = match
    intersects2(a1, a2.clone().sub(a1), b1.clone().add(v), b2.clone().sub(b1)) {
    Some(intersection) =>
      !(intersection.equals_fuzzily(a1) || intersection.equals_fuzzily(a2))
    None => false
  }
  match intersects2(a1, a2.clone().sub(a1), b1, v) {
    Some(intersection) =>
      if intersection.equals_fuzzily(a1) == intersection.equals_fuzzily(a2) ||
        edge_case {
        let ray_distance : Double = intersection.sub(b1).length()
        result = if result < ray_distance { result } else { ray_distance }
      } else {
        endpoint_hit = true
      }
    None => ()
  }
  match intersects2(a1, a2.clone().sub(a1), b2, v) {
    Some(intersection) =>
      if endpoint_hit ||
        intersection.equals_fuzzily(a1) == intersection.equals_fuzzily(a2) ||
        edge_case {
        let ray_distance : Double = intersection.sub(b2).length()
        result = if result < ray_distance { result } else { ray_distance }
      }
    None => ()
  }
  result
}

///|
pub fn contains_rect_path(rect : ElkRectangle, path : KVectorChain) -> Bool {
  if path.size() < 2 {
    return false
  }
  let first = path.get(0)
  let mut p1 = first
  let mut i = 1
  while i < path.size() {
    let p2 = path.get(i)
    if !contains_rect_line(rect, p1, p2) {
      return false
    }
    p1 = p2
    i = i + 1
  }
  if !contains_rect_line(rect, p1, first) {
    return false
  }
  true
}

///|
pub fn contains_rect_line(
  rect : ElkRectangle,
  p1 : KVector,
  p2 : KVector,
) -> Bool {
  contains_rect_point(rect, p1) && contains_rect_point(rect, p2)
}

///|
pub fn contains_rect_point(rect : ElkRectangle, p : KVector) -> Bool {
  let min_x = rect.x
  let max_x = rect.x + rect.width
  let min_y = rect.y
  let max_y = rect.y + rect.height
  (p.x > min_x && p.x < max_x) && p.y > min_y && p.y < max_y
}

///|
pub fn shortest_distance(r1 : ElkRectangle, r2 : ElkRectangle) -> Double {
  let right_dist = r2.x - (r1.x + r1.width)
  let left_dist = r1.x - (r2.x + r2.width)
  let top_dist = r1.y - (r2.y + r2.height)
  let bottom_dist = r2.y - (r1.y + r1.height)
  let horz_dist = if left_dist > right_dist { left_dist } else { right_dist }
  let vert_dist = if top_dist > bottom_dist { top_dist } else { bottom_dist }
  let horz_non_neg = _fuzzy_compare(horz_dist, 0.0, double_eq_epsilon) >= 0
  let vert_non_neg = _fuzzy_compare(vert_dist, 0.0, double_eq_epsilon) >= 0
  if horz_non_neg != vert_non_neg {
    return if vert_dist > horz_dist { vert_dist } else { horz_dist }
  }
  if _fuzzy_compare(horz_dist, 0.0, double_eq_epsilon) > 0 {
    return (vert_dist * vert_dist + horz_dist * horz_dist).sqrt()
  }
  -(vert_dist * vert_dist + horz_dist * horz_dist).sqrt()
}
