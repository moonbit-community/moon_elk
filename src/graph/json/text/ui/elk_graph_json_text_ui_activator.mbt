///|
pub struct ElkGraphJsonJsonTextUiActivator {
  base : GraphJsonTextActivator
}

///|
pub(all) suberror ElkGraphJsonTextUiActivatorException {
  IllegalArgumentException(String)
} derive(Show, ToJson)

///|
fn[T] graph_json_text_ui_activator_raise_illegal_argument(
  message : String,
) -> T raise ElkGraphJsonTextUiActivatorException {
  raise ElkGraphJsonTextUiActivatorException::IllegalArgumentException(message)
}

///|
pub fn new_elk_graph_json_json_text_ui_activator() -> ElkGraphJsonJsonTextUiActivator {
  { base: new_graph_json_text_activator() }
}

///|
pub fn ElkGraphJsonJsonTextUiActivator::get_base(
  self : ElkGraphJsonJsonTextUiActivator,
) -> GraphJsonTextActivator {
  self.base
}

///|
pub fn ElkGraphJsonJsonTextUiActivator::start(
  self : ElkGraphJsonJsonTextUiActivator,
) -> Unit {
  self.base.start()
}

///|
pub fn ElkGraphJsonJsonTextUiActivator::stop(
  self : ElkGraphJsonJsonTextUiActivator,
) -> Unit {
  self.base.stop()
}

///|
pub fn ElkGraphJsonJsonTextUiActivator::get_ide_module(
  self : ElkGraphJsonJsonTextUiActivator,
  grammar : String,
) -> @ide.ElkGraphJsonIdeModule raise ElkGraphJsonTextUiActivatorException {
  ignore(self)
  if grammar == graph_json_text_ui_language_name {
    return @ide.new_elk_graph_json_ide_module()
  }
  graph_json_text_ui_activator_raise_illegal_argument(grammar)
}

///|
pub fn ElkGraphJsonJsonTextUiActivator::create_injector(
  self : ElkGraphJsonJsonTextUiActivator,
  language : String,
) -> GraphJsonTextUiInjector raise ElkGraphJsonTextUiActivatorException {
  try {
    ignore(self.base.get_runtime_module(language))
    ignore(self.get_ide_module(language))
    ignore(self.base.get_shared_state_module())
    ignore(self.base.get_ui_module(language))
  } catch {
    GraphJsonTextActivatorException::IllegalArgumentException(message) =>
      graph_json_text_ui_activator_raise_illegal_argument(message)
    GraphJsonTextActivatorException::RuntimeException(message) =>
      graph_json_text_ui_activator_raise_illegal_argument(message)
    _ => graph_json_text_ui_activator_raise_illegal_argument(language)
  }

  let injector = new_graph_json_text_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.graph.json.text.ui.contentassist.ElkGraphJsonProposalProvider",
    () => graph_json_text_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.graph.json.text.ui.quickfix.ElkGraphJsonQuickfixProvider",
    () => graph_json_text_ui_object_named("quickfix_provider"),
  )
  injector
}
