///|
pub let graph_text_ui_status_error : Int = 4

///|
pub struct GraphTextUiStatus {
  severity : Int
  symbolic_name : String
  message : String
}

///|
pub fn new_graph_text_ui_status(
  severity : Int,
  symbolic_name : String,
  message : String,
) -> GraphTextUiStatus {
  { severity, symbolic_name, message }
}

///|
pub struct GraphTextUiCoreException {
  status : GraphTextUiStatus
}

///|
pub fn new_graph_text_ui_core_exception(
  status : GraphTextUiStatus,
) -> GraphTextUiCoreException {
  { status, }
}

///|
pub fn GraphTextUiCoreException::get_status(
  self : GraphTextUiCoreException,
) -> GraphTextUiStatus {
  self.status
}

///|
pub suberror GraphTextExecutableExtensionFactoryException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] graph_text_executable_extension_factory_raise_illegal_argument(
  message : String,
) -> T raise GraphTextExecutableExtensionFactoryException {
  raise GraphTextExecutableExtensionFactoryException::IllegalArgumentException(
    message,
  )
}

///|
pub struct ElkGraphExecutableExtensionFactory {
  mut clazz_name : String?
  mut config : GraphTextConfigurationElement?
}

///|
pub fn new_elk_graph_executable_extension_factory() -> ElkGraphExecutableExtensionFactory {
  { clazz_name: None, config: None }
}

///|
fn graph_text_initialization_data_to_debug_string(
  data : GraphTextInitializationData?,
) -> String {
  match data {
    Some(GraphTextInitializationDataString(value)) => value
    Some(GraphTextInitializationDataMap(_)) => "<map>"
    None => "null"
  }
}

///|
pub fn ElkGraphExecutableExtensionFactory::set_initialization_data(
  self : ElkGraphExecutableExtensionFactory,
  config : GraphTextConfigurationElement?,
  _property_name : String?,
  data : GraphTextInitializationData?,
) -> Unit raise GraphTextExecutableExtensionFactoryException {
  match data {
    Some(GraphTextInitializationDataString(value)) =>
      self.clazz_name = Some(value)
    Some(GraphTextInitializationDataMap(map_data)) =>
      self.clazz_name = map_data.get(graph_text_ui_extension_factory_guicekey)
    None => ()
  }
  if self.clazz_name is None {
    graph_text_executable_extension_factory_raise_illegal_argument(
      "couldn't handle passed data : " +
      graph_text_initialization_data_to_debug_string(data),
    )
  }
  self.config = config
}

///|
fn graph_text_executable_extension_factory_error(
  symbolic_name : String,
  message : String,
) -> GraphTextUiCoreException {
  new_graph_text_ui_core_exception(
    new_graph_text_ui_status(
      graph_text_ui_status_error,
      symbolic_name,
      message + " ExtensionFactory: ElkGraphExecutableExtensionFactory",
    ),
  )
}

///|
pub fn ElkGraphExecutableExtensionFactory::create(
  self : ElkGraphExecutableExtensionFactory,
) -> Result[GraphTextUiObject, GraphTextUiCoreException] {
  let class_name = match self.clazz_name {
    Some(name) => name
    None =>
      return Err(
        graph_text_executable_extension_factory_error(
          graph_text_ui_plugin_id, "missing class name",
        ),
      )
  }
  let activator = match text_activator_get_instance() {
    Some(value) => value
    None =>
      return Err(
        graph_text_executable_extension_factory_error(
          graph_text_ui_plugin_id, "activator is not started",
        ),
      )
  }
  let bundle = activator.get_bundle()
  if !bundle.load_class(class_name) {
    return Err(
      graph_text_executable_extension_factory_error(
        bundle.get_symbolic_name(),
        "class not found: " + class_name,
      ),
    )
  }
  let injector = activator.get_injector(graph_text_ui_language_name) catch {
    GraphTextActivatorException::IllegalArgumentException(message) =>
      return Err(
        graph_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          message,
        ),
      )
    GraphTextActivatorException::RuntimeException(message) =>
      return Err(
        graph_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          message,
        ),
      )
  }
  match injector.get_instance(class_name) {
    Some(result) => {
      match result {
        GraphTextUiObjectExecutableExtension(extension) =>
          extension.set_initialization_data(self.config, None, None)
        _ => ()
      }
      Ok(result)
    }
    None =>
      Err(
        graph_text_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          "injector has no binding for: " + class_name,
        ),
      )
  }
}
