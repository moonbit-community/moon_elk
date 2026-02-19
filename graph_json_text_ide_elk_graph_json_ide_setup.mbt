///|
pub struct ElkGraphJsonIdeInjector {
  runtime_module : ElkGraphJsonRuntimeModule
  ide_module : ElkGraphJsonIdeModule
}

///|
pub fn new_elk_graph_json_ide_injector(
  runtime_module : ElkGraphJsonRuntimeModule,
  ide_module : ElkGraphJsonIdeModule,
) -> ElkGraphJsonIdeInjector {
  { runtime_module, ide_module }
}

///|
pub fn ElkGraphJsonIdeInjector::get_runtime_module(
  self : ElkGraphJsonIdeInjector,
) -> ElkGraphJsonRuntimeModule {
  self.runtime_module
}

///|
pub fn ElkGraphJsonIdeInjector::get_ide_module(
  self : ElkGraphJsonIdeInjector,
) -> ElkGraphJsonIdeModule {
  self.ide_module
}

///|
pub struct ElkGraphJsonIdeSetup {
  unit : Unit
}

///|
pub fn new_elk_graph_json_ide_setup() -> ElkGraphJsonIdeSetup {
  { unit: () }
}

///|
pub fn ElkGraphJsonIdeSetup::create_injector(
  self : ElkGraphJsonIdeSetup,
) -> ElkGraphJsonIdeInjector {
  ignore(self)
  new_elk_graph_json_ide_injector(
    new_elk_graph_json_runtime_module(),
    new_elk_graph_json_ide_module(),
  )
}

///|
pub fn ElkGraphJsonIdeSetup::create_injector_and_do_emf_registration(
  self : ElkGraphJsonIdeSetup,
) -> ElkGraphJsonIdeInjector {
  ignore(elk_graph_json_standalone_setup_do_setup())
  self.create_injector()
}
