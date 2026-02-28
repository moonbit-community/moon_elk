///|
fn rectpacking_target_width_approximator_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  try
    rectpacking_target_width_approximator_process_impl(graph, progress_monitor)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        rectpacking_width_approximation_exception_message(err),
      )
      if progress_monitor is Some(monitor) && monitor.is_running() {
        monitor.done()
      }
    }
  } noraise {
    _ => ()
  }
}

///|
fn rectpacking_target_width_approximator_process_impl(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise RectpackingWidthApproximationException {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Target Width Setter", 1.0))
    None => ()
  }

  if @graph.node_has_double_property(
      graph, rectpacking_width_approximation_target_width,
    ) {
    @graph.node_set_double_property(
      graph,
      rectpacking_internal_target_width,
      @graph.node_get_double_property(
        graph, rectpacking_width_approximation_target_width,
      ),
    )
  } else {
    rectpacking_width_approximation_raise(
      "A target width has to be set if the TargetWidthWidthApproximator should be used.",
    )
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_target_width_approximator_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_target_width_approximator_process, _ => {
    None
  })
}
