///|
fn rectpacking_greedy_width_approximator_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  try
    rectpacking_greedy_width_approximator_process_impl(graph, progress_monitor)
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
fn rectpacking_greedy_width_approximator_process_impl(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise RectpackingWidthApproximationException {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Greedy Width Approximator", 1.0))
    None => ()
  }

  let aspect_ratio = @graph.node_get_double_property(
    graph, rectpacking_aspect_ratio,
  )
  let padding = @core.new_elk_padding()
  padding.parse(@graph.node_get_string_property(graph, rectpacking_padding))
  let goal = rectpacking_optimization_goal_from_string(
    @graph.node_get_string_property(
      graph, rectpacking_width_approximation_optimization_goal,
    ),
  )
  let last_place_shift = @graph.node_get_bool_property(
    graph, rectpacking_width_approximation_last_place_shift,
  )
  let node_node_spacing = @graph.node_get_double_property(
    graph, rectpacking_spacing_node_node,
  )

  let rectangles = @graph.node_children(graph)
  rectpacking_reset_coordinates(rectangles)

  let first_iteration = new_rectpacking_area_approximation(
    aspect_ratio, goal, last_place_shift,
  )
  let drawing = first_iteration.approx_bounding_box(
    rectangles, node_node_spacing, padding,
  )

  @graph.node_set_double_property(
    graph,
    rectpacking_internal_target_width,
    drawing.drawing_width,
  )

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_greedy_width_approximator_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_greedy_width_approximator_process, _ => {
    None
  })
}
