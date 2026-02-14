///|
let polyline_self_loop_router_corner_distance : Double = 10.0

///|
let polyline_self_loop_router_tolerance : Double = 0.01

///|
fn polyline_self_loop_router_sign(value : Double) -> Double {
  if value > 0.0 {
    1.0
  } else if value < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
fn polyline_self_loop_router_near_zero_to_zero(vector : KVector) -> KVector {
  if vector.x >= -polyline_self_loop_router_tolerance &&
    vector.x <= polyline_self_loop_router_tolerance {
    vector.x = 0.0
  }
  if vector.y >= -polyline_self_loop_router_tolerance &&
    vector.y <= polyline_self_loop_router_tolerance {
    vector.y = 0.0
  }
  vector
}

///|
fn polyline_self_loop_router_fuzzy_equals(
  left : Double,
  right : Double,
  tolerance : Double,
) -> Bool {
  (left - right).abs() <= tolerance
}

///|
fn polyline_self_loop_router_are_orthogonally_routed(
  previous : KVector,
  corner : KVector,
  next : KVector,
) -> Bool {
  let vertical_horizontal = polyline_self_loop_router_fuzzy_equals(
      previous.x,
      corner.x,
      polyline_self_loop_router_tolerance,
    ) &&
    polyline_self_loop_router_fuzzy_equals(
      corner.y,
      next.y,
      polyline_self_loop_router_tolerance,
    )
  let horizontal_vertical = polyline_self_loop_router_fuzzy_equals(
      previous.y,
      corner.y,
      polyline_self_loop_router_tolerance,
    ) &&
    polyline_self_loop_router_fuzzy_equals(
      corner.x,
      next.x,
      polyline_self_loop_router_tolerance,
    )
  vertical_horizontal || horizontal_vertical
}

///|
pub fn polyline_self_loop_router_cut_corners(
  bend_points : KVectorChain,
  distance : Double,
) -> KVectorChain {
  if bend_points.size() <= 2 {
    return new_kvector_chain()
  }

  let result = new_kvector_chain()
  let mut corner = bend_points.get(0)
  let mut next = bend_points.get(1)

  for index in 2..<bend_points.size() {
    let previous = corner
    corner = next
    next = bend_points.get(index)

    if !polyline_self_loop_router_are_orthogonally_routed(
        previous, corner, next,
      ) {
      continue
    }

    let offset_1 = polyline_self_loop_router_near_zero_to_zero(
      previous.clone().sub(corner),
    )
    let offset_2 = polyline_self_loop_router_near_zero_to_zero(
      next.clone().sub(corner),
    )

    let mut effective_distance = distance
    effective_distance = @math.minimum(
      effective_distance,
      (offset_1.x + offset_1.y).abs() / 2.0,
    )
    effective_distance = @math.minimum(
      effective_distance,
      (offset_2.x + offset_2.y).abs() / 2.0,
    )

    offset_1.x = polyline_self_loop_router_sign(offset_1.x) * effective_distance
    offset_1.y = polyline_self_loop_router_sign(offset_1.y) * effective_distance
    offset_2.x = polyline_self_loop_router_sign(offset_2.x) * effective_distance
    offset_2.y = polyline_self_loop_router_sign(offset_2.y) * effective_distance

    result.add_last_vector(offset_1.add(corner))
    result.add_last_vector(offset_2.add(corner))
  }

  result
}

///|
fn polyline_self_loop_router_modify_bend_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  bend_points : KVectorChain,
) -> KVectorChain {
  ignore(routing_direction)
  let source_port = sl_edge.get_sl_source().get_l_port()
  bend_points.add_first_vector(
    source_port.get_position().clone().add(source_port.get_anchor()),
  )

  let target_port = sl_edge.get_sl_target().get_l_port()
  bend_points.add_last_vector(
    target_port.get_position().clone().add(target_port.get_anchor()),
  )

  polyline_self_loop_router_cut_corners(
    bend_points, polyline_self_loop_router_corner_distance,
  )
}

///|
pub fn polyline_self_loop_router_route_self_loops(
  sl_holder : SelfLoopHolder,
) -> Unit {
  orthogonal_self_loop_router_route_with_modifier(
    sl_holder, polyline_self_loop_router_modify_bend_points,
  )
}

///|
pub fn new_polyline_self_loop_router() -> AbstractSelfLoopRouter {
  new_abstract_self_loop_router(polyline_self_loop_router_route_self_loops)
}
