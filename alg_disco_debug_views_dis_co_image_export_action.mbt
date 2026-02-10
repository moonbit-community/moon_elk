///|
let dis_co_image_export_action_id : String = "org.eclipse.elk.alg.disco.debug.imageExport"

///|
let dis_co_last_image_file_name_ref : Ref[String] = Ref::new("")

///|
let dis_co_exported_image_files_ref : Ref[Array[String]] = Ref::new([])

///|
pub struct DisCoImageExportAction {
  view : DisCoDebugView
  mut selected_file_name : String?
}

///|
pub fn new_dis_co_image_export_action(
  view : DisCoDebugView,
) -> DisCoImageExportAction {
  ignore(dis_co_image_export_action_id)
  { view, selected_file_name: None }
}

///|
pub fn dis_co_image_export_action_set_selected_file_name(
  action : DisCoImageExportAction,
  file_name : String?,
) -> Unit {
  action.selected_file_name = file_name
}

///|
pub fn dis_co_image_export_action_run(action : DisCoImageExportAction) -> Unit {
  let canvas = dis_co_debug_view_get_canvas(action.view)
  let graph = dis_co_graph_rendering_canvas_get_layout_graph(canvas)
  if graph is Some(_) {
    let file_name = dis_co_image_export_action_get_file_name(
      action.selected_file_name,
    )
    if file_name is Some(valid_name) {
      dis_co_exported_image_files_ref.val.push(valid_name)
    }
  }
}

///|
fn dis_co_image_export_action_get_file_name(input : String?) -> String? {
  let file_name = dis_co_image_export_action_check_file_name(input)
  if file_name is Some(name) {
    dis_co_last_image_file_name_ref.val = name
  }
  file_name
}

///|
pub fn dis_co_image_export_action_check_file_name(
  file_name : String?,
) -> String? {
  match file_name {
    None => None
    Some(original) => {
      let name_copy = original.to_lower()
      if name_copy.has_suffix(".png") {
        Some(original)
      } else if name_copy.has_suffix(".pn") {
        Some(original + "g")
      } else if name_copy.has_suffix(".p") {
        Some(original + "ng")
      } else if name_copy.has_suffix(".") {
        Some(original + "png")
      } else {
        Some(original + ".png")
      }
    }
  }
}

///|
pub fn dis_co_image_export_action_get_last_file_name() -> String {
  dis_co_last_image_file_name_ref.val
}

///|
pub fn dis_co_image_export_action_get_exported_files() -> Array[String] {
  dis_co_exported_image_files_ref.val
}

///|
pub fn dis_co_image_export_action_reset_for_test() -> Unit {
  dis_co_last_image_file_name_ref.val = ""
  dis_co_exported_image_files_ref.val.clear()
}
