///|
let nubs_self_loop_fraction : Double = 1.3

///|
let nubs_self_loop_half : Double = 0.5

///|
fn nubs_self_loop_port_position(port : LPort) -> @core.KVector {
  port.get_position().clone().add(port.get_anchor())
}

///|
fn new_nubs_self_loop_internal(
  clamped : Bool,
  dimension : Int,
  k_vectors : Array[@core.KVector],
) -> NubsSelfLoop {
  {
    nub_spline: new_nub_spline(clamped, dimension, k_vectors),
    first_label_position: @core.new_kvector(),
  }
}

///|
pub struct NubsSelfLoop {
  nub_spline : NubSpline
  mut first_label_position : @core.KVector
}

///|
pub fn new_nubs_self_loop_copy(nubs : NubsSelfLoop) -> NubsSelfLoop {
  {
    nub_spline: new_nub_spline_copy(nubs.nub_spline),
    first_label_position: nubs.first_label_position.clone(),
  }
}

///|
pub fn new_nubs_self_loop(
  dimension : Int,
  k_vectors : Array[@core.KVector],
) -> NubsSelfLoop {
  new_nubs_self_loop_internal(true, dimension, k_vectors)
}

///|
pub fn new_nubs_self_loop_with_clamped(
  clamped : Bool,
  dimension : Int,
  k_vectors : Array[@core.KVector],
) -> NubsSelfLoop {
  new_nubs_self_loop_internal(clamped, dimension, k_vectors)
}

///|
pub fn NubsSelfLoop::get_first_label_position(
  self : NubsSelfLoop,
) -> @core.KVector {
  self.first_label_position
}

///|
pub fn NubsSelfLoop::set_first_label_position(
  self : NubsSelfLoop,
  position : @core.KVector,
) -> Unit {
  self.first_label_position = position
}

///|
pub fn NubsSelfLoop::get_control_points(
  self : NubsSelfLoop,
) -> @core.KVectorChain {
  self.nub_spline.get_control_points()
}

///|
pub fn NubsSelfLoop::get_dim(self : NubsSelfLoop) -> Int {
  self.nub_spline.get_dim()
}

///|
pub fn NubsSelfLoop::as_nub_spline(self : NubsSelfLoop) -> NubSpline {
  self.nub_spline
}

///|
pub fn nubs_self_loop_create_side_self_loop(
  source : LPort,
  target : LPort,
  length : Double,
) -> NubsSelfLoop {
  let direction = splines_math_port_side_to_direction(source.get_side())
  let source_pos = nubs_self_loop_port_position(source)
  let target_pos = nubs_self_loop_port_position(target)

  let first_cp = source_pos
    .clone()
    .add(@core.new_kvector_angle(direction).scale(length))
  let third_cp = target_pos
    .clone()
    .add(@core.new_kvector_angle(direction).scale(length))
  let mid = first_cp.clone().sub(third_cp).scale(0.5)
  let second_cp = third_cp
    .clone()
    .add(mid)
    .add(@core.new_kvector_angle(direction).scale(mid.length()))

  new_nubs_self_loop_internal(true, nub_spline_dim, [
    source_pos, first_cp, second_cp, third_cp, target_pos,
  ])
}

///|
pub fn nubs_self_loop_create_corner_self_loop(
  source : LPort,
  target : LPort,
  source_height : Double,
  target_height : Double,
) -> NubsSelfLoop {
  let source_dir = splines_math_port_side_to_direction(source.get_side())
  let target_dir = splines_math_port_side_to_direction(target.get_side())
  let source_pos = nubs_self_loop_port_position(source)
  let target_pos = nubs_self_loop_port_position(target)

  let first_cp = source_pos
    .clone()
    .add(
      @core.new_kvector_angle(source_dir).scale(
        nubs_self_loop_fraction * source_height,
      ),
    )
  let third_cp = target_pos
    .clone()
    .add(
      @core.new_kvector_angle(target_dir).scale(
        nubs_self_loop_fraction * target_height,
      ),
    )

  let mut corner_x = 0.0
  let mut corner_y = 0.0

  match source.get_side() {
    West =>
      corner_x = 2.0 * (source_pos.x - source_height) -
        nubs_self_loop_half * (first_cp.x + third_cp.x)
    East =>
      corner_x = 2.0 * (source_pos.x + source_height) -
        nubs_self_loop_half * (first_cp.x + third_cp.x)
    North =>
      corner_y = 2.0 * (source_pos.y - source_height) -
        nubs_self_loop_half * (first_cp.y + third_cp.y)
    South =>
      corner_y = 2.0 * (source_pos.y + source_height) -
        nubs_self_loop_half * (first_cp.y + third_cp.y)
    @core.PortSide::SideUndefined => ()
  }

  match target.get_side() {
    West =>
      corner_x = 2.0 * (target_pos.x - target_height) -
        nubs_self_loop_half * (third_cp.x + first_cp.x)
    East =>
      corner_x = 2.0 * (target_pos.x + target_height) -
        nubs_self_loop_half * (third_cp.x + first_cp.x)
    North =>
      corner_y = 2.0 * (target_pos.y - target_height) -
        nubs_self_loop_half * (third_cp.y + first_cp.y)
    South =>
      corner_y = 2.0 * (target_pos.y + target_height) -
        nubs_self_loop_half * (third_cp.y + first_cp.y)
    @core.PortSide::SideUndefined => ()
  }

  let second_cp = @core.new_kvector_xy(corner_x, corner_y)
  new_nubs_self_loop_internal(true, nub_spline_dim, [
    source_pos, first_cp, second_cp, third_cp, target_pos,
  ])
}

///|
pub fn nubs_self_loop_create_across_self_loop(
  source : LPort,
  target : LPort,
  source_bend_point : @core.KVector,
  corner_bend_points : Array[@core.KVector],
  target_bend_point : @core.KVector,
) -> NubsSelfLoop {
  let source_pos = nubs_self_loop_port_position(source)
  let target_pos = nubs_self_loop_port_position(target)
  if corner_bend_points.length() != 2 {
    abort("corner bend points size must be 2")
  }

  let third_cp = corner_bend_points[0]
  let fourth_cp = corner_bend_points[1]
  let middle_cp = fourth_cp.clone().add(third_cp).scale(nubs_self_loop_half)

  new_nubs_self_loop_internal(true, nub_spline_dim, [
    source_pos, source_bend_point, third_cp, middle_cp, fourth_cp, target_bend_point,
    target_pos,
  ])
}

///|
pub fn nubs_self_loop_create_three_side_self_loop(
  source : LPort,
  target : LPort,
  source_bend_point : @core.KVector,
  corner_bend_points : Array[@core.KVector],
  target_bend_point : @core.KVector,
) -> NubsSelfLoop {
  let source_pos = nubs_self_loop_port_position(source)
  let target_pos = nubs_self_loop_port_position(target)
  if corner_bend_points.length() != 3 {
    abort("corner bend points size must be 3")
  }

  let third_cp = corner_bend_points[0]
  let fourth_cp = corner_bend_points[1]
  let fifth_cp = corner_bend_points[2]

  new_nubs_self_loop_internal(true, nub_spline_dim, [
    source_pos, source_bend_point, third_cp, fourth_cp, fifth_cp, target_bend_point,
    target_pos,
  ])
}

///|
pub fn nubs_self_loop_create_four_side_self_loop(
  source : LPort,
  target : LPort,
  source_bend_point : @core.KVector,
  corner_bend_points : Array[@core.KVector],
  target_bend_point : @core.KVector,
) -> NubsSelfLoop {
  let source_pos = nubs_self_loop_port_position(source)
  let target_pos = nubs_self_loop_port_position(target)
  if corner_bend_points.length() != 4 {
    abort("corner bend points size must be 4")
  }

  let third_cp = corner_bend_points[0]
  let fourth_cp = corner_bend_points[1]
  let fifth_cp = corner_bend_points[2]
  let sixth_cp = corner_bend_points[3]

  new_nubs_self_loop_internal(true, nub_spline_dim, [
    source_pos, source_bend_point, third_cp, fourth_cp, fifth_cp, sixth_cp, target_bend_point,
    target_pos,
  ])
}
