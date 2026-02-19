///|
pub struct LayoutGraphViewDropAdapter {
  layout_graph_view : LayoutGraphView
}

///|
pub fn new_layout_graph_view_drop_adapter(
  layout_graph_view : LayoutGraphView,
) -> LayoutGraphViewDropAdapter {
  { layout_graph_view, }
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
) -> Bool {
  if file_paths.is_empty() {
    return false
  }
  for file_path in file_paths {
    load_graph_action_run_file(Some(file_path), self.layout_graph_view)
  }
  true
}
