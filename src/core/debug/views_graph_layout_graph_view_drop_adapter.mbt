///|
pub(all) struct LayoutGraphViewDropAdapter {
  runtime : @core.LayoutRuntime
  session : @core.LayoutSession
  layout_graph_view : LayoutGraphView
}

///|
pub fn new_layout_graph_view_drop_adapter(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  layout_graph_view : LayoutGraphView,
) -> LayoutGraphViewDropAdapter {
  { runtime, session, layout_graph_view }
}

///|
pub fn LayoutGraphViewDropAdapter::validate_drop(
  _self : LayoutGraphViewDropAdapter,
) -> Bool {
  true
}

///|
pub fn LayoutGraphViewDropAdapter::perform_drop(
  self : LayoutGraphViewDropAdapter,
  file_paths : Array[String],
) -> Bool raise {
  if file_paths.is_empty() {
    return false
  }
  for file_path in file_paths {
    load_graph_action_run_file(
      self.runtime,
      self.session,
      Some(file_path),
      self.layout_graph_view,
    )
  }
  true
}
