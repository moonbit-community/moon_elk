///|
pub(all) struct ActiveEditorSupportedTester {
  service : @service.LayoutConnectorsService
}

///|
pub fn new_active_editor_supported_tester(
  service : @service.LayoutConnectorsService,
) -> ActiveEditorSupportedTester {
  { service, }
}

///|
pub fn ActiveEditorSupportedTester::is_supported(
  self : ActiveEditorSupportedTester,
  receiver : @service.ServiceWorkbenchPart?,
) -> Bool {
  match receiver {
    Some(workbench_part) =>
      self.service.get_connector(Some(workbench_part), None) is Some(_)
    None => false
  }
}
