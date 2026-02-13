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
