///|
pub struct GraphvizDotStandaloneSetup {
  marker : Unit
}

///|
pub fn new_graphviz_dot_standalone_setup() -> GraphvizDotStandaloneSetup {
  { marker: () }
}

///|
pub fn graphviz_dot_standalone_setup_do_setup() -> GraphvizDotInjector {
  new_graphviz_dot_standalone_setup().create_injector_and_do_emf_registration()
}

///|
pub fn GraphvizDotStandaloneSetup::create_injector_and_do_emf_registration(
  self : GraphvizDotStandaloneSetup,
) -> GraphvizDotInjector {
  ignore(self)
  new_graphviz_dot_standalone_setup_generated().create_injector_and_do_emf_registration()
}
