///|
pub(all) suberror LayoutRuntimeSubError {
  UnsupportedGraph(String)
  UnsupportedConfiguration(String)
  JsonImport(String)
}

///|
/// Raise a layout failure from code that does not otherwise need session state.
/// Algorithm and provider seams catch this checked error and record it in the
/// active `LayoutSession`.
pub fn layout_runtime_raise_unsupported_graph(message : String) -> Unit raise {
  raise UnsupportedGraph(message)
}

///|
pub fn layout_runtime_raise_unsupported_configuration(
  message : String,
) -> Unit raise {
  raise UnsupportedConfiguration(message)
}

///|
pub fn layout_runtime_raise_json_import(message : String) -> Unit raise {
  raise JsonImport(message)
}

///|
fn LayoutSession::set_error_once(self : LayoutSession, error : Error) -> Unit {
  if self.error is None {
    self.error = Some(error)
  }
}

///|
pub fn LayoutSession::record_error(self : LayoutSession, error : Error) -> Unit {
  self.set_error_once(error)
}

///|
pub fn LayoutSession::clear_error(self : LayoutSession) -> Unit {
  self.error = None
}

///|
pub fn LayoutSession::has_error(self : LayoutSession) -> Bool {
  self.error is Some(_)
}

///|
pub fn LayoutSession::report_unsupported_graph(
  self : LayoutSession,
  message : String,
) -> Unit {
  self.set_error_once(UnsupportedGraph(message))
}

///|
pub fn LayoutSession::report_unsupported_configuration(
  self : LayoutSession,
  message : String,
) -> Unit {
  self.set_error_once(UnsupportedConfiguration(message))
}

///|
pub fn LayoutSession::report_json_import(
  self : LayoutSession,
  message : String,
) -> Unit {
  self.set_error_once(JsonImport(message))
}

///|
pub fn LayoutSession::take_error_message(self : LayoutSession) -> String? {
  let error = self.error
  self.error = None
  match error {
    Some(LayoutRuntimeSubError::UnsupportedGraph(message)) =>
      Some("org.eclipse.elk.core.UnsupportedGraphException: " + message)
    Some(LayoutRuntimeSubError::UnsupportedConfiguration(message)) =>
      Some("org.eclipse.elk.core.UnsupportedConfigurationException: " + message)
    Some(LayoutRuntimeSubError::JsonImport(message)) =>
      Some("org.eclipse.elk.graph.json.JsonImportException: " + message)
    Some(error) => Some(error.to_string())
    None => None
  }
}
