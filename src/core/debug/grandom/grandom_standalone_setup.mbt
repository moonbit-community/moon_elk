///|
pub(all) struct CoreDebugGRandomStandaloneSetup {
  unit : Unit
}

///|
pub fn new_core_debug_grandom_standalone_setup() -> CoreDebugGRandomStandaloneSetup {
  { unit: () }
}

///|
pub fn CoreDebugGRandomStandaloneSetup::create_injector_and_do_emf_registration(
  _self : CoreDebugGRandomStandaloneSetup,
) -> CoreDebugGRandomRuntimeModule {
  new_core_debug_grandom_runtime_module()
}

///|
pub fn core_debug_grandom_do_setup() -> CoreDebugGRandomRuntimeModule {
  new_core_debug_grandom_standalone_setup().create_injector_and_do_emf_registration()
}
