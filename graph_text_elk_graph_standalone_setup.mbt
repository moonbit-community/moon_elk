///|
pub struct ElkGraphStandaloneSetup {
  marker : Unit
}

///|
pub fn new_elk_graph_standalone_setup() -> ElkGraphStandaloneSetup {
  { marker: () }
}

///|
pub fn elk_graph_standalone_setup_do_setup() -> GraphTextInjector {
  new_elk_graph_standalone_setup().create_injector_and_do_emf_registration()
}

///|
pub fn ElkGraphStandaloneSetup::create_injector_and_do_emf_registration(
  self : ElkGraphStandaloneSetup,
) -> GraphTextInjector {
  ignore(self)
  new_elk_graph_standalone_setup_generated().create_injector_and_do_emf_registration()
}
