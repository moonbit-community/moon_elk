///|
pub struct ElkGraphIdeInjector {
  runtime_module : ElkGraphRuntimeModule
  ide_module : ElkGraphIdeModule
}

///|
pub fn new_elk_graph_ide_injector(
  runtime_module : ElkGraphRuntimeModule,
  ide_module : ElkGraphIdeModule,
) -> ElkGraphIdeInjector {
  { runtime_module, ide_module }
}

///|
pub fn ElkGraphIdeInjector::get_runtime_module(
  self : ElkGraphIdeInjector,
) -> ElkGraphRuntimeModule {
  self.runtime_module
}

///|
pub fn ElkGraphIdeInjector::get_ide_module(
  self : ElkGraphIdeInjector,
) -> ElkGraphIdeModule {
  self.ide_module
}

///|
pub struct ElkGraphIdeSetup {
  unit : Unit
}

///|
pub fn new_elk_graph_ide_setup() -> ElkGraphIdeSetup {
  { unit: () }
}

///|
pub fn ElkGraphIdeSetup::create_injector(
  self : ElkGraphIdeSetup,
) -> ElkGraphIdeInjector {
  ignore(self)
  new_elk_graph_ide_injector(
    new_elk_graph_runtime_module(),
    new_elk_graph_ide_module(),
  )
}

///|
pub fn ElkGraphIdeSetup::create_injector_and_do_emf_registration(
  self : ElkGraphIdeSetup,
) -> ElkGraphIdeInjector {
  ignore(elk_graph_standalone_setup_do_setup())
  self.create_injector()
}
