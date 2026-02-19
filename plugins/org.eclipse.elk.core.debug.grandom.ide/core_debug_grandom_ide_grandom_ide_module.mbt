///|
pub struct CoreDebugGRandomIdeModule {
  base : AbstractCoreDebugGRandomIdeModule
}

///|
pub fn new_core_debug_grandom_ide_module() -> CoreDebugGRandomIdeModule {
  { base: new_abstract_core_debug_grandom_ide_module() }
}

///|
pub fn CoreDebugGRandomIdeModule::get_base(
  self : CoreDebugGRandomIdeModule,
) -> AbstractCoreDebugGRandomIdeModule {
  self.base
}
