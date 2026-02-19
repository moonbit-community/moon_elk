///|
fn rectpacking_to_aspectratio_node_expander_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) =>
      ignore(monitor.begin("To Aspect Ratio Whitesapce Eliminator", 1.0))
    None => ()
  }

  let mut width = node_get_double_property(
    graph, rectpacking_internal_drawing_width,
  )
  let height = node_get_double_property(
    graph, rectpacking_internal_drawing_height,
  )
  let desired_aspect_ratio = node_get_double_property(
    graph, rectpacking_aspect_ratio,
  )
  let mut additional_height = node_get_double_property(
    graph, rectpacking_internal_additional_height,
  )
  let aspect_ratio = width / height

  if aspect_ratio < desired_aspect_ratio {
    width = height * desired_aspect_ratio
    node_set_double_property(graph, rectpacking_internal_drawing_width, width)
  } else {
    additional_height += width / desired_aspect_ratio - height
    node_set_double_property(
      graph, rectpacking_internal_additional_height, additional_height,
    )
    node_set_double_property(
      graph,
      rectpacking_internal_drawing_height,
      height + additional_height,
    )
  }

  rectpacking_equal_whitespace_eliminator_process(graph, progress_monitor)

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_to_aspectratio_node_expander_layout_phase() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_phase(rectpacking_to_aspectratio_node_expander_process, _ => None)
}
