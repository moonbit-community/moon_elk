///|
pub let layout_upon_load_setting_action_id : String = "org.eclipse.elk.debug.actions.layoutUponLoad"

///|
pub(all) struct LayoutUponLoadSettingAction {
  mut checked : Bool
}

///|
pub fn new_layout_upon_load_setting_action() -> LayoutUponLoadSettingAction {
  { checked: layout_upon_load_setting_action_should_layout_upon_load() }
}

///|
pub fn LayoutUponLoadSettingAction::is_checked(
  self : LayoutUponLoadSettingAction,
) -> Bool {
  self.checked
}

///|
pub fn LayoutUponLoadSettingAction::set_checked(
  self : LayoutUponLoadSettingAction,
  checked : Bool,
) -> Unit {
  self.checked = checked
}

///|
pub fn LayoutUponLoadSettingAction::run(
  self : LayoutUponLoadSettingAction,
) -> Unit {
  let settings = core_debug_dialog_settings_section("")
  settings.put_bool(layout_upon_load_setting_action_id, self.checked)
}

///|
pub fn layout_upon_load_setting_action_should_layout_upon_load() -> Bool {
  let settings = core_debug_dialog_settings_section("")
  match settings.get_bool(layout_upon_load_setting_action_id) {
    Some(value) => value
    None => true
  }
}
