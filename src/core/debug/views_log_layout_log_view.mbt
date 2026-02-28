///|
pub let layout_log_view_id : String = "org.eclipse.elk.core.debug.logView"

///|
pub(all) struct LayoutLogView {
  base : AbstractLayoutDebugView
  mut log_text : String
}

///|
fn layout_log_view_filter(info : ExecutionInfo) -> Bool {
  execution_info_has_log_messages(info) ||
  execution_info_has_descendants_with_log_messages(info)
}

///|
pub fn new_layout_log_view() -> LayoutLogView {
  {
    base: new_abstract_layout_debug_view(
      layout_log_view_id, core_debug_pref_debug_logging, layout_log_view_filter,
    ),
    log_text: "",
  }
}

///|
pub fn LayoutLogView::get_base(self : LayoutLogView) -> AbstractLayoutDebugView {
  self.base
}

///|
pub fn LayoutLogView::set_selected_execution_infos(
  self : LayoutLogView,
  infos : Array[ExecutionInfo],
) -> Unit {
  self.base.set_selected_execution_infos(infos)
  self.tree_selection_changed()
}

///|
pub fn LayoutLogView::tree_selection_changed(self : LayoutLogView) -> Unit {
  let chunks : Array[String] = []
  for info in self.base.get_selected_execution_infos() {
    let messages = execution_info_get_log_messages(info)
    if !messages.is_empty() {
      chunks.push(messages.join("\n"))
    }
  }
  if chunks.is_empty() {
    self.log_text = ""
  } else {
    self.log_text = chunks.join("\n\n") + "\n\n"
  }
}

///|
pub fn LayoutLogView::get_log_text(self : LayoutLogView) -> String {
  self.log_text
}
