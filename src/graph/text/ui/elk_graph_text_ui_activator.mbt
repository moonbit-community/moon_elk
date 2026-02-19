///|
pub struct ElkGraphTextUiActivator {
  base : TextActivator
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
) -> @ide.ElkGraphIdeModule {
  ignore(self)
  if grammar == graph_text_ui_language_name {
    return @ide.new_elk_graph_ide_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn ElkGraphTextUiActivator::create_injector(
  self : ElkGraphTextUiActivator,
  language : String,
) -> GraphTextUiInjector {
  ignore(self.base.get_runtime_module(language))
  ignore(self.get_ide_module(language))
  ignore(self.base.get_shared_state_module())
  ignore(self.base.get_ui_module(language))

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
