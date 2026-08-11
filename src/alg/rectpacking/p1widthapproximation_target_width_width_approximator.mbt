///|
fn rectpacking_target_width_approximator_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  try
    rectpacking_target_width_approximator_process_impl(graph, progress_monitor)
  catch {
    RectpackingWidthApproximationException(message) => {
      @core.layout_runtime_raise_unsupported_configuration(message)
      if progress_monitor is Some(monitor) && monitor.is_running() {
        monitor.done()
      }
    }
    err => raise err
  } noraise {
    _ => ()
  }
}

///|
fn rectpacking_target_width_approximator_process_impl(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
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
pub fn new_rectpacking_target_width_approximator_layout_phase() -> @core.TypedLayoutProcessor[
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_target_width_approximator_process, _ => {
    None
  })
}
