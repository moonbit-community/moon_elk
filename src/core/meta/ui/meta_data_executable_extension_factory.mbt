///|
pub let core_meta_ui_status_error : Int = 4

///|
priv suberror CoreMetaExecutableExtensionFactoryException {
  CoreMetaExecutableExtensionFactoryException(String)
} derive(Debug, ToJson)

///|
fn core_meta_executable_extension_factory_raise_unit(
  message : String,
) -> Unit raise CoreMetaExecutableExtensionFactoryException {
  raise CoreMetaExecutableExtensionFactoryException(message)
}

///|
pub(all) struct CoreMetaUiStatus {
  severity : Int
  symbolic_name : String
  message : String
}

///|
pub fn new_core_meta_ui_status(
  severity : Int,
  symbolic_name : String,
  message : String,
) -> CoreMetaUiStatus {
  { severity, symbolic_name, message }
}

///|
pub(all) struct CoreMetaUiCoreException {
  status : CoreMetaUiStatus
}

///|
pub fn new_core_meta_ui_core_exception(
  status : CoreMetaUiStatus,
) -> CoreMetaUiCoreException {
  { status, }
}

///|
pub fn CoreMetaUiCoreException::get_status(
  self : CoreMetaUiCoreException,
) -> CoreMetaUiStatus {
  self.status
}

///|
pub(all) struct MetaDataExecutableExtensionFactory {
  mut clazz_name : String?
  mut config : CoreMetaConfigurationElement?
}

///|
pub fn new_meta_data_executable_extension_factory() -> MetaDataExecutableExtensionFactory {
  { clazz_name: None, config: None }
}

///|
fn core_meta_ui_initialization_data_to_debug_string(
  data : CoreMetaInitializationData?,
) -> String {
  match data {
    Some(CoreMetaInitializationDataString(value)) => value
    Some(CoreMetaInitializationDataMap(_)) => "<map>"
    None => "null"
  }
}

///|
pub fn MetaDataExecutableExtensionFactory::set_initialization_data(
  self : MetaDataExecutableExtensionFactory,
  config : CoreMetaConfigurationElement?,
  _property_name : String?,
  data : CoreMetaInitializationData?,
) -> Unit {
  match data {
    Some(CoreMetaInitializationDataString(value)) =>
      self.clazz_name = Some(value)
    Some(CoreMetaInitializationDataMap(map_data)) =>
      self.clazz_name = map_data.get(core_meta_ui_extension_factory_guicekey)
    None => ()
  }
  if self.clazz_name is None {
    try
      core_meta_executable_extension_factory_raise_unit(
        "couldn't handle passed data : " +
        core_meta_ui_initialization_data_to_debug_string(data),
      )
    catch {
      err => ignore(err)
    } noraise {
      _ => ()
    }
  }
  self.config = config
}

///|
fn core_meta_ui_executable_extension_factory_error(
  symbolic_name : String,
  message : String,
) -> CoreMetaUiCoreException {
  new_core_meta_ui_core_exception(
    new_core_meta_ui_status(
      core_meta_ui_status_error,
      symbolic_name,
      message + " ExtensionFactory: MetaDataExecutableExtensionFactory",
    ),
  )
}

///|
pub fn MetaDataExecutableExtensionFactory::create(
  self : MetaDataExecutableExtensionFactory,
) -> Result[CoreMetaUiObject, CoreMetaUiCoreException] {
  let class_name = match self.clazz_name {
    Some(name) => name
    None =>
      return Err(
        core_meta_ui_executable_extension_factory_error(
          core_meta_ui_plugin_id, "missing class name",
        ),
      )
  }
  let activator = match meta_activator_get_instance() {
    Some(value) => value
    None =>
      return Err(
        core_meta_ui_executable_extension_factory_error(
          core_meta_ui_plugin_id, "activator is not started",
        ),
      )
  }
  let bundle = activator.get_bundle()
  if !bundle.load_class(class_name) {
    return Err(
      core_meta_ui_executable_extension_factory_error(
        bundle.get_symbolic_name(),
        "class not found: " + class_name,
      ),
    )
  }
  let injector = activator.get_injector(core_meta_ui_language_name)
  match injector.get_instance(class_name) {
    Some(result) => {
      match result {
        CoreMetaUiObjectExecutableExtension(extension) =>
          extension.set_initialization_data(self.config, None, None)
        _ => ()
      }
      Ok(result)
    }
    None =>
      Err(
        core_meta_ui_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          "injector has no binding for: " + class_name,
        ),
      )
  }
}
