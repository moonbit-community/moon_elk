///|
fn radial_rotate_angle(graph : ElkNode) -> Unit {
  let mut target_angle = node_get_double_property(
    graph, radial_rotation_target_angle,
  )
  if node_get_bool_property(
      graph, radial_rotation_compute_additional_wedge_space,
    ) {
    match radial_internal_root(graph) {
      Some(root) => {
        let outgoing = node_outgoing_edges(root)
        if !outgoing.is_empty() {
          let last_targets = edge_targets(outgoing[outgoing.length() - 1])
          let first_targets = edge_targets(outgoing[0])
          if !last_targets.is_empty() && !first_targets.is_empty() {
            let last_node = connectable_shape_to_node(Some(last_targets[0]))
            let first_node = connectable_shape_to_node(Some(first_targets[0]))
            let last_vector = new_kvector_xy(
              node_x(last_node) + node_width(last_node) / 2.0,
              node_y(last_node) + node_height(last_node) / 2.0,
            )
            let first_vector = new_kvector_xy(
              node_x(first_node) + node_width(first_node) / 2.0,
              node_y(first_node) + node_height(first_node) / 2.0,
            )
            let mut alpha = target_angle
            if alpha <= 0.0 {
              alpha += 2.0 * @math.PI
            }
            let mut wedge_angle = last_vector.angle(first_vector)
            if wedge_angle <= 0.0 {
              wedge_angle += 2.0 * @math.PI
            }
            let mut alignment_angle = @math.atan2(last_vector.y, last_vector.x)
            if alignment_angle <= 0.0 {
              alignment_angle += 2.0 * @math.PI
            }
            target_angle = @math.PI -
              (alignment_angle - alpha + wedge_angle / 2.0)
          }
        }
      }
      None => ()
    }
  }
  for node in node_children(graph) {
    let pos = new_kvector_xy(
      node_x(node) + node_width(node) / 2.0,
      node_y(node) + node_height(node) / 2.0,
    )
    ignore(pos.rotate(target_angle))
    node_set_location(
      node,
      pos.x - node_width(node) / 2.0,
      pos.y - node_height(node) / 2.0,
    )
  }
}

///|
pub fn new_radial_general_rotator_layout_processor() -> ILayoutProcessor[
  RadialLayoutPhases,
  ElkNode,
] {
  new_layout_processor((graph, progress_monitor) => {
    match progress_monitor {
      Some(monitor) => {
        ignore(monitor.begin("General 'Rotator", 1.0))
        if monitor.is_logging_enabled() {
          monitor.log_graph("Before")
        }
      }
      None => ()
    }
    radial_rotate_angle(graph)
    match progress_monitor {
      Some(monitor) => {
        if monitor.is_logging_enabled() {
          monitor.log_graph("After")
        }
        monitor.done()
      }
      None => ()
    }
  })
}
