///|
pub fn new_radial_general_rotator_layout_processor() -> @core.ILayoutProcessor[
  RadialLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor((graph, progress_monitor) => {
    match progress_monitor {
      Some(monitor) => {
        ignore(monitor.begin("General 'Rotator", 1.0))
        if monitor.is_logging_enabled() {
          monitor.log_graph("Before")
        }
      }
      None => ()
    }
    let rotator = new_angle_rotation().as_i_radial_rotator()
    rotator.rotate(graph)
    match progress_monitor {
      Some(monitor) =>
        if monitor.is_logging_enabled() {
          monitor.log_graph("After")
        }
      None => ()
    }
  })
}
