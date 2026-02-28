///|
pub let core_meta_generator_class_name : String = "org.eclipse.elk.core.meta.jvmmodel.MelkDocumentationGenerator"

///|
pub let core_meta_unique_class_name_validator_class_name : String = "org.eclipse.elk.core.meta.validation.MelkUniqueClassNameValidator"

///|
pub let core_meta_output_configuration_ad_input : String = "AD_INPUT"

///|
pub(all) struct CoreMetaOutputConfiguration {
  id : String
  description : String
  output_directory : String
}

///|
pub fn new_core_meta_output_configuration(
  id : String,
  description : String,
  output_directory : String,
) -> CoreMetaOutputConfiguration {
  { id, description, output_directory }
}

///|
pub(all) struct CoreMetaInjector {
  runtime_module : MetaDataRuntimeModule
}

///|
pub fn new_core_meta_injector(
  runtime_module : MetaDataRuntimeModule,
) -> CoreMetaInjector {
  { runtime_module, }
}

///|
pub fn CoreMetaInjector::get_runtime_module(
  self : CoreMetaInjector,
) -> MetaDataRuntimeModule {
  self.runtime_module
}

///|
pub(all) struct MetaDataRuntimeModule {
  base : AbstractMetaDataRuntimeModule
}

///|
pub fn new_meta_data_runtime_module(
  base? : AbstractMetaDataRuntimeModule = new_abstract_meta_data_runtime_module(),
) -> MetaDataRuntimeModule {
  { base, }
}

///|
pub fn MetaDataRuntimeModule::get_base(
  self : MetaDataRuntimeModule,
) -> AbstractMetaDataRuntimeModule {
  self.base
}

///|
pub fn MetaDataRuntimeModule::configure(
  self : MetaDataRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.base.configure(properties)
}

///|
pub fn MetaDataRuntimeModule::bind_igenerator(
  self : MetaDataRuntimeModule,
) -> String {
  ignore(self)
  core_meta_generator_class_name
}

///|
pub fn MetaDataRuntimeModule::bind_unique_class_name_validator(
  self : MetaDataRuntimeModule,
) -> String {
  ignore(self)
  core_meta_unique_class_name_validator_class_name
}

///|
pub fn MetaDataRuntimeModule::get_output_configurations(
  self : MetaDataRuntimeModule,
) -> Array[CoreMetaOutputConfiguration] {
  ignore(self)
  [
    new_core_meta_output_configuration(
      "DEFAULT_OUTPUT", "Default generated output folder", "src-gen",
    ),
    new_core_meta_output_configuration(
      core_meta_output_configuration_ad_input, "Additional Documentation Input Folder",
      "./",
    ),
  ]
}

///|
pub fn MetaDataRuntimeModule::create_injector(
  self : MetaDataRuntimeModule,
) -> CoreMetaInjector {
  new_core_meta_injector(self)
}
