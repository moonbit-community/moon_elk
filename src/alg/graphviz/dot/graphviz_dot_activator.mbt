///|
pub let graphviz_dot_language_name : String = "org.eclipse.elk.alg.graphviz.dot.GraphvizDot"

///|
pub let graphviz_dot_plugin_id : String = "org.eclipse.elk.alg.graphviz.dot"

///|
pub suberror GraphvizDotActivatorException {
  IllegalArgumentException(String)
} derive(Debug, ToJson)

///|
fn[T] graphviz_dot_activator_raise_illegal_argument(
  message : String,
) -> T raise GraphvizDotActivatorException {
  raise GraphvizDotActivatorException::IllegalArgumentException(message)
}

///|
pub fn graphviz_dot_activator_exception_message(
  err : GraphvizDotActivatorException,
) -> String {
  match err {
    IllegalArgumentException(message) => message
  }
}

///|
pub enum GraphvizDotInitializationData {
  GraphvizDotInitializationDataString(String)
  GraphvizDotInitializationDataMap(Map[String, String])
}

///|
pub fn graphviz_dot_initialization_data_string(
  value : String,
) -> GraphvizDotInitializationData {
  GraphvizDotInitializationDataString(value)
}

///|
pub fn graphviz_dot_initialization_data_map(
  value : Map[String, String],
) -> GraphvizDotInitializationData {
  GraphvizDotInitializationDataMap(value)
}

///|
pub struct GraphvizDotConfigurationElement {
  mut contributor : String?
}

///|
pub fn new_graphviz_dot_configuration_element(
  contributor? : String? = None,
) -> GraphvizDotConfigurationElement {
  { contributor, }
}

///|
pub fn GraphvizDotConfigurationElement::get_contributor(
  self : GraphvizDotConfigurationElement,
) -> String? {
  self.contributor
}

///|
pub fn GraphvizDotConfigurationElement::set_contributor(
  self : GraphvizDotConfigurationElement,
  value : String?,
) -> Unit {
  self.contributor = value
}

///|
pub struct GraphvizDotExecutableExtension {
  set_initialization_data_fn : (
    GraphvizDotConfigurationElement?,
    String?,
    GraphvizDotInitializationData?,
  ) -> Unit
}

///|
pub fn new_graphviz_dot_executable_extension(
  set_initialization_data_fn? : (
    GraphvizDotConfigurationElement?,
    String?,
    GraphvizDotInitializationData?,
  ) -> Unit = (_config, _property_name, _data) => (),
) -> GraphvizDotExecutableExtension {
  { set_initialization_data_fn, }
}

///|
pub fn GraphvizDotExecutableExtension::set_initialization_data(
  self : GraphvizDotExecutableExtension,
  config : GraphvizDotConfigurationElement?,
  property_name : String?,
  data : GraphvizDotInitializationData?,
) -> Unit {
  (self.set_initialization_data_fn)(config, property_name, data)
}

///|
pub enum GraphvizDotObject {
  GraphvizDotObjectSerializer(GraphvizDotSerializer)
  GraphvizDotObjectExecutableExtension(GraphvizDotExecutableExtension)
}

///|
pub fn graphviz_dot_object_serializer(
  value : GraphvizDotSerializer,
) -> GraphvizDotObject {
  GraphvizDotObjectSerializer(value)
}

///|
pub fn graphviz_dot_object_executable_extension(
  value : GraphvizDotExecutableExtension,
) -> GraphvizDotObject {
  GraphvizDotObjectExecutableExtension(value)
}

///|
pub fn graphviz_dot_object_tag(value : GraphvizDotObject) -> String {
  match value {
    GraphvizDotObjectSerializer(_) => "serializer"
    GraphvizDotObjectExecutableExtension(_) => "executable_extension"
  }
}

///|
pub let graphviz_dot_status_error : Int = 4

///|
pub struct GraphvizDotStatus {
  severity : Int
  symbolic_name : String
  message : String
}

///|
pub fn new_graphviz_dot_status(
  severity : Int,
  symbolic_name : String,
  message : String,
) -> GraphvizDotStatus {
  { severity, symbolic_name, message }
}

///|
pub fn GraphvizDotStatus::get_severity(self : GraphvizDotStatus) -> Int {
  self.severity
}

///|
pub fn GraphvizDotStatus::get_symbolic_name(self : GraphvizDotStatus) -> String {
  self.symbolic_name
}

///|
pub fn GraphvizDotStatus::get_message(self : GraphvizDotStatus) -> String {
  self.message
}

///|
pub struct GraphvizDotCoreException {
  status : GraphvizDotStatus
}

///|
pub fn new_graphviz_dot_core_exception(
  status : GraphvizDotStatus,
) -> GraphvizDotCoreException {
  { status, }
}

///|
pub fn GraphvizDotCoreException::get_status(
  self : GraphvizDotCoreException,
) -> GraphvizDotStatus {
  self.status
}

///|
pub struct GraphvizDotBundle {
  symbolic_name : String
  class_registry : Map[String, Bool]
}

///|
pub fn new_graphviz_dot_bundle(
  symbolic_name? : String = graphviz_dot_plugin_id,
) -> GraphvizDotBundle {
  { symbolic_name, class_registry: {} }
}

///|
pub fn GraphvizDotBundle::register_class(
  self : GraphvizDotBundle,
  class_name : String,
) -> Unit {
  self.class_registry[class_name] = true
}

///|
pub fn GraphvizDotBundle::load_class(
  self : GraphvizDotBundle,
  class_name : String,
) -> Bool {
  self.class_registry.contains(class_name)
}

///|
pub fn GraphvizDotBundle::get_symbolic_name(self : GraphvizDotBundle) -> String {
  self.symbolic_name
}

///|
pub fn GraphvizDotBundle::class_count(self : GraphvizDotBundle) -> Int {
  self.class_registry.length()
}

///|
pub struct GraphvizDotInjector {
  providers : Map[String, () -> GraphvizDotObject]
}

///|
pub fn new_graphviz_dot_injector() -> GraphvizDotInjector {
  { providers: {} }
}

///|
pub fn GraphvizDotInjector::register_provider(
  self : GraphvizDotInjector,
  class_name : String,
  provider : () -> GraphvizDotObject,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn GraphvizDotInjector::get_instance(
  self : GraphvizDotInjector,
  class_name : String,
) -> GraphvizDotObject? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub fn GraphvizDotInjector::provider_class_names(
  self : GraphvizDotInjector,
) -> Array[String] {
  let names : Array[String] = []
  for entry in self.providers.to_array() {
    names.push(entry.0)
  }
  names
}

///|
pub fn GraphvizDotInjector::provider_count(self : GraphvizDotInjector) -> Int {
  self.providers.length()
}

///|
pub struct GraphvizDotActivator {
  injectors : Map[String, GraphvizDotInjector]
  bundle : GraphvizDotBundle
}

///|
let graphviz_dot_activator_instance_ref : Ref[GraphvizDotActivator?] = Ref(None)

///|
pub fn new_graphviz_dot_activator() -> GraphvizDotActivator {
  { injectors: {}, bundle: new_graphviz_dot_bundle() }
}

///|
pub fn GraphvizDotActivator::start(self : GraphvizDotActivator) -> Unit {
  graphviz_dot_activator_instance_ref.val = Some(self)
}

///|
pub fn GraphvizDotActivator::stop(self : GraphvizDotActivator) -> Unit {
  self.injectors.clear()
  graphviz_dot_activator_instance_ref.val = None
}

///|
pub fn graphviz_dot_activator_get_instance() -> GraphvizDotActivator? {
  graphviz_dot_activator_instance_ref.val
}

///|
pub fn graphviz_dot_activator_reset_for_test() -> Unit {
  graphviz_dot_activator_instance_ref.val = None
}

///|
pub fn GraphvizDotActivator::get_bundle(
  self : GraphvizDotActivator,
) -> GraphvizDotBundle {
  self.bundle
}

///|
pub fn GraphvizDotActivator::register_bundle_class(
  self : GraphvizDotActivator,
  class_name : String,
) -> Unit {
  self.bundle.register_class(class_name)
}

///|
pub fn GraphvizDotActivator::injector_count(self : GraphvizDotActivator) -> Int {
  self.injectors.length()
}

///|
pub fn GraphvizDotActivator::get_runtime_module(
  self : GraphvizDotActivator,
  grammar : String,
) -> GraphvizDotRuntimeModule raise GraphvizDotActivatorException {
  ignore(self)
  if graphviz_dot_language_name == grammar {
    new_graphviz_dot_runtime_module()
  } else {
    graphviz_dot_activator_raise_illegal_argument(grammar)
  }
}

///|
pub fn GraphvizDotActivator::get_injector(
  self : GraphvizDotActivator,
  language_name : String,
) -> GraphvizDotInjector raise GraphvizDotActivatorException {
  match self.injectors.get(language_name) {
    Some(injector) => injector
    None => {
      let runtime_module = self.get_runtime_module(language_name)
      let injector = runtime_module.create_injector()
      for class_name in injector.provider_class_names() {
        self.bundle.register_class(class_name)
      }
      self.injectors[language_name] = injector
      injector
    }
  }
}

///|
pub fn GraphvizDotActivator::register_injector_provider(
  self : GraphvizDotActivator,
  language_name : String,
  class_name : String,
  provider : () -> GraphvizDotObject,
) -> Unit raise GraphvizDotActivatorException {
  let injector = self.get_injector(language_name)
  injector.register_provider(class_name, provider)
  self.bundle.register_class(class_name)
  self.injectors[language_name] = injector
}
