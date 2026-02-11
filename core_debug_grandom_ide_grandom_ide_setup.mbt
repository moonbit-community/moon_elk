///|
pub struct CoreDebugGRandomIdeInjector {
  runtime_module : CoreDebugGRandomRuntimeModule
  ide_module : CoreDebugGRandomIdeModule
}

///|
pub fn new_core_debug_grandom_ide_injector(
  runtime_module : CoreDebugGRandomRuntimeModule,
  ide_module : CoreDebugGRandomIdeModule,
) -> CoreDebugGRandomIdeInjector {
  { runtime_module, ide_module }
}

///|
pub fn CoreDebugGRandomIdeInjector::get_runtime_module(
  self : CoreDebugGRandomIdeInjector,
) -> CoreDebugGRandomRuntimeModule {
  self.runtime_module
}

///|
pub fn CoreDebugGRandomIdeInjector::get_ide_module(
  self : CoreDebugGRandomIdeInjector,
) -> CoreDebugGRandomIdeModule {
  self.ide_module
}

///|
pub struct CoreDebugGRandomIdeSetup {
  unit : Unit
}

///|
pub fn new_core_debug_grandom_ide_setup() -> CoreDebugGRandomIdeSetup {
  { unit: () }
}

///|
pub fn CoreDebugGRandomIdeSetup::create_injector(
  self : CoreDebugGRandomIdeSetup,
) -> CoreDebugGRandomIdeInjector {
  ignore(self)
  new_core_debug_grandom_ide_injector(
    new_core_debug_grandom_runtime_module(),
    new_core_debug_grandom_ide_module(),
  )
}

///|
pub fn CoreDebugGRandomIdeSetup::create_injector_and_do_emf_registration(
  self : CoreDebugGRandomIdeSetup,
) -> CoreDebugGRandomIdeInjector {
  self.create_injector()
}
