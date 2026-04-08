///|
pub let graph_json_text_ui_status_error : Int = 4

///|
pub struct GraphJsonTextUiStatus {
  severity : Int
  symbolic_name : String
  message : String
}

///|
pub fn new_graph_json_text_ui_status(
  severity : Int,
  symbolic_name : String,
  message : String,
) -> GraphJsonTextUiStatus {
  { severity, symbolic_name, message }
}

///|
pub struct GraphJsonTextUiCoreException {
  status : GraphJsonTextUiStatus
}

///|
pub fn new_graph_json_text_ui_core_exception(
  status : GraphJsonTextUiStatus,
) -> GraphJsonTextUiCoreException {
  { status, }
}

///|
pub fn GraphJsonTextUiCoreException::get_status(
  self : GraphJsonTextUiCoreException,
) -> GraphJsonTextUiStatus {
  self.status
}

///|
pub suberror GraphJsonTextExecutableExtensionFactoryException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] graph_json_text_executable_extension_factory_raise_illegal_argument(
  message : String,
) -> T raise GraphJsonTextExecutableExtensionFactoryException {
  raise GraphJsonTextExecutableExtensionFactoryException::IllegalArgumentException(
    message,
  )
}

///|
pub struct ElkGraphJsonExecutableExtensionFactory {
  mut clazz_name : String?
  mut config : GraphJsonTextConfigurationElement?
}

///|
pub fn new_elk_graph_json_executable_extension_factory() -> ElkGraphJsonExecutableExtensionFactory {
  { clazz_name: None, config: None }
}

///|
fn graph_json_text_initialization_data_to_debug_string(
  data : GraphJsonTextInitializationData?,
) -> String {
  match data {
    Some(GraphJsonTextInitializationDataString(value)) => value
    Some(GraphJsonTextInitializationDataMap(_)) => "<map>"
    None => "null"
  }
}

///|
pub fn ElkGraphJsonExecutableExtensionFactory::set_initialization_data(
  self : ElkGraphJsonExecutableExtensionFactory,
  config : GraphJsonTextConfigurationElement?,
  _property_name : String?,
  data : GraphJsonTextInitializationData?,
) -> Unit raise GraphJsonTextExecutableExtensionFactoryException {
  match data {
    Some(GraphJsonTextInitializationDataString(value)) =>
      self.clazz_name = Some(value)
    Some(GraphJsonTextInitializationDataMap(map_data)) =>
      self.clazz_name = map_data.get(
        graph_json_text_ui_extension_factory_guicekey,
      )
    None => ()
  }
  if self.clazz_name is None {
    graph_json_text_executable_extension_factory_raise_illegal_argument(
      "couldn't handle passed data : " +
      graph_json_text_initialization_data_to_debug_string(data),
    )
  }
  self.config = config
}

///|
fn graph_json_text_executable_extension_factory_error(
  symbolic_name : String,
  message : String,
) -> GraphJsonTextUiCoreException {
  new_graph_json_text_ui_core_exception(
    new_graph_json_text_ui_status(
      graph_json_text_ui_status_error,
      symbolic_name,
      message + " ExtensionFactory: ElkGraphJsonExecutableExtensionFactory",
    ),
  )
}

///|
pub fn ElkGraphJsonExecutableExtensionFactory::create(
  self : ElkGraphJsonExecutableExtensionFactory,
) -> Result[GraphJsonTextUiObject, GraphJsonTextUiCoreException] {
  let class_name = match self.clazz_name {
    Some(name) => name
    None =>
      return Err(
        graph_json_text_executable_extension_factory_error(
          graph_json_text_ui_plugin_id, "missing class name",
        ),
      )
  }
  let activator = match graph_json_text_activator_get_instance() {
    Some(value) => value
    None =>
      return Err(
        graph_json_text_executable_extension_factory_error(
          graph_json_text_ui_plugin_id, "activator is not started",
        ),
      )
  }
  let bundle = activator.get_bundle()
  if !bundle.load_class(class_name) {
    return Err(
      graph_json_text_executable_extension_factory_error(
        bundle.get_symbolic_name(),
        "class not found: " + class_name,
      ),
    )
  }
  let injector = activator.get_injector(graph_json_text_ui_language_name) catch {
    GraphJsonTextActivatorException::IllegalArgumentException(message) =>
      return Err(
        graph_json_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          message,
        ),
      )
    GraphJsonTextActivatorException::RuntimeException(message) =>
      return Err(
        graph_json_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          message,
        ),
      )
  }
  match injector.get_instance(class_name) {
    Some(result) => {
      match result {
        GraphJsonTextUiObjectExecutableExtension(extension) =>
          extension.set_initialization_data(self.config, None, None)
        _ => ()
      }
      Ok(result)
    }
    None =>
      Err(
        graph_json_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          "injector has no binding for: " + class_name,
        ),
      )
  }
}
