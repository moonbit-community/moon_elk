///|
pub let clear_execution_action_id : String = "org.eclipse.elk.debug.actions.clearExecution"

///|
pub(all) struct ClearExecutionAction {
  view : AbstractLayoutDebugView
  mut enabled : Bool
}

///|
pub fn new_clear_execution_action(
  view : AbstractLayoutDebugView,
) -> ClearExecutionAction {
  { view, enabled: false }
}

///|
pub fn ClearExecutionAction::is_enabled(self : ClearExecutionAction) -> Bool {
  self.enabled
}

///|
pub fn ClearExecutionAction::update_enablement(
  self : ClearExecutionAction,
) -> Unit {
  self.enabled = !self.view.get_selected_execution_infos().is_empty()
}

///|
pub fn ClearExecutionAction::run(self : ClearExecutionAction) -> Unit {
  let selected_infos = self.view.get_selected_execution_infos()
  match elk_debug_plugin_get_default() {
    Some(plugin) => plugin.get_model().remove_execution_infos(selected_infos)
    None => ()
  }
}
