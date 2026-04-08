///|
pub let graphviz_dot_executable_extension_factory_guicekey : String = "guicekey"

///|
pub suberror GraphvizDotExecutableExtensionFactoryException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] graphviz_dot_executable_extension_factory_raise_illegal_argument(
  message : String,
) -> T raise GraphvizDotExecutableExtensionFactoryException {
  raise GraphvizDotExecutableExtensionFactoryException::IllegalArgumentException(
    message,
  )
}

///|
pub fn graphviz_dot_executable_extension_factory_exception_message(
  err : GraphvizDotExecutableExtensionFactoryException,
) -> String {
  match err {
    IllegalArgumentException(message) => message
  }
}

///|
pub struct GraphvizDotExecutableExtensionFactory {
  mut clazz_name : String?
  mut config : GraphvizDotConfigurationElement?
}

///|
pub fn new_graphviz_dot_executable_extension_factory() -> GraphvizDotExecutableExtensionFactory {
  { clazz_name: None, config: None }
}

///|
fn graphviz_dot_initialization_data_to_debug_string(
  data : GraphvizDotInitializationData?,
) -> String {
  match data {
    Some(GraphvizDotInitializationDataString(value)) => value
    Some(GraphvizDotInitializationDataMap(_)) => "<map>"
    None => "null"
  }
}

///|
pub fn GraphvizDotExecutableExtensionFactory::set_initialization_data(
  self : GraphvizDotExecutableExtensionFactory,
  config : GraphvizDotConfigurationElement?,
  _property_name : String?,
  data : GraphvizDotInitializationData?,
) -> Unit raise GraphvizDotExecutableExtensionFactoryException {
  match data {
    Some(GraphvizDotInitializationDataString(value)) =>
      self.clazz_name = Some(value)
    Some(GraphvizDotInitializationDataMap(map_data)) =>
      self.clazz_name = map_data.get(
        graphviz_dot_executable_extension_factory_guicekey,
      )
    None => ()
  }
  if self.clazz_name is None {
    graphviz_dot_executable_extension_factory_raise_illegal_argument(
      "couldn't handle passed data : " +
      graphviz_dot_initialization_data_to_debug_string(data),
    )
  }
  self.config = config
}

///|
fn graphviz_dot_executable_extension_factory_error(
  symbolic_name : String,
  message : String,
) -> GraphvizDotCoreException {
  new_graphviz_dot_core_exception(
    new_graphviz_dot_status(
      graphviz_dot_status_error,
      symbolic_name,
      message + " ExtensionFactory: GraphvizDotExecutableExtensionFactory",
    ),
  )
}

///|
pub fn GraphvizDotExecutableExtensionFactory::create(
  self : GraphvizDotExecutableExtensionFactory,
) -> Result[GraphvizDotObject, GraphvizDotCoreException] {
  let class_name = match self.clazz_name {
    Some(name) => name
    None =>
      return Err(
        graphviz_dot_executable_extension_factory_error(
          graphviz_dot_plugin_id, "missing class name",
        ),
      )
  }
  let activator = match graphviz_dot_activator_get_instance() {
    Some(value) => value
    None =>
      return Err(
        graphviz_dot_executable_extension_factory_error(
          graphviz_dot_plugin_id, "activator is not started",
        ),
      )
  }
  let bundle = activator.get_bundle()
  if !bundle.load_class(class_name) {
    return Err(
      graphviz_dot_executable_extension_factory_error(
        bundle.get_symbolic_name(),
        "class not found: " + class_name,
      ),
    )
  }
  let injector = activator.get_injector(graphviz_dot_language_name) catch {
    GraphvizDotActivatorException::IllegalArgumentException(message) =>
      return Err(
        graphviz_dot_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          message,
        ),
      )
  }
  match injector.get_instance(class_name) {
    Some(result) => {
      match result {
        GraphvizDotObjectExecutableExtension(extension) =>
          extension.set_initialization_data(self.config, None, None)
        _ => ()
      }
      Ok(result)
    }
    None =>
      Err(
        graphviz_dot_executable_extension_factory_error(
          bundle.get_symbolic_name(),
          "injector has no binding for: " + class_name,
        ),
      )
  }
}
