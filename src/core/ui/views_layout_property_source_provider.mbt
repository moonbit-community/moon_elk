///|
pub(all) struct LayoutPropertySourceProvider {
  mut configuration_store_provider : @service.LayoutConfigurationStoreProvider?
  config_manager : @service.LayoutConfigurationManager
  layout_option_validator_provider : () -> @core.LayoutOptionValidator
  mut workbench_part : @service.ServiceWorkbenchPart?
  config_stores : Array[@service.ILayoutConfigurationStore]
}

///|
pub fn new_layout_property_source_provider(
  configuration_store_provider? : @service.LayoutConfigurationStoreProvider? = None,
  config_manager? : @service.LayoutConfigurationManager = @service.new_layout_configuration_manager(),
  layout_option_validator_provider? : () -> @core.LayoutOptionValidator = () => {
    @core.new_layout_option_validator()
  },
) -> LayoutPropertySourceProvider {
  {
    configuration_store_provider,
    config_manager,
    layout_option_validator_provider,
    workbench_part: None,
    config_stores: [],
  }
}

///|
pub fn LayoutPropertySourceProvider::set_configuration_store_provider(
  self : LayoutPropertySourceProvider,
  provider : @service.LayoutConfigurationStoreProvider?,
) -> Unit {
  self.configuration_store_provider = provider
}

///|
pub fn LayoutPropertySourceProvider::get_workbench_part(
  self : LayoutPropertySourceProvider,
) -> @service.ServiceWorkbenchPart? {
  self.workbench_part
}

///|
pub fn LayoutPropertySourceProvider::set_workbench_part(
  self : LayoutPropertySourceProvider,
  workbench_part : @service.ServiceWorkbenchPart?,
) -> Unit {
  self.workbench_part = workbench_part
}

///|
pub fn LayoutPropertySourceProvider::get_configuration_stores(
  self : LayoutPropertySourceProvider,
) -> Array[@service.ILayoutConfigurationStore] {
  self.config_stores
}

///|
pub fn LayoutPropertySourceProvider::get_configuration_manager(
  self : LayoutPropertySourceProvider,
) -> @service.LayoutConfigurationManager {
  self.config_manager
}

///|
pub fn LayoutPropertySourceProvider::create_property_source(
  self : LayoutPropertySourceProvider,
  config : @service.ILayoutConfigurationStore,
) -> LayoutPropertySource {
  let result = new_layout_property_source(
    config,
    self.get_configuration_manager(),
  )
  result.set_validator((self.layout_option_validator_provider)())
  result
}

///|
pub fn LayoutPropertySourceProvider::get_property_source(
  self : LayoutPropertySourceProvider,
  object : @service.ServiceDiagramElement?,
) -> LayoutPropertySource? {
  match self.configuration_store_provider {
    Some(provider) =>
      match provider.get(self.workbench_part, object) {
        Some(config) => {
          self.config_stores.push(config)
          Some(self.create_property_source(config))
        }
        None => None
      }
    None => None
  }
}
