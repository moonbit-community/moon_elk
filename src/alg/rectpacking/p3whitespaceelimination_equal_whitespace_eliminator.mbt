///|
priv suberror RectPackingEqualWhitespaceEliminatorException {
  UnsupportedConfiguration(String)
} derive(Debug, ToJson)

///|
fn rectpacking_raise_unsupported_configuration(
  message : String,
) -> Unit raise RectPackingEqualWhitespaceEliminatorException {
  raise UnsupportedConfiguration(message)
}

///|
fn rectpacking_equal_whitespace_eliminator_process(
  session : RectPackingSession,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  try
    rectpacking_equal_whitespace_eliminator_process_impl(
      session, graph, progress_monitor,
    )
  catch {
    UnsupportedConfiguration(message) => {
      if progress_monitor is Some(monitor) && monitor.is_running() {
        monitor.done()
      }
      @core.layout_runtime_raise_unsupported_configuration(message)
    }
    err => raise err
  } noraise {
    _ => ()
  }
}

///|
fn rectpacking_equal_whitespace_eliminator_process_impl(
  session : RectPackingSession,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Equal Whitespace Eliminator", 1.0))
    None => ()
  }

  match session.get_rows(graph) {
    Some(rows) =>
      rectpacking_rectangle_expansion_expand(
        rows,
        @graph.node_get_double_property(
          graph, rectpacking_internal_drawing_width,
        ),
        @graph.node_get_double_property(
          graph, rectpacking_internal_additional_height,
        ),
        @graph.node_get_double_property(graph, rectpacking_spacing_node_node),
      )
    None =>
      rectpacking_raise_unsupported_configuration(
        "The graph does not contain rows.",
      )
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_rectpacking_equal_whitespace_eliminator_layout_phase(
  session : RectPackingSession,
) -> @core.ILayoutProcessor[RectPackingLayoutPhases, @graph.ElkNode] {
  @core.new_layout_phase(
    (graph, progress_monitor) => {
      rectpacking_equal_whitespace_eliminator_process(
        session, graph, progress_monitor,
      )
    },
    _ => None,
  )
}
