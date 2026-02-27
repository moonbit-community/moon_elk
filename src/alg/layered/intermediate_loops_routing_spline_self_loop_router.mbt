///|
let spline_self_loop_router_dim : Int = 3

///|
let spline_self_loop_router_half : Double = 0.5

///|
fn spline_self_loop_router_relative_port_anchor(
  sl_port : SelfLoopPort,
) -> @core.KVector {
  let l_port = sl_port.get_l_port()
  @core.new_kvector_copy(l_port.get_position()).add(l_port.get_anchor())
}

///|
fn spline_self_loop_router_add_spline_control_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  ortho_bend_points : @core.KVectorChain,
  new_bend_points : @core.KVectorChain,
  edge_label_distance : Double,
) -> Unit {
  if ortho_bend_points.size() < 2 {
    return
  }

  let mut curr_port_side = sl_edge.get_sl_source().get_l_port().get_side()
  let mut first_bp = ortho_bend_points.get(0)

  for second_bp_index in 1..<ortho_bend_points.size() {
    let second_bp = ortho_bend_points.get(second_bp_index)
    new_bend_points.add_last_vector(first_bp)

    let mid_bp = @core.new_kvector_copy(first_bp)
      .add(second_bp)
      .scale(spline_self_loop_router_half)
    let offset = @core.new_kvector_angle(
      splines_math_port_side_to_direction(curr_port_side),
    ).scale(edge_label_distance)
    ignore(mid_bp.add(offset))
    new_bend_points.add_last_vector(mid_bp)

    first_bp = second_bp
    curr_port_side = match routing_direction {
      EdgeRoutingDirection::Clockwise => curr_port_side.right()
      EdgeRoutingDirection::CounterClockwise => curr_port_side.left()
    }
  }

  new_bend_points.add_last_vector(
    ortho_bend_points.get(ortho_bend_points.size() - 1),
  )
}

///|
fn spline_self_loop_router_modify_bend_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  bend_points : @core.KVectorChain,
) -> @core.KVectorChain {
  let sl_loop = match sl_edge.get_sl_hyper_loop() {
    Some(curr_loop) => curr_loop
    None => return bend_points
  }
  let edge_label_distance = get_individual_or_inherited(
    sl_loop.get_sl_holder().get_l_node(),
    @core.spacing_edge_label,
  )

  let spline_bend_points = @core.new_kvector_chain()
  spline_bend_points.add_last_vector(
    spline_self_loop_router_relative_port_anchor(sl_edge.get_sl_source()),
  )
  spline_self_loop_router_add_spline_control_points(
    sl_edge, routing_direction, bend_points, spline_bend_points, edge_label_distance,
  )
  spline_bend_points.add_last_vector(
    spline_self_loop_router_relative_port_anchor(sl_edge.get_sl_target()),
  )

  let spline = try
    new_nub_spline(
      true,
      spline_self_loop_router_dim,
      spline_bend_points.to_array(),
    )
  catch {
    NubSplineException::IllegalArgumentException(message) => {
      @core.layout_runtime_report_unsupported_configuration(
        "java.lang.IllegalArgumentException: " + message,
      )
      return bend_points
    }
  } noraise {
    value => value
  }
  spline.get_control_points()
}

///|
pub fn spline_self_loop_router_route_self_loops(
  sl_holder : SelfLoopHolder,
) -> Unit {
  orthogonal_self_loop_router_route_with_modifier(
    sl_holder, spline_self_loop_router_modify_bend_points,
  )
}

///|
pub fn new_spline_self_loop_router() -> AbstractSelfLoopRouter {
  new_abstract_self_loop_router(spline_self_loop_router_route_self_loops)
}
