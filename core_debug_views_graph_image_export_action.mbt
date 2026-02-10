///|
pub let image_export_action_id : String = "org.eclipse.elk.debug.actions.imageExport"

///|
let image_export_action_last_file_name_pref : String = "imageExportAction.lastImageFile"

///|
let image_export_action_exported_files_ref : Ref[Array[String]] = Ref::new([])

///|
pub struct ImageExportAction {
  view : LayoutGraphView
  mut enabled : Bool
  mut selected_file_name : String?
}

///|
pub fn new_image_export_action(view : LayoutGraphView) -> ImageExportAction {
  {
    view,
    enabled: false,
    selected_file_name: Some(
      core_debug_plugin_get_string_preference(
        image_export_action_last_file_name_pref, "",
      ),
    ),
  }
}

///|
pub fn ImageExportAction::is_enabled(self : ImageExportAction) -> Bool {
  self.enabled
}

///|
pub fn ImageExportAction::set_selected_file_name_for_test(
  self : ImageExportAction,
  file_name : String?,
) -> Unit {
  self.selected_file_name = file_name
}

///|
pub fn ImageExportAction::update_enablement(self : ImageExportAction) -> Unit {
  self.enabled = self.view.get_canvas_graph_for_test() is Some(_)
}

///|
fn image_export_action_get_file_name(input : String?) -> String? {
  let normalized = image_export_action_complete_file_name(input)
  match normalized {
    Some(path) => {
      core_debug_plugin_set_string_preference(
        image_export_action_last_file_name_pref, path,
      )
      Some(path)
    }
    None => None
  }
}

///|
pub fn image_export_action_complete_file_name(file_name : String?) -> String? {
  match file_name {
    None => None
    Some(original) => {
      let lower = original.to_lower()
      if lower.has_suffix(".png") {
        Some(original)
      } else if lower.has_suffix(".pn") {
        Some(original + "g")
      } else if lower.has_suffix(".p") {
        Some(original + "ng")
      } else if lower.has_suffix(".") {
        Some(original + "png")
      } else {
        Some(original + ".png")
      }
    }
  }
}

///|
pub fn ImageExportAction::run(self : ImageExportAction) -> Unit {
  if self.view.get_canvas_graph_for_test() is None {
    return
  }
  match image_export_action_get_file_name(self.selected_file_name) {
    Some(path) => image_export_action_exported_files_ref.val.push(path)
    None => ()
  }
}

///|
pub fn image_export_action_get_exported_files_for_test() -> Array[String] {
  image_export_action_exported_files_ref.val.copy()
}

///|
pub fn image_export_action_reset_for_test() -> Unit {
  image_export_action_exported_files_ref.val.clear()
}
