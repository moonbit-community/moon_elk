///|
pub(all) struct CoreMetaIdeInjector {
  runtime_module : @meta.MetaDataRuntimeModule
  ide_module : CoreMetaIdeModule
}

///|
pub fn new_core_meta_ide_injector(
  runtime_module : @meta.MetaDataRuntimeModule,
  ide_module : CoreMetaIdeModule,
) -> CoreMetaIdeInjector {
  { runtime_module, ide_module }
}

///|
pub fn CoreMetaIdeInjector::get_runtime_module(
  self : CoreMetaIdeInjector,
) -> @meta.MetaDataRuntimeModule {
  self.runtime_module
}

///|
pub fn CoreMetaIdeInjector::get_ide_module(
  self : CoreMetaIdeInjector,
) -> CoreMetaIdeModule {
  self.ide_module
}

///|
pub(all) struct CoreMetaIdeSetup {
  unit : Unit
}

///|
pub fn new_core_meta_ide_setup() -> CoreMetaIdeSetup {
  { unit: () }
}

///|
pub fn CoreMetaIdeSetup::create_injector(
  self : CoreMetaIdeSetup,
) -> CoreMetaIdeInjector {
  ignore(self)
  new_core_meta_ide_injector(
    @meta.new_meta_data_runtime_module(),
    new_core_meta_ide_module(),
  )
}

///|
pub fn CoreMetaIdeSetup::create_injector_and_do_emf_registration(
  self : CoreMetaIdeSetup,
) -> CoreMetaIdeInjector {
  ignore(@meta.meta_data_standalone_setup_do_setup())
  self.create_injector()
}
