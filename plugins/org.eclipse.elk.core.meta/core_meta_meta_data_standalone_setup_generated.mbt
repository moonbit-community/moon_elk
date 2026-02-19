///|
pub let core_meta_ns_uri : String = "http://www.eclipse.org/elk/MetaData"

///|
pub let core_meta_file_extension : String = "melk"

///|
pub let core_meta_epackage_value : String = "org.eclipse.elk.core.meta.metaData.MetaDataPackage"

///|
pub let core_meta_resource_factory_value : String = "org.eclipse.xtext.resource.IResourceFactory"

///|
pub let core_meta_resource_service_provider_value : String = "org.eclipse.xtext.resource.IResourceServiceProvider"

///|
let core_meta_epackage_registry_ref : Ref[Map[String, String]] = Ref::new({})

///|
let core_meta_resource_factory_registry_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
let core_meta_resource_service_provider_registry_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
pub struct MetaDataStandaloneSetupGenerated {
  marker : Unit
}

///|
pub fn new_meta_data_standalone_setup_generated() -> MetaDataStandaloneSetupGenerated {
  { marker: () }
}

///|
pub fn MetaDataStandaloneSetupGenerated::create_injector_and_do_emf_registration(
  self : MetaDataStandaloneSetupGenerated,
) -> CoreMetaInjector {
  let injector = self.create_injector()
  self.register(injector)
  injector
}

///|
pub fn MetaDataStandaloneSetupGenerated::create_injector(
  self : MetaDataStandaloneSetupGenerated,
) -> CoreMetaInjector {
  ignore(self)
  new_meta_data_runtime_module().create_injector()
}

///|
pub fn MetaDataStandaloneSetupGenerated::register(
  self : MetaDataStandaloneSetupGenerated,
  _injector : CoreMetaInjector,
) -> Unit {
  ignore(self)
  if !core_meta_epackage_registry_ref.val.contains(core_meta_ns_uri) {
    core_meta_epackage_registry_ref.val[core_meta_ns_uri] = core_meta_epackage_value
  }
  core_meta_resource_factory_registry_ref.val[core_meta_file_extension] = core_meta_resource_factory_value
  core_meta_resource_service_provider_registry_ref.val[core_meta_file_extension] = core_meta_resource_service_provider_value
}

///|
pub fn core_meta_registered_epackage(ns_uri : String) -> String? {
  core_meta_epackage_registry_ref.val.get(ns_uri)
}

///|
pub fn core_meta_registered_resource_factory(extension : String) -> String? {
  core_meta_resource_factory_registry_ref.val.get(extension)
}

///|
pub fn core_meta_registered_resource_service_provider(
  extension : String,
) -> String? {
  core_meta_resource_service_provider_registry_ref.val.get(extension)
}

///|
pub fn core_meta_reset_registries_for_test() -> Unit {
  core_meta_epackage_registry_ref.val.clear()
  core_meta_resource_factory_registry_ref.val.clear()
  core_meta_resource_service_provider_registry_ref.val.clear()
}
