///|
pub fn new_radial_edge_angle_calculator_layout_processor() -> ILayoutProcessor[
  RadialLayoutPhases,
  ElkNode,
] {
  new_layout_processor((graph, progress_monitor) => {
    ignore(progress_monitor)
    match radial_internal_root(graph) {
      Some(root) =>
        for edge in node_outgoing_edges(root) {
          let sections = edge_sections(edge)
          if sections.is_empty() {
            continue
          }
          let section = sections[0]
          let start = new_kvector_xy(
            edge_section_start_x(section),
            edge_section_start_y(section),
          )
          let end = new_kvector_xy(
            edge_section_end_x(section),
            edge_section_end_y(section),
          )
          let edge_vector = kvector_diff(end, start)
          let angle = @math.atan2(edge_vector.y, edge_vector.x)
          let targets = edge_targets(edge)
          if targets.is_empty() {
            continue
          }
          let target = connectable_shape_to_node(Some(targets[0]))
          node_set_double_property(target, radial_rotation_target_angle, angle)
        }
      None => ()
    }
  })
}
