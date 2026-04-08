///|
priv suberror RectPackingEqualWhitespaceEliminatorException {
  UnsupportedConfiguration(String)
} derive(Debug, ToJson)

///|
fn rectpacking_raise_unsupported_configuration(
  message : String,
) -> Unit raise RectPackingEqualWhitespaceEliminatorException {
  raise RectPackingEqualWhitespaceEliminatorException::UnsupportedConfiguration(
    message,
  )
}

///|
fn rectpacking_equal_whitespace_eliminator_exception_message(
  err : RectPackingEqualWhitespaceEliminatorException,
) -> String {
  match err {
    RectPackingEqualWhitespaceEliminatorException::UnsupportedConfiguration(
      message
    ) => message
  }
}

///|
fn rectpacking_equal_whitespace_eliminator_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  try
    rectpacking_equal_whitespace_eliminator_process_impl(
      graph, progress_monitor,
    )
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        rectpacking_equal_whitespace_eliminator_exception_message(err),
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
fn rectpacking_equal_whitespace_eliminator_process_impl(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise RectPackingEqualWhitespaceEliminatorException {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Equal Whitespace Eliminator", 1.0))
    None => ()
  }

  match rectpacking_internal_get_rows(graph) {
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
pub fn new_rectpacking_equal_whitespace_eliminator_layout_phase() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(rectpacking_equal_whitespace_eliminator_process, _ => {
    None
  })
}
