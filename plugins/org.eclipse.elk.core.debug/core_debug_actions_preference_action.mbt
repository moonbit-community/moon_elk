///|
pub let preference_action_id : String = "org.eclipse.elk.debug.actions.preference"

///|
pub struct PreferenceAction {
  preference_id : String
  mut checked : Bool
}

///|
pub fn new_preference_action(preference_id : String) -> PreferenceAction {
  {
    preference_id,
    checked: core_debug_service_get_boolean_preference(preference_id, false),
  }
}

///|
pub fn PreferenceAction::dispose(self : PreferenceAction) -> Unit {
  ignore(self)
}

///|
pub fn PreferenceAction::is_checked(self : PreferenceAction) -> Bool {
  self.checked
}

///|
pub fn PreferenceAction::update_checked_state(self : PreferenceAction) -> Unit {
  self.checked = core_debug_service_get_boolean_preference(
    self.preference_id,
    false,
  )
}

///|
pub fn PreferenceAction::run(self : PreferenceAction) -> Unit {
  let current = core_debug_service_get_boolean_preference(
    self.preference_id,
    false,
  )
  core_debug_service_set_boolean_preference(self.preference_id, !current)
  self.update_checked_state()
}
