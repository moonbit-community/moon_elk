///|
pub let core_ui_pref_animation : String = "org.eclipse.elk.animation"

///|
pub let core_ui_pref_zoom : String = "org.eclipse.elk.zoomToFit"

///|
pub let core_ui_pref_progress : String = "org.eclipse.elk.progressDialog"

///|
pub let core_ui_param_layout_scope : String = "org.eclipse.elk.core.ui.layoutScope"

///|
pub let core_ui_val_diagram : String = "diagram"

///|
pub let core_ui_val_selection : String = "selection"

///|
pub enum CoreUiLayoutSelection {
  CoreUiLayoutSelectionNone
  CoreUiLayoutSelectionSingle(ServiceDiagramElement)
  CoreUiLayoutSelectionMultiple(Array[ServiceDiagramElement])
}

///|
pub struct CoreUiExecutionEvent {
  parameters : Map[String, String]
  selection : CoreUiLayoutSelection
  active_editor : ServiceWorkbenchPart?
}

///|
pub fn new_core_ui_execution_event(
  parameters? : Map[String, String] = {},
  selection? : CoreUiLayoutSelection = CoreUiLayoutSelectionNone,
  active_editor? : ServiceWorkbenchPart? = None,
) -> CoreUiExecutionEvent {
  { parameters, selection, active_editor }
}

///|
pub fn CoreUiExecutionEvent::get_parameter(
  self : CoreUiExecutionEvent,
  key : String,
) -> String? {
  self.parameters.get(key)
}

///|
pub struct CoreUiLayoutInvocation {
  editor : ServiceWorkbenchPart?
  diagram_part : ServiceDiagramElement?
  selection : CoreUiLayoutSelection
  animation : Bool
  progress_dialog : Bool
  zoom_to_fit : Bool
}

///|
pub struct LayoutHandler {
  invoke_layout_fn : (CoreUiLayoutInvocation) -> Unit
  mut last_invocation : CoreUiLayoutInvocation?
}

///|
fn layout_handler_default_invoke(invocation : CoreUiLayoutInvocation) -> Unit {
  let params = new_diagram_layout_engine_parameters()
  ignore(
    params
    .set_global_bool_setting("animate", invocation.animation)
    .set_global_bool_setting("progressBar", invocation.progress_dialog)
    .set_global_bool_setting("layoutAncestors", false)
    .set_global_bool_setting("zoomToFit", invocation.zoom_to_fit),
  )
  ignore(
    diagram_layout_engine_invoke_layout(
      invocation.editor,
      invocation.diagram_part,
      params~,
    ),
  )
}

///|
pub fn new_layout_handler(
  invoke_layout_fn? : (CoreUiLayoutInvocation) -> Unit = invocation => {
    layout_handler_default_invoke(invocation)
  },
) -> LayoutHandler {
  { invoke_layout_fn, last_invocation: None }
}

///|
fn layout_handler_selection_to_diagram_part(
  selection : CoreUiLayoutSelection,
) -> ServiceDiagramElement? {
  match selection {
    CoreUiLayoutSelectionNone => None
    CoreUiLayoutSelectionSingle(value) => Some(value)
    CoreUiLayoutSelectionMultiple(values) =>
      if values.length() == 1 {
        Some(values[0])
      } else {
        None
      }
  }
}

///|
pub fn LayoutHandler::execute(
  self : LayoutHandler,
  event : CoreUiExecutionEvent,
) -> Unit {
  let layout_scope = event.get_parameter(core_ui_param_layout_scope)
  let selection = match layout_scope {
    Some(scope) =>
      if scope == core_ui_val_selection {
        event.selection
      } else {
        CoreUiLayoutSelectionNone
      }
    None => CoreUiLayoutSelectionNone
  }

  let preference_store = elk_ui_plugin_get_instance().get_preference_store()
  let animation = preference_store.get_boolean(core_ui_pref_animation)
  let zoom_to_fit = preference_store.get_boolean(core_ui_pref_zoom)
  let progress_dialog = preference_store.get_boolean(core_ui_pref_progress)

  let invocation = {
    editor: event.active_editor,
    diagram_part: layout_handler_selection_to_diagram_part(selection),
    selection,
    animation,
    progress_dialog,
    zoom_to_fit,
  }
  self.last_invocation = Some(invocation)
  (self.invoke_layout_fn)(invocation)
}

///|
pub fn LayoutHandler::get_last_invocation(
  self : LayoutHandler,
) -> CoreUiLayoutInvocation? {
  self.last_invocation
}
