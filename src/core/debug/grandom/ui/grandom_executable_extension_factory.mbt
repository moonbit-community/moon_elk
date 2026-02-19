///|
pub let core_debug_grandom_ui_status_error : Int = 4

///|
pub(all) struct CoreDebugGRandomUiStatus {
  severity : Int
  symbolic_name : String
  message : String
}

///|
pub fn new_core_debug_grandom_ui_status(
  severity : Int,
  symbolic_name : String,
  message : String,
) -> CoreDebugGRandomUiStatus {
  { severity, symbolic_name, message }
}

///|
pub(all) struct CoreDebugGRandomUiCoreException {
  status : CoreDebugGRandomUiStatus
}

///|
pub fn new_core_debug_grandom_ui_core_exception(
  status : CoreDebugGRandomUiStatus,
) -> CoreDebugGRandomUiCoreException {
  { status, }
}

///|
pub fn CoreDebugGRandomUiCoreException::get_status(
  self : CoreDebugGRandomUiCoreException,
) -> CoreDebugGRandomUiStatus {
  self.status
}

///|
pub(all) struct CoreDebugGRandomExecutableExtensionFactory {
  mut clazz_name : String?
  mut config : CoreDebugGRandomConfigurationElement?
}

///|
pub fn new_core_debug_grandom_executable_extension_factory() -> CoreDebugGRandomExecutableExtensionFactory {
  { clazz_name: None, config: None }
}

///|
fn core_debug_grandom_initialization_data_to_debug_string(
  data : CoreDebugGRandomInitializationData?,
) -> String {
  match data {
    Some(CoreDebugGRandomInitializationDataString(value)) => value
    Some(CoreDebugGRandomInitializationDataMap(_)) => "<map>"
    None => "null"
  }
}

///|
pub fn CoreDebugGRandomExecutableExtensionFactory::set_initialization_data(
  self : CoreDebugGRandomExecutableExtensionFactory,
  config : CoreDebugGRandomConfigurationElement?,
  _property_name : String?,
  data : CoreDebugGRandomInitializationData?,
) -> Unit {
  match data {
    Some(CoreDebugGRandomInitializationDataString(value)) =>
      self.clazz_name = Some(value)
    Some(CoreDebugGRandomInitializationDataMap(map_data)) =>
      self.clazz_name = map_data.get(
        core_debug_grandom_ui_extension_factory_guicekey,
      )
    None => ()
  }
  if self.clazz_name is None {
    abort(
      "couldn't handle passed data : " +
      core_debug_grandom_initialization_data_to_debug_string(data),
    )
  }
  self.config = config
}

///|
fn core_debug_grandom_executable_extension_factory_error(
  symbolic_name : String,
  message : String,
) -> CoreDebugGRandomUiCoreException {
  new_core_debug_grandom_ui_core_exception(
    new_core_debug_grandom_ui_status(
      core_debug_grandom_ui_status_error,
      symbolic_name,
      message + " ExtensionFactory: GRandomExecutableExtensionFactory",
    ),
  )
}

///|
pub fn CoreDebugGRandomExecutableExtensionFactory::create(
  self : CoreDebugGRandomExecutableExtensionFactory,
) -> Result[CoreDebugGRandomUiObject, CoreDebugGRandomUiCoreException] {
  let class_name = match self.clazz_name {
    Some(name) => name
    None =>
      return Err(
        core_debug_grandom_executable_extension_factory_error(
          core_debug_grandom_ui_plugin_id, "missing class name",
        ),
      )
  }
  let activator = match grandom_activator_get_instance() {
    Some(value) => value
    None =>
      return Err(
        core_debug_grandom_executable_extension_factory_error(
          core_debug_grandom_ui_plugin_id, "activator is not started",
        ),
      )
  }
  let bundle = activator.get_bundle()
  if !bundle.load_class(class_name) {
    return Err(
      core_debug_grandom_executable_extension_factory_error(
        bundle.get_symbolic_name(),
        "class not found: " + class_name,
      ),
    )
  }
  let injector = activator.get_injector(core_debug_grandom_ui_language_name)
  match injector.get_instance(class_name) {
    Some(result) => {
      match result {
        CoreDebugGRandomUiObjectExecutableExtension(extension) =>
          extension.set_initialization_data(self.config, None, None)
        _ => ()
      }
      Ok(result)
    }
    None =>
      Err(
        core_debug_grandom_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          "injector has no binding for: " + class_name,
        ),
      )
  }
}
