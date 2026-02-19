///|
pub let nub_spline_dim : Int = 3

///|
let nub_spline_epsilon : Double = 0.000001

///|
pub struct PolarCP {
  cp : KVector
  polar_coordinate : Array[Double]
}

///|
fn new_polar_cp(
  control_point : KVector,
  polar_coordinate : Array[Double],
) -> PolarCP {
  { cp: control_point.clone(), polar_coordinate: polar_coordinate.copy() }
}

///|
fn new_polar_cp_copy(polar_cp : PolarCP) -> PolarCP {
  {
    cp: polar_cp.cp.clone(),
    polar_coordinate: polar_cp.polar_coordinate.copy(),
  }
}

///|
fn PolarCP::get_cp(self : PolarCP) -> KVector {
  self.cp
}

///|
fn PolarCP::to_string(self : PolarCP) -> String {
  self.cp.to_string() + "@" + self.polar_coordinate.to_string()
}

///|
fn nub_spline_create_uniform_knot_vector(
  clamped : Bool,
  dimension : Int,
  size : Int,
) -> (Array[Double], Double, Double) {
  if size < 2 * dimension {
    abort("The knot vector must have at least two time the dimension elements.")
  }

  let knot_vector = []
  let mut min_knot = 0.0
  let mut max_knot = 1.0
  let mut my_size = 0.0

  if clamped {
    min_knot = 0.0
    max_knot = 1.0
    for _ in 0..<dimension {
      knot_vector.push(0.0)
    }
    my_size = (size + 1 - 2 * dimension).to_double()
  } else {
    my_size = (size + 1).to_double()
    let ddim = dimension.to_double()
    min_knot = ddim / (my_size + 1.0)
    max_knot = (my_size - ddim) / my_size
  }

  for i in 1..<my_size.to_int() {
    knot_vector.push(i.to_double() / my_size)
  }

  if clamped {
    for _ in 0..<dimension {
      knot_vector.push(1.0)
    }
  }

  (knot_vector, min_knot, max_knot)
}

///|
fn nub_spline_get_t_from_polar(polar : Array[Double]) -> Double {
  let mut sum = 0.0
  for value in polar {
    sum += value
  }
  sum / polar.length().to_double()
}

///|
pub struct NubSpline {
  knot_vector : Array[Double]
  control_points : Array[PolarCP]
  dim_nubs : Int
  is_uniform : Bool
  is_clamped : Bool
  mut outer_box : Rectangle?
  is_bezier : Bool
  min_knot : Double
  max_knot : Double
}

///|
fn new_nub_spline_precalculated(
  clamped : Bool,
  uniform : Bool,
  bezier : Bool,
  dim : Int,
  knot_vector : Array[Double],
  control_points : Array[PolarCP],
) -> NubSpline {
  if knot_vector.is_empty() {
    abort("knot vector may not be empty")
  }
  {
    is_clamped: clamped,
    is_uniform: uniform,
    is_bezier: bezier,
    dim_nubs: dim,
    knot_vector,
    control_points,
    outer_box: None,
    min_knot: knot_vector[0],
    max_knot: knot_vector[knot_vector.length() - 1],
  }
}

///|
pub fn new_nub_spline_copy(nub_spline : NubSpline) -> NubSpline {
  let knot_vector = nub_spline.knot_vector.copy()
  let control_points = []
  for polar_cp in nub_spline.control_points {
    control_points.push(new_polar_cp_copy(polar_cp))
  }
  {
    dim_nubs: nub_spline.dim_nubs,
    is_uniform: nub_spline.is_uniform,
    is_clamped: nub_spline.is_clamped,
    outer_box: nub_spline.outer_box,
    is_bezier: nub_spline.is_bezier,
    knot_vector,
    min_knot: nub_spline.min_knot,
    max_knot: nub_spline.max_knot,
    control_points,
  }
}

///|
pub fn new_nub_spline(
  clamped : Bool,
  dimension : Int,
  k_vectors : Array[KVector],
) -> NubSpline {
  if dimension < 1 {
    abort("The dimension must be at least 1!")
  }

  let control_vectors = k_vectors.copy()
  if control_vectors.is_empty() {
    abort("At (least dimension + 1) control points are necessary!")
  }

  let mut i = control_vectors.length() - 1
  while i < dimension {
    ignore(control_vectors.insert(0, control_vectors[0]))
    i += 1
  }

  if control_vectors.length() < dimension + 1 {
    abort("At (least dimension + 1) control points are necessary!")
  }

  let (knot_vector, min_knot, max_knot) = nub_spline_create_uniform_knot_vector(
    clamped,
    dimension,
    control_vectors.length() + dimension - 1,
  )

  let polar_coordinate = []
  let mut knot_index = 0
  for _ in 0..<(dimension - 1) {
    polar_coordinate.push(knot_vector[knot_index])
    knot_index += 1
  }

  let control_points = []
  for vector in control_vectors {
    polar_coordinate.push(knot_vector[knot_index])
    knot_index += 1
    control_points.push(new_polar_cp(vector, polar_coordinate))
    ignore(polar_coordinate.remove(0))
  }

  {
    dim_nubs: dimension,
    is_clamped: clamped,
    is_uniform: true,
    is_bezier: false,
    knot_vector,
    control_points,
    outer_box: None,
    min_knot,
    max_knot,
  }
}

///|
pub fn nub_spline_generate_derived(nub_spline : NubSpline) -> NubSpline {
  let new_clamped = nub_spline.is_clamped
  let new_uniform = nub_spline.is_uniform
  let new_bezier = nub_spline.is_bezier
  let old_dim = nub_spline.dim_nubs
  let new_dim = old_dim - 1
  if new_dim < 1 {
    abort("Cannot derive NUBS with dimension <= 1")
  }

  let old_knot_vector = nub_spline.knot_vector
  let new_knot_vector = []
  for i in 1..<(nub_spline.knot_vector.length() - 1) {
    new_knot_vector.push(nub_spline.knot_vector[i])
  }

  let new_control_points = []
  for i in 0..<(nub_spline.control_points.length() - 1) {
    let numerator = nub_spline.control_points[i + 1]
      .get_cp()
      .clone()
      .sub(nub_spline.control_points[i].get_cp())
    let denominator = old_knot_vector[i + old_dim] - old_knot_vector[i]
    if denominator.abs() < nub_spline_epsilon {
      abort("Cannot derive NUBS on degenerated knot interval")
    }
    new_control_points.push(numerator.scale(old_dim.to_double() / denominator))
  }

  let polar_coordinate = []
  let mut knot_index = 0
  for _ in 0..<(new_dim - 1) {
    polar_coordinate.push(new_knot_vector[knot_index])
    knot_index += 1
  }

  let new_polar_vectors = []
  for vector in new_control_points {
    polar_coordinate.push(new_knot_vector[knot_index])
    knot_index += 1
    new_polar_vectors.push(new_polar_cp(vector, polar_coordinate))
    ignore(polar_coordinate.remove(0))
  }

  new_nub_spline_precalculated(
    new_clamped, new_uniform, new_bezier, new_dim, new_knot_vector, new_polar_vectors,
  )
}

///|
pub fn nub_spline_generate_inverted(nub_spline : NubSpline) -> NubSpline {
  let new_knot_vector = []
  let max_vector = nub_spline.knot_vector[nub_spline.knot_vector.length() - 1]
  for vector in nub_spline.knot_vector {
    ignore(new_knot_vector.insert(0, max_vector - vector))
  }

  let reversed_chain = kvector_chain_reverse(nub_spline.get_control_points())
  let new_control_points = reversed_chain.to_array()

  let polar_coordinate = []
  let mut knot_index = 0
  for _ in 0..<(nub_spline.dim_nubs - 1) {
    polar_coordinate.push(new_knot_vector[knot_index])
    knot_index += 1
  }

  let new_polar_vectors = []
  for vector in new_control_points {
    polar_coordinate.push(new_knot_vector[knot_index])
    knot_index += 1
    new_polar_vectors.push(new_polar_cp(vector, polar_coordinate))
    ignore(polar_coordinate.remove(0))
  }

  new_nub_spline_precalculated(
    nub_spline.is_clamped,
    nub_spline.is_uniform,
    nub_spline.is_bezier,
    nub_spline.dim_nubs,
    new_knot_vector,
    new_polar_vectors,
  )
}

///|
pub fn NubSpline::get_dim(self : NubSpline) -> Int {
  self.dim_nubs
}

///|
pub fn NubSpline::get_outer_box(self : NubSpline) -> Rectangle {
  match self.outer_box {
    Some(rectangle) => rectangle
    None => {
      let rectangle = new_rectangle_vectors(
        self.get_control_points().to_array(),
      )
      self.outer_box = Some(rectangle)
      rectangle
    }
  }
}

///|
pub fn NubSpline::set_outer_box(
  self : NubSpline,
  outer_rectangle : Rectangle,
) -> Unit {
  self.outer_box = Some(outer_rectangle)
}

///|
pub fn NubSpline::get_control_points(self : NubSpline) -> KVectorChain {
  let result = new_kvector_chain()
  for polar_cp in self.control_points {
    result.add_vector(polar_cp.get_cp())
  }
  result
}

///|
pub fn NubSpline::get_control_point(self : NubSpline, i : Int) -> KVector {
  self.control_points[i].get_cp()
}

///|
pub fn NubSpline::get_control_points_size(self : NubSpline) -> Int {
  self.control_points.length()
}

///|
pub fn NubSpline::get_knot_vector(self : NubSpline) -> Array[Double] {
  self.knot_vector.copy()
}

///|
fn nub_spline_get_zero_y_of_control_polygon(nub_spline : NubSpline) -> Double {
  if nub_spline.control_points.length() < 2 {
    return 0.0
  }

  let mut second_cp = nub_spline.control_points[0]
  let mut second_y = second_cp.get_cp().y
  let mut second_is_positive = second_y > nub_spline_epsilon
  let mut second_is_negative = second_y < -nub_spline_epsilon

  for i in 1..<nub_spline.control_points.length() {
    let first_cp = second_cp
    let first_y = second_y
    let first_is_positive = second_is_positive
    let first_is_negative = second_is_negative

    second_cp = nub_spline.control_points[i]
    second_y = second_cp.get_cp().y
    second_is_positive = second_y > nub_spline_epsilon
    second_is_negative = second_y < -nub_spline_epsilon

    if !(second_is_positive || second_is_negative) {
      return nub_spline_get_t_from_control_point(second_cp)
    }

    if (first_is_positive && second_is_negative) ||
      (first_is_negative && second_is_positive) {
      let factor = first_y / (first_y - second_y)
      let t1 = nub_spline_get_t_from_control_point(first_cp)
      let t2 = nub_spline_get_t_from_control_point(second_cp)
      return factor * t1 + (1.0 - factor) * t2
    }
  }

  0.0
}

///|
fn nub_spline_get_zero_x_of_control_polygon(nub_spline : NubSpline) -> Double {
  if nub_spline.control_points.length() < 2 {
    return 0.0
  }

  let mut second_cp = nub_spline.control_points[0]
  let mut second_x = second_cp.get_cp().x
  let mut second_is_positive = second_x > nub_spline_epsilon
  let mut second_is_negative = second_x < -nub_spline_epsilon

  for i in 1..<nub_spline.control_points.length() {
    let first_cp = second_cp
    let first_x = second_x
    let first_is_positive = second_is_positive
    let first_is_negative = second_is_negative

    second_cp = nub_spline.control_points[i]
    second_x = second_cp.get_cp().x
    second_is_positive = second_x > nub_spline_epsilon
    second_is_negative = second_x < -nub_spline_epsilon

    if !(second_is_positive || second_is_negative) {
      return nub_spline_get_t_from_control_point(second_cp)
    }

    if (first_is_positive && second_is_negative) ||
      (first_is_negative && second_is_positive) {
      let factor = first_x / (first_x - second_x)
      let t1 = nub_spline_get_t_from_control_point(first_cp)
      let t2 = nub_spline_get_t_from_control_point(second_cp)
      return factor * t1 + (1.0 - factor) * t2
    }
  }

  0.0
}

///|
fn NubSpline::find_span(self : NubSpline, t : Double) -> Int {
  let n = self.control_points.length() - 1
  let degree = self.dim_nubs - 1
  if n < 0 || degree < 0 {
    return 0
  }

  if t >= self.knot_vector[n + 1] {
    return n
  }
  if t <= self.knot_vector[degree] {
    return degree
  }

  let mut low = degree
  let mut high = n + 1
  let mut mid = (low + high) / 2
  while t < self.knot_vector[mid] || t >= self.knot_vector[mid + 1] {
    if t < self.knot_vector[mid] {
      high = mid
    } else {
      low = mid
    }
    mid = (low + high) / 2
  }
  mid
}

///|
pub fn NubSpline::get_point_on_curve(self : NubSpline, t : Double) -> KVector {
  let n = self.control_points.length() - 1
  let degree = self.dim_nubs - 1
  if n < 0 {
    return new_kvector()
  }
  if degree <= 0 {
    return self.control_points[0].get_cp().clone()
  }
  if (t - self.min_knot).abs() < nub_spline_epsilon {
    return self.control_points[0].get_cp().clone()
  }
  if (t - self.max_knot).abs() < nub_spline_epsilon {
    return self.control_points[self.control_points.length() - 1]
      .get_cp()
      .clone()
  }

  let span = self.find_span(t)
  let d = []
  for j in 0..<=degree {
    d.push(self.control_points[span - degree + j].get_cp().clone())
  }

  for r in 1..<=degree {
    let mut j = degree
    while j >= r {
      let i = span - degree + j
      let denominator = self.knot_vector[i + degree - r + 1] -
        self.knot_vector[i]
      let alpha = if denominator.abs() < nub_spline_epsilon {
        0.0
      } else {
        (t - self.knot_vector[i]) / denominator
      }

      let left = d[j - 1].clone().scale(1.0 - alpha)
      let right = d[j].clone().scale(alpha)
      d[j] = left.add(right)

      if j == r {
        break
      }
      j -= 1
    }
  }

  d[degree]
}

///|
pub fn NubSpline::get_point_on_curve_with_modify(
  self : NubSpline,
  t : Double,
  modify : Bool,
) -> KVector {
  ignore(modify)
  self.get_point_on_curve(t)
}

///|
pub fn nub_spline_get_first_vertical_point(
  nub_spline : NubSpline,
  accuracy : Double,
  max_recursion : Int,
) -> KVector {
  let first_derive = nub_spline_generate_derived(nub_spline)
  let mut current_accuracy = @double.infinity
  let mut current_vector = new_kvector()
  let mut loop_count = 0
  let mut knot = 0.0

  while current_accuracy > accuracy && loop_count < max_recursion {
    knot = nub_spline_get_zero_x_of_control_polygon(first_derive)
    current_vector = first_derive.get_point_on_curve_with_modify(knot, true)
    current_accuracy = current_vector.x.abs()
    loop_count += 1
  }

  nub_spline.get_point_on_curve_with_modify(knot, false)
}

///|
pub fn nub_spline_get_last_vertical_point(
  nub_spline : NubSpline,
  accuracy : Double,
  max_recursion : Int,
) -> KVector {
  let first_derive = nub_spline_generate_inverted(
    nub_spline_generate_derived(nub_spline),
  )
  let mut current_accuracy = @double.infinity
  let mut current_vector = new_kvector()
  let mut loop_count = 0
  let mut knot = 0.0

  while current_accuracy > accuracy && loop_count < max_recursion {
    knot = nub_spline_get_zero_x_of_control_polygon(first_derive)
    current_vector = first_derive.get_point_on_curve_with_modify(knot, true)
    current_accuracy = current_vector.x.abs()
    loop_count += 1
  }

  nub_spline.get_point_on_curve_with_modify(nub_spline.max_knot - knot, false)
}

///|
pub fn nub_spline_get_first_horizontal_point(
  nub_spline : NubSpline,
  accuracy : Double,
  max_recursion : Int,
) -> KVector {
  let first_derive = nub_spline_generate_derived(nub_spline)
  let mut current_accuracy = @double.infinity
  let mut current_vector = new_kvector()
  let mut loop_count = 0
  let mut knot = 0.0

  while current_accuracy > accuracy && loop_count < max_recursion {
    knot = nub_spline_get_zero_y_of_control_polygon(first_derive)
    current_vector = first_derive.get_point_on_curve_with_modify(knot, true)
    current_accuracy = current_vector.y.abs()
    loop_count += 1
  }

  nub_spline.get_point_on_curve_with_modify(knot, false)
}

///|
pub fn nub_spline_get_last_horizontal_point(
  nub_spline : NubSpline,
  accuracy : Double,
  max_recursion : Int,
) -> KVector {
  let first_derive = nub_spline_generate_inverted(
    nub_spline_generate_derived(nub_spline),
  )
  let mut current_accuracy = @double.infinity
  let mut current_vector = new_kvector()
  let mut loop_count = 0
  let mut knot = 0.0

  while current_accuracy > accuracy && loop_count < max_recursion {
    knot = nub_spline_get_zero_y_of_control_polygon(first_derive)
    current_vector = first_derive.get_point_on_curve_with_modify(knot, true)
    current_accuracy = current_vector.y.abs()
    loop_count += 1
  }

  nub_spline.get_point_on_curve_with_modify(nub_spline.max_knot - knot, false)
}

///|
fn nub_spline_mirror_on_x(original : KVector, x_value : Double) -> KVector {
  new_kvector_xy(x_value + x_value - original.x, original.y)
}

///|
pub fn nub_spline_generate_nice_curve() -> NubSpline {
  let nice_chain = new_kvector_chain()
  let vector1 = new_kvector_xy(5.5, 23.0)
  let vector2 = new_kvector_xy(2.5, 12.0)
  let vector3 = new_kvector_xy(5.0, 10.0)
  let vector4 = new_kvector_xy(5.0, 9.0)
  let vector5 = new_kvector_xy(3.8, 5.5)
  let vector6 = new_kvector_xy(7.0, 4.0)
  let vector7 = new_kvector_xy(7.0, 3.5)
  let vector8 = new_kvector_xy(6.0, 2.2)
  let vector9 = new_kvector_xy(8.0, 0.5)

  nice_chain.add_vector(vector1)
  nice_chain.add_vector(vector1)
  nice_chain.add_vector(vector1)
  nice_chain.add_vector(vector2)
  nice_chain.add_vector(vector3)
  nice_chain.add_vector(vector4)
  nice_chain.add_vector(vector5)
  nice_chain.add_vector(vector6)
  nice_chain.add_vector(vector7)
  nice_chain.add_vector(vector8)
  nice_chain.add_vector(vector9)
  nice_chain.add_vector(nub_spline_mirror_on_x(vector8, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector7, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector6, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector5, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector4, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector3, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector2, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector1, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector1, vector9.x))
  nice_chain.add_vector(nub_spline_mirror_on_x(vector1, vector9.x))

  ignore(nice_chain.scale(5.0))
  ignore(nice_chain.offset_xy(-50.0, -80.0))

  new_nub_spline(true, 3, nice_chain.to_array())
}

///|
pub fn NubSpline::to_string(self : NubSpline) -> String {
  let pieces = []
  for control_point in self.control_points {
    pieces.push(control_point.to_string())
  }
  pieces.to_string()
}

///|
pub fn nub_spline_get_t_from_control_point(cp : PolarCP) -> Double {
  nub_spline_get_t_from_polar(cp.polar_coordinate)
}
