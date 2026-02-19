///|
fn rectpacking_no_placement_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("No Compaction", 1.0))
    None => ()
  }

  let padding = @core.new_elk_padding()
  padding.parse(@graph.node_get_string_property(graph, rectpacking_padding))
  let rectangles = @graph.node_children(graph)

  let size = rectpacking_calculate_dimensions_rectangles(rectangles)
  let width = @math.maximum(
    size.x,
    @graph.node_get_double_property(graph, rectpacking_internal_min_width) -
    padding.get_horizontal(),
  )
  let height = @math.maximum(
    size.y,
    @graph.node_get_double_property(graph, rectpacking_internal_min_height) -
    padding.get_vertical(),
  )
  let additional_height = height - size.y

  @graph.node_set_double_property(
    graph, rectpacking_internal_additional_height, additional_height,
  )
  @graph.node_set_double_property(graph, rectpacking_internal_drawing_width, width)
  @graph.node_set_double_property(
    graph,
    rectpacking_internal_drawing_height,
    height + additional_height,
  )

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_no_placement_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_no_placement_process, _ => None)
}
