///|
pub fn core_ui_preference_initializer_initialize_default_preferences() -> Unit {
  let service_pref_store = @service.elk_service_plugin_get_instance()
  let ui_pref_store = elk_ui_plugin_get_instance().get_preference_store()

  ui_pref_store.set_default_boolean(core_ui_pref_animation, true)
  ui_pref_store.set_default_boolean(core_ui_pref_zoom, false)
  ui_pref_store.set_default_boolean(core_ui_pref_progress, false)
  ui_pref_store.set_default_boolean(core_ui_layout_view_pref_categories, true)
  ui_pref_store.set_default_boolean(core_ui_layout_view_pref_advanced, false)

  service_pref_store.set_default_boolean_preference(
    @service.diagram_layout_engine_pref_debug_store, false,
  )
  service_pref_store.set_default_boolean_preference(
    @service.diagram_layout_engine_pref_debug_logging, false,
  )
  service_pref_store.set_default_boolean_preference(
    @service.diagram_layout_engine_pref_debug_exec_time, false,
  )
}
