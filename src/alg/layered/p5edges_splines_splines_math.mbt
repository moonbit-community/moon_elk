///|
let splines_math_epsilon : Double = 0.00000001

///|
let splines_math_null_string : String = "(null)"

///|
pub let splines_math_half_pi : Double = @math.PI / 2.0

///|
pub let splines_math_quarter_pi : Double = splines_math_half_pi / 2.0

///|
pub let splines_math_three_half_pi : Double = splines_math_half_pi +
  splines_math_half_pi +
  splines_math_half_pi

///|
pub let splines_math_two_pi : Double = 2.0 * @math.PI

///|
pub let splines_math_three : Double = 3.0

///|
pub fn splines_math_intersect_by_directions(
  point_1 : @core.KVector,
  point_2 : @core.KVector,
  direction_1 : Double,
  direction_2 : Double,
) -> @core.KVector? {
  splines_math_intersect(
    point_1,
    @core.new_kvector_angle(direction_1).add(point_1.clone()),
    point_2,
    @core.new_kvector_angle(direction_2).add(point_2.clone()),
  )
}

///|
pub fn splines_math_intersect(
  point_1 : @core.KVector,
  point_2 : @core.KVector,
  point_3 : @core.KVector,
  point_4 : @core.KVector,
) -> @core.KVector? {
  let x1 = point_1.x
  let y1 = point_1.y
  let x2 = point_2.x
  let y2 = point_2.y
  let x3 = point_3.x
  let y3 = point_3.y
  let x4 = point_4.x
  let y4 = point_4.y

  let divisor = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  if divisor.abs() < splines_math_epsilon {
    return None
  }

  let first = x1 * y2 - y1 * x2
  let second = x3 * y4 - y3 * x4
  let new_x = (first * (x3 - x4) - second * (x1 - x2)) / divisor
  let new_y = (first * (y3 - y4) - second * (y1 - y2)) / divisor
  Some(@core.new_kvector_xy(new_x, new_y))
}

///|
pub fn splines_math_inner_angle_vectors(
  vector_1 : @core.KVector,
  vector_2 : @core.KVector,
) -> Double {
  @math.acos(
    (vector_1.x * vector_2.x + vector_1.y * vector_2.y) /
    (vector_1.length() * vector_2.length()),
  )
}

///|
pub fn splines_math_inner_angle_directions(
  direction_1 : Double,
  direction_2 : Double,
) -> Double {
  (direction_1 - direction_2).abs() % @math.PI
}

///|
fn splines_math_round_1_decimal(value : Double) -> Double {
  (value * 10.0).round() / 10.0
}

///|
fn splines_math_format_1_decimal(value : Double) -> String {
  let rounded = splines_math_round_1_decimal(value)
  let mut text = rounded.to_string()
  if !text.contains(".") {
    text = text + ".0"
  } else if text.has_suffix(".") {
    text = text + "0"
  }
  text
}

///|
pub fn splines_math_convert_kvector_to_string(
  vector : @core.KVector?,
) -> String {
  match vector {
    Some(value) =>
      "(" +
      splines_math_format_1_decimal(value.x) +
      "," +
      splines_math_format_1_decimal(value.y) +
      ")"
    None => splines_math_null_string
  }
}

///|
pub fn splines_math_convert_kvector_array_to_string(
  vectors : Array[@core.KVector],
) -> String {
  if vectors.is_empty() {
    return splines_math_null_string
  }

  let buffer = @buffer.new()
  for i in 0..<vectors.length() {
    buffer.write_string(
      splines_math_convert_kvector_to_string(Some(vectors[i])),
    )
    if i + 1 < vectors.length() {
      buffer.write_string(", ")
    }
  }
  buffer.to_string()
}

///|
pub fn splines_math_length_to_orthogonal(
  direction : Double,
  point : @core.KVector,
) -> Double {
  let mut angle = splines_math_inner_angle_directions(
    direction,
    point.to_radians(),
  )
  let mut factor = 1

  if angle > splines_math_half_pi {
    factor = -1
    angle = angle - splines_math_quarter_pi
  }

  factor.to_double() * @math.cos(angle) * point.length()
}

///|
pub fn splines_math_port_side_to_direction(side : @core.PortSide) -> Double {
  match side {
    North => splines_math_three_half_pi
    East => 0.0
    South => splines_math_half_pi
    West => @math.PI
    @core.PortSide::SideUndefined => 0.0
  }
}

///|
pub fn splines_math_dist_port_to_node_edge(
  port : LPort,
  side : @core.PortSide,
) -> Double {
  let port_pos = port.get_position().clone().add(port.get_anchor())
  let node_size = port.get_node().unwrap().get_size()

  match side {
    North => -port_pos.y
    East => -port_pos.x + node_size.x
    South => -port_pos.y + node_size.y
    West => -port_pos.x
    @core.PortSide::SideUndefined => 0.0
  }
}

///|
pub fn splines_math_is_between_int(
  value : Int,
  boundary_0 : Int,
  boundary_1 : Int,
) -> Bool {
  if value < boundary_0 {
    boundary_1 <= value
  } else {
    value <= boundary_1 || value == boundary_0
  }
}

///|
pub fn splines_math_is_between_double(
  value : Double,
  boundary_0 : Double,
  boundary_1 : Double,
) -> Bool {
  if (boundary_0 - value).abs() < splines_math_epsilon ||
    (boundary_1 - value).abs() < splines_math_epsilon {
    return true
  }

  if boundary_0 - value > splines_math_epsilon {
    value - boundary_1 > splines_math_epsilon
  } else {
    boundary_1 - value > splines_math_epsilon
  }
}

///|
pub fn splines_math_get_margin_on_port_side(
  node : LNode,
  side : @core.PortSide,
) -> Double {
  match side {
    North => node.get_margin().top
    East => node.get_margin().right
    South => node.get_margin().bottom
    West => node.get_margin().left
    @core.PortSide::SideUndefined => 0.0
  }
}
