///|
pub let compress_log_folder_action_id : String = "org.eclipse.elk.debug.actions.compressLogFolder"

///|
pub struct CompressLogFolderAction {
  view : AbstractLayoutDebugView
  mut enabled : Bool
  mut selected_output_file_name : String?
}

///|
pub fn new_compress_log_folder_action(
  view : AbstractLayoutDebugView,
) -> CompressLogFolderAction {
  { view, enabled: false, selected_output_file_name: None }
}

///|
pub fn CompressLogFolderAction::is_enabled(
  self : CompressLogFolderAction,
) -> Bool {
  self.enabled
}

///|
pub fn CompressLogFolderAction::set_selected_output_file_name(
  self : CompressLogFolderAction,
  file_name : String?,
) -> Unit {
  self.selected_output_file_name = file_name
}

///|
fn compress_log_folder_action_get_selected_layout_runs_with_debug_folder(
  view : AbstractLayoutDebugView,
) -> Array[ExecutionInfo] {
  let selected_layout_runs : Array[ExecutionInfo] = []
  for info in view.get_selected_execution_infos() {
    if execution_info_get_parent(info) is None {
      let debug_folder = execution_info_get_debug_folder(info)
      if core_debug_is_directory(debug_folder) {
        selected_layout_runs.push(info)
      }
    }
  }
  selected_layout_runs
}

///|
pub fn CompressLogFolderAction::update_enablement(
  self : CompressLogFolderAction,
) -> Unit {
  self.enabled = !compress_log_folder_action_get_selected_layout_runs_with_debug_folder(
    self.view,
  ).is_empty()
}

///|
pub fn compress_log_folder_action_suggested_file_name(
  execution_infos : Array[ExecutionInfo],
) -> String {
  let names : Array[String] = []
  for info in execution_infos {
    let folder = execution_info_get_debug_folder(info)
    if !folder.is_empty() {
      names.push(core_debug_path_file_name(folder))
    }
  }
  names.join(", ") + ".zip"
}

///|
pub fn compress_log_folder_action_complete_file_name(
  file_name : String?,
) -> String? {
  match file_name {
    None => None
    Some(original) => {
      let lower = original.to_lower()
      if lower.has_suffix(".zip") {
        Some(original)
      } else if lower.has_suffix(".zi") {
        Some(original + "p")
      } else if lower.has_suffix(".z") {
        Some(original + "ip")
      } else if lower.has_suffix(".") {
        Some(original + "zip")
      } else {
        Some(original + ".zip")
      }
    }
  }
}

///|
pub fn CompressLogFolderAction::run(self : CompressLogFolderAction) -> Unit {
  let selected_infos = compress_log_folder_action_get_selected_layout_runs_with_debug_folder(
    self.view,
  )
  if selected_infos.is_empty() {
    return
  }

  let normalized_file_name = compress_log_folder_action_complete_file_name(
    self.selected_output_file_name,
  )
  match normalized_file_name {
    Some(file_name) =>
      compress_log_folder_action_do_zip(selected_infos, file_name)
    None => ()
  }
}

///|
fn compress_log_folder_action_do_zip(
  layout_runs : Array[ExecutionInfo],
  zip_file_name : String,
) -> Unit {
  let entries : Array[String] = ["/"]
  for layout_run in layout_runs {
    compress_log_folder_action_do_zip_layout_run(layout_run, entries)
  }
  core_debug_record_zip_output(zip_file_name, entries)
}

///|
fn compress_log_folder_action_do_zip_layout_run(
  layout_run : ExecutionInfo,
  entries : Array[String],
) -> Unit {
  let debug_folder = execution_info_get_debug_folder(layout_run)
  if core_debug_is_directory(debug_folder) {
    compress_log_folder_action_do_zip_folder("/", debug_folder, entries)
  }
}

///|
fn compress_log_folder_action_do_zip_folder(
  path_prefix : String,
  folder : String,
  entries : Array[String],
) -> Unit {
  let new_path_prefix = path_prefix + core_debug_path_file_name(folder) + "/"
  entries.push(new_path_prefix)

  for child in core_debug_directory_children(folder) {
    if core_debug_is_directory(child) {
      compress_log_folder_action_do_zip_folder(new_path_prefix, child, entries)
    } else if core_debug_is_regular_file(child) {
      compress_log_folder_action_do_zip_file(new_path_prefix, child, entries)
    }
  }
}

///|
fn compress_log_folder_action_do_zip_file(
  path_prefix : String,
  file : String,
  entries : Array[String],
) -> Unit {
  entries.push(path_prefix + core_debug_path_file_name(file))
}
