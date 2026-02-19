///|
pub let reveal_log_folder_action_id : String = "org.eclipse.elk.debug.actions.revealLogFolder"

///|
pub struct RevealLogFolderAction {
  view : AbstractLayoutDebugView
  mut enabled : Bool
}

///|
pub fn new_reveal_log_folder_action(
  view : AbstractLayoutDebugView,
) -> RevealLogFolderAction {
  { view, enabled: false }
}

///|
pub fn RevealLogFolderAction::is_enabled(self : RevealLogFolderAction) -> Bool {
  self.enabled
}

///|
fn reveal_log_folder_action_get_single_selected_execution_info_or_none(
  view : AbstractLayoutDebugView,
) -> ExecutionInfo? {
  let selected_infos = view.get_selected_execution_infos()
  if selected_infos.length() == 1 {
    Some(selected_infos[0])
  } else {
    None
  }
}

///|
pub fn RevealLogFolderAction::update_enablement(
  self : RevealLogFolderAction,
) -> Unit {
  match
    reveal_log_folder_action_get_single_selected_execution_info_or_none(
      self.view,
    ) {
    Some(info) => {
      let debug_folder = execution_info_get_debug_folder(info)
      self.enabled = core_debug_is_directory(debug_folder)
    }
    None => self.enabled = false
  }
}

///|
pub fn RevealLogFolderAction::run(self : RevealLogFolderAction) -> Unit {
  match
    reveal_log_folder_action_get_single_selected_execution_info_or_none(
      self.view,
    ) {
    Some(info) => {
      let debug_folder = execution_info_get_debug_folder(info)
      if core_debug_is_directory(debug_folder) {
        core_debug_launch_program(debug_folder)
      }
    }
    None => ()
  }
}
