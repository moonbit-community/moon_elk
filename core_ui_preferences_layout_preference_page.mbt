///|
let core_ui_layout_preference_page_debug_folder_ref : Ref[String] = Ref::new("")

///|
let core_ui_layout_preference_page_existing_paths_ref : Ref[Map[String, Bool]] = Ref::new({},
)

///|
let core_ui_layout_preference_page_launched_paths_ref : Ref[Array[String]] = Ref::new([],
)

///|
pub fn core_ui_layout_preference_page_set_debug_folder_for_test(
  path : String,
) -> Unit {
  core_ui_layout_preference_page_debug_folder_ref.val = path
}

///|
pub fn core_ui_layout_preference_page_mark_path_exists_for_test(
  path : String,
  exists : Bool,
) -> Unit {
  core_ui_layout_preference_page_existing_paths_ref.val[path] = exists
}

///|
pub fn core_ui_layout_preference_page_get_launched_paths_for_test() -> Array[
  String,
] {
  core_ui_layout_preference_page_launched_paths_ref.val.copy()
}

///|
pub fn core_ui_layout_preference_page_reset_for_test() -> Unit {
  core_ui_layout_preference_page_debug_folder_ref.val = ""
  core_ui_layout_preference_page_existing_paths_ref.val.clear()
  core_ui_layout_preference_page_launched_paths_ref.val.clear()
}

///|
fn core_ui_layout_preference_page_is_directory(path : String) -> Bool {
  match core_ui_layout_preference_page_existing_paths_ref.val.get(path) {
    Some(value) => value
    None => false
  }
}

///|
fn core_ui_layout_preference_page_launch(path : String) -> Unit {
  core_ui_layout_preference_page_launched_paths_ref.val.push(path)
}

///|
pub struct LayoutPreferencePage {
  mut preference_store : CoreUiPreferenceStore?
  mut animation : Bool
  mut zoom : Bool
  mut progress : Bool
  mut enable_logging : Bool
  mut store_logs : Bool
  mut exec_time : Bool
}

///|
pub fn new_layout_preference_page() -> LayoutPreferencePage {
  {
    preference_store: None,
    animation: false,
    zoom: false,
    progress: false,
    enable_logging: false,
    store_logs: false,
    exec_time: false,
  }
}

///|
pub fn LayoutPreferencePage::init(self : LayoutPreferencePage) -> Unit {
  self.preference_store = Some(
    elk_ui_plugin_get_instance().get_preference_store(),
  )
}

///|
pub fn LayoutPreferencePage::create_contents(
  self : LayoutPreferencePage,
) -> Unit {
  let main_pref_store = match self.preference_store {
    Some(store) => store
    None => elk_ui_plugin_get_instance().get_preference_store()
  }
  let service_pref_store = elk_service_plugin_get_instance()

  self.animation = main_pref_store.get_boolean(core_ui_pref_animation)
  self.zoom = main_pref_store.get_boolean(core_ui_pref_zoom)
  self.progress = main_pref_store.get_boolean(core_ui_pref_progress)
  self.exec_time = service_pref_store.get_boolean_preference(
    diagram_layout_engine_pref_debug_exec_time, false,
  )
  self.enable_logging = service_pref_store.get_boolean_preference(
    diagram_layout_engine_pref_debug_logging, false,
  )
  self.store_logs = service_pref_store.get_boolean_preference(
    diagram_layout_engine_pref_debug_store, false,
  )
}

///|
pub fn LayoutPreferencePage::perform_defaults(
  self : LayoutPreferencePage,
) -> Unit {
  let main_pref_store = match self.preference_store {
    Some(store) => store
    None => elk_ui_plugin_get_instance().get_preference_store()
  }
  let service_pref_store = elk_service_plugin_get_instance()
  self.animation = main_pref_store.get_default_boolean(core_ui_pref_animation)
  self.zoom = main_pref_store.get_default_boolean(core_ui_pref_zoom)
  self.progress = main_pref_store.get_default_boolean(core_ui_pref_progress)
  self.exec_time = service_pref_store.get_default_boolean_preference(
    diagram_layout_engine_pref_debug_exec_time,
  )
  self.enable_logging = service_pref_store.get_default_boolean_preference(
    diagram_layout_engine_pref_debug_logging,
  )
  self.store_logs = service_pref_store.get_default_boolean_preference(
    diagram_layout_engine_pref_debug_store,
  )
}

///|
pub fn LayoutPreferencePage::perform_ok(self : LayoutPreferencePage) -> Bool {
  let main_pref_store = match self.preference_store {
    Some(store) => store
    None => elk_ui_plugin_get_instance().get_preference_store()
  }
  let service_pref_store = elk_service_plugin_get_instance()

  main_pref_store.set_boolean(core_ui_pref_animation, self.animation)
  main_pref_store.set_boolean(core_ui_pref_zoom, self.zoom)
  main_pref_store.set_boolean(core_ui_pref_progress, self.progress)
  service_pref_store.set_boolean_preference(
    diagram_layout_engine_pref_debug_exec_time,
    self.exec_time,
  )
  service_pref_store.set_boolean_preference(
    diagram_layout_engine_pref_debug_logging,
    self.enable_logging,
  )
  service_pref_store.set_boolean_preference(
    diagram_layout_engine_pref_debug_store,
    self.store_logs,
  )

  match layout_view_part_find_view() {
    Some(layout_view) => layout_view.refresh()
    None => ()
  }
  true
}

///|
pub fn LayoutPreferencePage::open_log_folder(
  self : LayoutPreferencePage,
) -> Unit {
  ignore(self)
  let debug_path = core_ui_layout_preference_page_debug_folder_ref.val
  if core_ui_layout_preference_page_is_directory(debug_path) {
    core_ui_layout_preference_page_launch(debug_path)
  }
}

///|
pub fn LayoutPreferencePage::set_animation(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.animation = value
}

///|
pub fn LayoutPreferencePage::set_zoom(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.zoom = value
}

///|
pub fn LayoutPreferencePage::set_progress(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.progress = value
}

///|
pub fn LayoutPreferencePage::set_enable_logging(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.enable_logging = value
}

///|
pub fn LayoutPreferencePage::set_store_logs(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.store_logs = value
}

///|
pub fn LayoutPreferencePage::set_exec_time(
  self : LayoutPreferencePage,
  value : Bool,
) -> Unit {
  self.exec_time = value
}

///|
pub fn LayoutPreferencePage::get_values(
  self : LayoutPreferencePage,
) -> (Bool, Bool, Bool, Bool, Bool, Bool) {
  (
    self.animation,
    self.zoom,
    self.progress,
    self.exec_time,
    self.enable_logging,
    self.store_logs,
  )
}

///|
pub fn LayoutPreferencePage::get_preference_store(
  self : LayoutPreferencePage,
) -> CoreUiPreferenceStore? {
  self.preference_store
}
