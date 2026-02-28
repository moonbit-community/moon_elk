///|
pub(all) struct AbstractLayoutDebugView {
  view_id : String
  preference_id : String
  model : ExecutionInfoModel
  tree_content_provider : ExecutionInfoContentProvider
  tree_filter_fn : (ExecutionInfo) -> Bool
  mut selected_execution_infos : Array[ExecutionInfo]
  mut filter_enabled : Bool
  mut model_listener : IExecutionInfoModelListener?
  mut tree_expanded : Bool
  mut refresh_count : Int
}

///|
let abstract_layout_debug_view_filter_key : String = ".filterState"

///|
pub fn new_abstract_layout_debug_view(
  view_id : String,
  preference_id : String,
  tree_filter_fn : (ExecutionInfo) -> Bool,
) -> AbstractLayoutDebugView {
  let model = match elk_debug_plugin_get_default() {
    Some(plugin) => plugin.get_model()
    None => new_execution_info_model()
  }
  {
    view_id,
    preference_id,
    model,
    tree_content_provider: new_execution_info_content_provider(),
    tree_filter_fn,
    selected_execution_infos: [],
    filter_enabled: false,
    model_listener: None,
    tree_expanded: true,
    refresh_count: 0,
  }
}

///|
pub fn AbstractLayoutDebugView::attach_model_listener(
  self : AbstractLayoutDebugView,
) -> Unit {
  match self.model_listener {
    Some(_) => ()
    None => {
      let listener = new_execution_info_model_listener(() => {
        self.execution_info_changed()
      })
      self.model.add_execution_info_model_listener(listener)
      self.model_listener = Some(listener)
    }
  }
}

///|
pub fn AbstractLayoutDebugView::dispose(self : AbstractLayoutDebugView) -> Unit {
  match self.model_listener {
    Some(listener) => {
      self.model.remove_execution_info_model_listener(listener)
      self.model_listener = None
    }
    None => ()
  }
}

///|
pub fn AbstractLayoutDebugView::get_model(
  self : AbstractLayoutDebugView,
) -> ExecutionInfoModel {
  self.model
}

///|
pub fn AbstractLayoutDebugView::get_view_id(
  self : AbstractLayoutDebugView,
) -> String {
  self.view_id
}

///|
pub fn AbstractLayoutDebugView::get_preference_id(
  self : AbstractLayoutDebugView,
) -> String {
  self.preference_id
}

///|
pub fn AbstractLayoutDebugView::tree_selection_changed(
  _self : AbstractLayoutDebugView,
) -> Unit {
  ()
}

///|
pub fn AbstractLayoutDebugView::get_selected_execution_infos(
  self : AbstractLayoutDebugView,
) -> Array[ExecutionInfo] {
  self.selected_execution_infos.copy()
}

///|
pub fn AbstractLayoutDebugView::set_selected_execution_infos(
  self : AbstractLayoutDebugView,
  infos : Array[ExecutionInfo],
) -> Unit {
  self.selected_execution_infos = infos.copy()
  self.tree_selection_changed()
}

///|
pub fn AbstractLayoutDebugView::set_filter_tree(
  self : AbstractLayoutDebugView,
  filter : Bool,
) -> Unit {
  self.filter_enabled = filter
  if filter {
    self.tree_content_provider.set_filter(Some(self.tree_filter_fn))
  } else {
    self.tree_content_provider.set_filter(None)
  }
}

///|
pub fn AbstractLayoutDebugView::is_filter_tree_enabled(
  self : AbstractLayoutDebugView,
) -> Bool {
  self.filter_enabled
}

///|
pub fn AbstractLayoutDebugView::collapse_all_tree_viewer_elements(
  self : AbstractLayoutDebugView,
) -> Unit {
  self.tree_expanded = false
  self.tree_selection_changed()
}

///|
pub fn AbstractLayoutDebugView::expand_all_tree_viewer_elements(
  self : AbstractLayoutDebugView,
) -> Unit {
  self.tree_expanded = true
}

///|
pub fn AbstractLayoutDebugView::is_tree_expanded(
  self : AbstractLayoutDebugView,
) -> Bool {
  self.tree_expanded
}

///|
pub fn AbstractLayoutDebugView::execution_info_changed(
  self : AbstractLayoutDebugView,
) -> Unit {
  self.refresh_count = self.refresh_count + 1
  self.tree_selection_changed()
}

///|
pub fn AbstractLayoutDebugView::get_refresh_count_for_test(
  self : AbstractLayoutDebugView,
) -> Int {
  self.refresh_count
}

///|
pub fn AbstractLayoutDebugView::get_visible_root_infos_for_test(
  self : AbstractLayoutDebugView,
) -> Array[ExecutionInfo] {
  self.tree_content_provider.get_elements(
    Some(self.model.get_execution_infos()),
  )
}

///|
pub fn AbstractLayoutDebugView::get_visible_children_for_test(
  self : AbstractLayoutDebugView,
  info : ExecutionInfo,
) -> Array[ExecutionInfo] {
  self.tree_content_provider.get_children(Some(info))
}

///|
pub fn AbstractLayoutDebugView::retrieve_dialog_settings(
  self : AbstractLayoutDebugView,
) -> CoreDebugDialogSettingsSection {
  core_debug_dialog_settings_section(self.view_id)
}

///|
pub fn AbstractLayoutDebugView::load_state(
  self : AbstractLayoutDebugView,
  settings : CoreDebugDialogSettingsSection,
) -> Unit {
  match settings.get_bool(abstract_layout_debug_view_filter_key) {
    Some(filter_enabled) => self.set_filter_tree(filter_enabled)
    None => ()
  }
}

///|
pub fn AbstractLayoutDebugView::persist_state(
  self : AbstractLayoutDebugView,
  settings : CoreDebugDialogSettingsSection,
) -> Unit {
  settings.put_bool(abstract_layout_debug_view_filter_key, self.filter_enabled)
}
