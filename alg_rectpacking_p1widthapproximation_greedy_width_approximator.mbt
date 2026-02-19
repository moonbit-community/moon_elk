///|
fn rectpacking_greedy_width_approximator_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Greedy Width Approximator", 1.0))
    None => ()
  }

  let aspect_ratio = node_get_double_property(graph, rectpacking_aspect_ratio)
  let padding = new_elk_padding()
  padding.parse(node_get_string_property(graph, rectpacking_padding))
  let goal = rectpacking_optimization_goal_from_string(
    node_get_string_property(
      graph, rectpacking_width_approximation_optimization_goal,
    ),
  )
  let last_place_shift = node_get_bool_property(
    graph, rectpacking_width_approximation_last_place_shift,
  )
  let node_node_spacing = node_get_double_property(
    graph, rectpacking_spacing_node_node,
  )

  let rectangles = node_children(graph)
  rectpacking_reset_coordinates(rectangles)

  let first_iteration = new_rectpacking_area_approximation(
    aspect_ratio, goal, last_place_shift,
  )
  let drawing = first_iteration.approx_bounding_box(
    rectangles, node_node_spacing, padding,
  )

  node_set_double_property(
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
pub fn new_rectpacking_greedy_width_approximator_layout_phase() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_phase(rectpacking_greedy_width_approximator_process, _ => None)
}
