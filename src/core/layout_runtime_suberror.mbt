///|
pub enum LayoutRuntimeSubError {
  UnsupportedGraph(String)
  UnsupportedConfiguration(String)
  JsonImport(String)
}

///|
let layout_runtime_suberror_ref : Ref[LayoutRuntimeSubError?] = Ref::new(None)

///|
fn layout_runtime_set_error_once(error : LayoutRuntimeSubError) -> Unit {
  if layout_runtime_suberror_ref.val is None {
    layout_runtime_suberror_ref.val = Some(error)
  }
}

///|
pub fn layout_runtime_clear_error() -> Unit {
  layout_runtime_suberror_ref.val = None
}

///|
pub fn layout_runtime_has_error() -> Bool {
  layout_runtime_suberror_ref.val is Some(_)
}

///|
pub fn layout_runtime_report_unsupported_graph(message : String) -> Unit {
  layout_runtime_set_error_once(
    LayoutRuntimeSubError::UnsupportedGraph(message),
  )
}

///|
pub fn layout_runtime_report_unsupported_configuration(
  message : String,
) -> Unit {
  layout_runtime_set_error_once(
    LayoutRuntimeSubError::UnsupportedConfiguration(message),
  )
}

///|
pub fn layout_runtime_report_json_import(message : String) -> Unit {
  layout_runtime_set_error_once(LayoutRuntimeSubError::JsonImport(message))
}

///|
pub fn layout_runtime_take_error_message() -> String? {
  let error = layout_runtime_suberror_ref.val
  layout_runtime_suberror_ref.val = None
  match error {
    Some(LayoutRuntimeSubError::UnsupportedGraph(message)) =>
      Some("org.eclipse.elk.core.UnsupportedGraphException: " + message)
    Some(LayoutRuntimeSubError::UnsupportedConfiguration(message)) =>
      Some("org.eclipse.elk.core.UnsupportedConfigurationException: " + message)
    Some(LayoutRuntimeSubError::JsonImport(message)) =>
      Some("org.eclipse.elk.graph.json.JsonImportException: " + message)
    None => None
  }
}
