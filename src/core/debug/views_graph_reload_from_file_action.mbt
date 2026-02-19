///|
pub let reload_from_file_action_id : String = "org.eclipse.elk.debug.actions.reloadFromFile"

///|
pub(all) struct ReloadFromFileAction {
  view : LayoutGraphView
  mut enabled : Bool
}

///|
pub fn new_reload_from_file_action(
  view : LayoutGraphView,
) -> ReloadFromFileAction {
  { view, enabled: false }
}

///|
pub fn ReloadFromFileAction::is_enabled(self : ReloadFromFileAction) -> Bool {
  self.enabled
}

///|
pub fn ReloadFromFileAction::update_enablement(
  self : ReloadFromFileAction,
) -> Unit {
  let selection = self.view.get_selected_execution_infos()
  self.enabled = selection.length() == 1 &&
    execution_info_is_loaded_from_file(selection[0])
}

///|
pub fn ReloadFromFileAction::run(self : ReloadFromFileAction) -> Unit {
  let selection = self.view.get_selected_execution_infos()
  if selection.length() != 1 {
    return
  }

  let old_info = selection[0]
  if !execution_info_is_loaded_from_file(old_info) {
    return
  }

  let file_name = match execution_info_get_file_name(old_info) {
    Some(value) => value
    None => return
  }

  let graph = load_graph_action_load_from_file(file_name)
  let new_info = load_graph_action_layout_internal(
    file_name,
    execution_info_is_laid_out_after_load(old_info),
    graph,
  )

  match elk_debug_plugin_get_default() {
    Some(plugin) => plugin.get_model().replace_execution(old_info, new_info)
    None => ()
  }

  self.view.set_selected_execution_infos([new_info])
}
