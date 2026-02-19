///|
pub struct MetaDataUiModule {
  plugin_id : String
  base : AbstractMetaDataUiModule
}

///|
pub fn new_meta_data_ui_module(
  plugin_id? : String = core_meta_ui_plugin_id,
) -> MetaDataUiModule {
  { plugin_id, base: new_abstract_meta_data_ui_module(plugin_id~) }
}

///|
pub fn MetaDataUiModule::get_base(
  self : MetaDataUiModule,
) -> AbstractMetaDataUiModule {
  self.base
}

///|
pub fn MetaDataUiModule::bind_unique_class_name_validator(
  self : MetaDataUiModule,
) -> String {
  ignore(self)
  core_meta_unique_class_name_validator_class_name
}
