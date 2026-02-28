///|
pub struct ElkGraphTextUiActivator {
  base : TextActivator
}

///|
pub(all) suberror ElkGraphTextUiActivatorException {
  IllegalArgumentException(String)
} derive(Show, ToJson)

///|
fn[T] graph_text_ui_activator_raise_illegal_argument(
  message : String,
) -> T raise ElkGraphTextUiActivatorException {
  raise ElkGraphTextUiActivatorException::IllegalArgumentException(message)
}

///|
pub fn new_elk_graph_text_ui_activator() -> ElkGraphTextUiActivator {
  { base: new_text_activator() }
}

///|
pub fn ElkGraphTextUiActivator::get_base(
  self : ElkGraphTextUiActivator,
) -> TextActivator {
  self.base
}

///|
pub fn ElkGraphTextUiActivator::start(self : ElkGraphTextUiActivator) -> Unit {
  self.base.start()
}

///|
pub fn ElkGraphTextUiActivator::stop(self : ElkGraphTextUiActivator) -> Unit {
  self.base.stop()
}

///|
pub fn ElkGraphTextUiActivator::get_ide_module(
  self : ElkGraphTextUiActivator,
  grammar : String,
) -> @ide.ElkGraphIdeModule raise ElkGraphTextUiActivatorException {
  ignore(self)
  if grammar == graph_text_ui_language_name {
    return @ide.new_elk_graph_ide_module()
  }
  graph_text_ui_activator_raise_illegal_argument(grammar)
}

///|
pub fn ElkGraphTextUiActivator::create_injector(
  self : ElkGraphTextUiActivator,
  language : String,
) -> GraphTextUiInjector raise ElkGraphTextUiActivatorException {
  try {
    ignore(self.base.get_runtime_module(language))
    ignore(self.get_ide_module(language))
    ignore(self.base.get_shared_state_module())
    ignore(self.base.get_ui_module(language))
  } catch {
    GraphTextActivatorException::IllegalArgumentException(message) =>
      graph_text_ui_activator_raise_illegal_argument(message)
    GraphTextActivatorException::RuntimeException(message) =>
      graph_text_ui_activator_raise_illegal_argument(message)
    _ => graph_text_ui_activator_raise_illegal_argument(language)
  }

  let injector = new_graph_text_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.graph.text.ui.contentassist.ElkGraphProposalProvider",
    () => graph_text_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.graph.text.ui.quickfix.ElkGraphQuickfixProvider",
    () => graph_text_ui_object_named("quickfix_provider"),
  )
  injector
}
