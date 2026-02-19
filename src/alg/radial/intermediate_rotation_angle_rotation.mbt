///|
fn angle_rotation_rotate(graph : @graph.ElkNode) -> Unit {
  let mut target_angle = @graph.node_get_double_property(
    graph, radial_rotation_target_angle,
  )
  if @graph.node_get_bool_property(
      graph, radial_rotation_compute_additional_wedge_space,
    ) {
    match radial_internal_root(graph) {
      Some(root) => {
        let outgoing = @graph.node_outgoing_edges(root)
        if !outgoing.is_empty() {
          let last_targets = @graph.edge_targets(outgoing[outgoing.length() - 1])
          let first_targets = @graph.edge_targets(outgoing[0])
          if !last_targets.is_empty() && !first_targets.is_empty() {
            let last_node = @graph.connectable_shape_to_node(Some(last_targets[0]))
            let first_node = @graph.connectable_shape_to_node(Some(first_targets[0]))
            let last_vector = @core.new_kvector_xy(
              @graph.node_x(last_node) + @graph.node_width(last_node) / 2.0,
              @graph.node_y(last_node) + @graph.node_height(last_node) / 2.0,
            )
            let first_vector = @core.new_kvector_xy(
              @graph.node_x(first_node) + @graph.node_width(first_node) / 2.0,
              @graph.node_y(first_node) + @graph.node_height(first_node) / 2.0,
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
  for node in @graph.node_children(graph) {
    let pos = @core.new_kvector_xy(
      @graph.node_x(node) + @graph.node_width(node) / 2.0,
      @graph.node_y(node) + @graph.node_height(node) / 2.0,
    )
    ignore(pos.rotate(target_angle))
    @graph.node_set_location(
      node,
      pos.x - @graph.node_width(node) / 2.0,
      pos.y - @graph.node_height(node) / 2.0,
    )
  }
}

///|
pub struct AngleRotation {
  rotator : IRadialRotator
}

///|
pub fn new_angle_rotation() -> AngleRotation {
  { rotator: new_i_radial_rotator(angle_rotation_rotate) }
}

///|
pub fn AngleRotation::rotate(self : AngleRotation, graph : @graph.ElkNode) -> Unit {
  self.rotator.rotate(graph)
}

///|
pub fn AngleRotation::as_i_radial_rotator(
  self : AngleRotation,
) -> IRadialRotator {
  self.rotator
}
