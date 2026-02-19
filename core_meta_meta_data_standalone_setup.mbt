///|
pub struct MetaDataStandaloneSetup {
  marker : Unit
}

///|
pub fn new_meta_data_standalone_setup() -> MetaDataStandaloneSetup {
  { marker: () }
}

///|
pub fn meta_data_standalone_setup_do_setup() -> CoreMetaInjector {
  new_meta_data_standalone_setup().create_injector_and_do_emf_registration()
}

///|
pub fn MetaDataStandaloneSetup::create_injector_and_do_emf_registration(
  self : MetaDataStandaloneSetup,
) -> CoreMetaInjector {
  ignore(self)
  new_meta_data_standalone_setup_generated().create_injector_and_do_emf_registration()
}
