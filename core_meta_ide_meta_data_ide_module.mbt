///|
pub struct CoreMetaIdeModule {
  base : AbstractCoreMetaIdeModule
}

///|
pub fn new_core_meta_ide_module() -> CoreMetaIdeModule {
  { base: new_abstract_core_meta_ide_module() }
}

///|
pub fn CoreMetaIdeModule::get_base(
  self : CoreMetaIdeModule,
) -> AbstractCoreMetaIdeModule {
  self.base
}
