///|
fn rectpacking_equal_whitespace_eliminator_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Equal Whitespace Eliminator", 1.0))
    None => ()
  }

  match rectpacking_internal_get_rows(graph) {
    Some(rows) =>
      rectpacking_rectangle_expansion_expand(
        rows,
        @graph.node_get_double_property(graph, rectpacking_internal_drawing_width),
        @graph.node_get_double_property(graph, rectpacking_internal_additional_height),
        @graph.node_get_double_property(graph, rectpacking_spacing_node_node),
      )
    None => abort("The graph does not contain rows.")
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_equal_whitespace_eliminator_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_equal_whitespace_eliminator_process, _ => None)
}
