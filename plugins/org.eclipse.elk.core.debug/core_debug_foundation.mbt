///|
pub let core_debug_plugin_id : String = "org.eclipse.elk.core.debug"

///|
pub let core_debug_pref_debug_logging : String = "org.eclipse.elk.core.debug.logging"

///|
pub let core_debug_pref_debug_store : String = "org.eclipse.elk.core.debug.store"

///|
pub let core_debug_pref_debug_execution_time : String = "org.eclipse.elk.core.debug.executionTime"

///|
pub struct CoreDebugLayoutMapping {
  layout_graph : ElkNode?
}

///|
pub fn new_core_debug_layout_mapping(
  layout_graph : ElkNode?,
) -> CoreDebugLayoutMapping {
  { layout_graph, }
}

///|
pub fn core_debug_layout_mapping_get_layout_graph(
  mapping : CoreDebugLayoutMapping,
) -> ElkNode? {
  mapping.layout_graph
}

///|
pub struct CoreDebugLayoutListener {
  id : Int
  layout_about_to_start : (CoreDebugLayoutMapping, IElkProgressMonitor) -> Unit
  layout_done : (CoreDebugLayoutMapping, IElkProgressMonitor) -> Unit
}

///|
let core_debug_layout_listener_id_ref : Ref[Int] = Ref::new(0)

///|
let core_debug_layout_listeners_ref : Ref[Array[CoreDebugLayoutListener]] = Ref::new([],
)

///|
pub fn new_core_debug_layout_listener(
  layout_about_to_start : (CoreDebugLayoutMapping, IElkProgressMonitor) -> Unit,
  layout_done : (CoreDebugLayoutMapping, IElkProgressMonitor) -> Unit,
) -> CoreDebugLayoutListener {
  core_debug_layout_listener_id_ref.val = core_debug_layout_listener_id_ref.val +
    1
  {
    id: core_debug_layout_listener_id_ref.val,
    layout_about_to_start,
    layout_done,
  }
}

///|
pub fn core_debug_layout_connectors_add_layout_listener(
  listener : CoreDebugLayoutListener,
) -> Unit {
  core_debug_layout_listeners_ref.val.push(listener)
}

///|
pub fn core_debug_layout_connectors_remove_layout_listener(
  listener : CoreDebugLayoutListener,
) -> Unit {
  let kept : Array[CoreDebugLayoutListener] = []
  for existing in core_debug_layout_listeners_ref.val {
    if existing.id != listener.id {
      kept.push(existing)
    }
  }
  core_debug_layout_listeners_ref.val = kept
}

///|
pub fn core_debug_layout_connectors_fire_layout_about_to_start(
  mapping : CoreDebugLayoutMapping,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  for listener in core_debug_layout_listeners_ref.val {
    (listener.layout_about_to_start)(mapping, progress_monitor)
  }
}

///|
pub fn core_debug_layout_connectors_fire_layout_done(
  mapping : CoreDebugLayoutMapping,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  for listener in core_debug_layout_listeners_ref.val {
    (listener.layout_done)(mapping, progress_monitor)
  }
}

///|
let core_debug_service_boolean_preferences_ref : Ref[Map[String, Bool]] = Ref::new({},
)

///|
let core_debug_plugin_string_preferences_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
pub fn core_debug_service_get_boolean_preference(
  key : String,
  default_value : Bool,
) -> Bool {
  match core_debug_service_boolean_preferences_ref.val.get(key) {
    Some(value) => value
    None => default_value
  }
}

///|
pub fn core_debug_service_set_boolean_preference(
  key : String,
  value : Bool,
) -> Unit {
  core_debug_service_boolean_preferences_ref.val[key] = value
}

///|
pub fn core_debug_plugin_get_string_preference(
  key : String,
  default_value : String,
) -> String {
  match core_debug_plugin_string_preferences_ref.val.get(key) {
    Some(value) => value
    None => default_value
  }
}

///|
pub fn core_debug_plugin_set_string_preference(
  key : String,
  value : String,
) -> Unit {
  core_debug_plugin_string_preferences_ref.val[key] = value
}

///|
pub struct CoreDebugDialogSettingsSection {
  section : String
}

///|
fn core_debug_dialog_key(section : String, key : String) -> String {
  section + "|" + key
}

///|
let core_debug_dialog_bool_ref : Ref[Map[String, Bool]] = Ref::new({})

///|
let core_debug_dialog_int_ref : Ref[Map[String, Int]] = Ref::new({})

///|
let core_debug_dialog_string_ref : Ref[Map[String, String]] = Ref::new({})

///|
pub fn core_debug_dialog_settings_section(
  section : String,
) -> CoreDebugDialogSettingsSection {
  { section, }
}

///|
pub fn CoreDebugDialogSettingsSection::put_bool(
  self : CoreDebugDialogSettingsSection,
  key : String,
  value : Bool,
) -> Unit {
  core_debug_dialog_bool_ref.val[core_debug_dialog_key(self.section, key)] = value
}

///|
pub fn CoreDebugDialogSettingsSection::put_int(
  self : CoreDebugDialogSettingsSection,
  key : String,
  value : Int,
) -> Unit {
  core_debug_dialog_int_ref.val[core_debug_dialog_key(self.section, key)] = value
}

///|
pub fn CoreDebugDialogSettingsSection::put_string(
  self : CoreDebugDialogSettingsSection,
  key : String,
  value : String,
) -> Unit {
  core_debug_dialog_string_ref.val[core_debug_dialog_key(self.section, key)] = value
}

///|
pub fn CoreDebugDialogSettingsSection::get_bool(
  self : CoreDebugDialogSettingsSection,
  key : String,
) -> Bool? {
  core_debug_dialog_bool_ref.val.get(core_debug_dialog_key(self.section, key))
}

///|
pub fn CoreDebugDialogSettingsSection::get_int(
  self : CoreDebugDialogSettingsSection,
  key : String,
) -> Int? {
  core_debug_dialog_int_ref.val.get(core_debug_dialog_key(self.section, key))
}

///|
pub fn CoreDebugDialogSettingsSection::get_string(
  self : CoreDebugDialogSettingsSection,
  key : String,
) -> String? {
  core_debug_dialog_string_ref.val.get(core_debug_dialog_key(self.section, key))
}

///|
let core_debug_directory_children_ref : Ref[Map[String, Array[String]]] = Ref::new({},
)

///|
let core_debug_regular_files_ref : Ref[Map[String, Bool]] = Ref::new({})

///|
let core_debug_launched_programs_ref : Ref[Array[String]] = Ref::new([])

///|
fn core_debug_path_trim_trailing_slash(path : String) -> String {
  if path.length() > 1 && path.has_suffix("/") {
    path.unsafe_substring(start=0, end=path.length() - 1)
  } else {
    path
  }
}

///|
pub fn core_debug_path_file_name(path : String) -> String {
  let normalized = core_debug_path_trim_trailing_slash(path)
  match normalized.rev_find("/") {
    Some(index) =>
      if index + 1 < normalized.length() {
        normalized.unsafe_substring(start=index + 1, end=normalized.length())
      } else {
        ""
      }
    None => normalized
  }
}

///|
pub fn core_debug_register_directory_for_test(
  path : String,
  children : Array[String],
) -> Unit {
  core_debug_directory_children_ref.val[path] = children.copy()
}

///|
pub fn core_debug_register_regular_file_for_test(path : String) -> Unit {
  core_debug_regular_files_ref.val[path] = true
}

///|
pub fn core_debug_directory_children(path : String) -> Array[String] {
  match core_debug_directory_children_ref.val.get(path) {
    Some(children) => children.copy()
    None => []
  }
}

///|
pub fn core_debug_is_directory(path : String) -> Bool {
  core_debug_directory_children_ref.val.contains(path)
}

///|
pub fn core_debug_is_regular_file(path : String) -> Bool {
  match core_debug_regular_files_ref.val.get(path) {
    Some(value) => value
    None => false
  }
}

///|
pub fn core_debug_launch_program(path : String) -> Unit {
  core_debug_launched_programs_ref.val.push(path)
}

///|
pub fn core_debug_get_launched_programs_for_test() -> Array[String] {
  core_debug_launched_programs_ref.val.copy()
}

///|
pub struct CoreDebugZipOutput {
  file_name : String
  entries : Array[String]
}

///|
let core_debug_zip_outputs_ref : Ref[Array[CoreDebugZipOutput]] = Ref::new([])

///|
pub fn core_debug_record_zip_output(
  file_name : String,
  entries : Array[String],
) -> Unit {
  core_debug_zip_outputs_ref.val.push({ file_name, entries: entries.copy() })
}

///|
pub fn core_debug_get_zip_outputs_for_test() -> Array[CoreDebugZipOutput] {
  core_debug_zip_outputs_ref.val.copy()
}

///|
let core_debug_graph_file_contents_ref : Ref[Map[String, String]] = Ref::new({})

///|
pub fn core_debug_register_graph_file_for_test(
  path : String,
  graph : ElkNode,
) -> Unit {
  let content = elk_graph_json_for_elk_graph(graph).to_json()
  core_debug_graph_file_contents_ref.val[path] = content
}

///|
pub fn core_debug_register_graph_file_content_for_test(
  path : String,
  content : String,
) -> Unit {
  core_debug_graph_file_contents_ref.val[path] = content
}

///|
pub fn core_debug_load_graph_from_registered_file(path : String) -> ElkNode {
  match core_debug_graph_file_contents_ref.val.get(path) {
    Some(content) => elk_graph_json_for_graph(content).to_elk()
    None => abort("graph file not registered")
  }
}

///|
pub fn core_debug_reset_foundation_for_test() -> Unit {
  core_debug_layout_listener_id_ref.val = 0
  core_debug_layout_listeners_ref.val.clear()
  core_debug_service_boolean_preferences_ref.val.clear()
  core_debug_plugin_string_preferences_ref.val.clear()
  core_debug_dialog_bool_ref.val.clear()
  core_debug_dialog_int_ref.val.clear()
  core_debug_dialog_string_ref.val.clear()
  core_debug_directory_children_ref.val.clear()
  core_debug_regular_files_ref.val.clear()
  core_debug_launched_programs_ref.val.clear()
  core_debug_zip_outputs_ref.val.clear()
  core_debug_graph_file_contents_ref.val.clear()
}
