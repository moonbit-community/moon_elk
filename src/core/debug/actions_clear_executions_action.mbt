///|
pub let clear_executions_action_id : String = "org.eclipse.elk.debug.actions.clearExecutions"

///|
pub(all) struct ClearExecutionsAction {
  mut enabled : Bool
}

///|
pub fn new_clear_executions_action() -> ClearExecutionsAction {
  { enabled: false }
}

///|
pub fn ClearExecutionsAction::is_enabled(self : ClearExecutionsAction) -> Bool {
  self.enabled
}

///|
pub fn ClearExecutionsAction::update_enablement(
  self : ClearExecutionsAction,
) -> Unit {
  self.enabled = match elk_debug_plugin_get_default() {
    Some(plugin) => !plugin.get_model().get_execution_infos().is_empty()
    None => false
  }
}

///|
pub fn ClearExecutionsAction::run(self : ClearExecutionsAction) -> Unit {
  ignore(self)
  match elk_debug_plugin_get_default() {
    Some(plugin) => plugin.get_model().remove_all_execution_infos()
    None => ()
  }
}
