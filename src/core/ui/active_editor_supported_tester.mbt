///|
pub(all) struct ActiveEditorSupportedTester {
  _dummy : Int
}

///|
pub fn new_active_editor_supported_tester() -> ActiveEditorSupportedTester {
  { _dummy: 0 }
}

///|
pub fn ActiveEditorSupportedTester::is_supported(
  self : ActiveEditorSupportedTester,
  receiver : @service.ServiceWorkbenchPart?,
) -> Bool {
  ignore(self)
  match receiver {
    Some(workbench_part) =>
      @service.layout_connectors_service_get_instance().get_connector(
        Some(workbench_part),
        None,
      )
      is Some(_)
    None => false
  }
}
