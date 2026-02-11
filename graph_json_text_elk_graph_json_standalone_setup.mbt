///|
pub struct ElkGraphJsonStandaloneSetup {
  marker : Unit
}

///|
pub fn new_elk_graph_json_standalone_setup() -> ElkGraphJsonStandaloneSetup {
  { marker: () }
}

///|
pub fn elk_graph_json_standalone_setup_do_setup() -> GraphJsonTextInjector {
  new_elk_graph_json_standalone_setup().create_injector_and_do_emf_registration()
}

///|
pub fn ElkGraphJsonStandaloneSetup::create_injector_and_do_emf_registration(
  self : ElkGraphJsonStandaloneSetup,
) -> GraphJsonTextInjector {
  ignore(self)
  new_elk_graph_json_standalone_setup_generated().create_injector_and_do_emf_registration()
}
