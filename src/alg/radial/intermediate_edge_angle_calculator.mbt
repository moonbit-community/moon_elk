///|
pub fn new_radial_edge_angle_calculator_layout_processor() -> @core.ILayoutProcessor[
  RadialLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor((graph, progress_monitor) => {
    ignore(progress_monitor)
    let root = match radial_internal_root(graph) {
      Some(root_node) => root_node
      None => abort("radial root node is missing")
    }
    for edge in @graph.node_outgoing_edges(root) {
      let section = @graph.edge_sections(edge)[0]
      let start = @core.new_kvector_xy(
        @graph.edge_section_start_x(section),
        @graph.edge_section_start_y(section),
      )
      let end = @core.new_kvector_xy(
        @graph.edge_section_end_x(section),
        @graph.edge_section_end_y(section),
      )

      let edge_vector = @core.kvector_diff(end, start)
      let angle = @math.atan2(edge_vector.y, edge_vector.x)

      let target = @graph.connectable_shape_to_node(
        Some(@graph.edge_targets(edge)[0]),
      )
      @graph.node_set_double_property(
        target, radial_rotation_target_angle, angle,
      )
    }
  })
}
