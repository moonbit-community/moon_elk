///|
pub let graph_json_text_ui_language_name : String = "org.eclipse.elk.graph.json.text.ElkGraphJson"

///|
pub let graph_json_text_ui_extension_factory_guicekey : String = "guicekey"

///|
pub let graph_json_text_extension_factory_guicekey : String = graph_json_text_ui_extension_factory_guicekey

///|
pub enum GraphJsonTextInitializationData {
  GraphJsonTextInitializationDataString(String)
  GraphJsonTextInitializationDataMap(Map[String, String])
}

///|
pub fn graph_json_text_initialization_data_string(
  value : String,
) -> GraphJsonTextInitializationData {
  GraphJsonTextInitializationDataString(value)
}

///|
pub fn graph_json_text_initialization_data_map(
  value : Map[String, String],
) -> GraphJsonTextInitializationData {
  GraphJsonTextInitializationDataMap(value)
}

///|
pub struct GraphJsonTextConfigurationElement {
  contributor : String?
}

///|
pub fn new_graph_json_text_configuration_element(
  contributor? : String? = None,
) -> GraphJsonTextConfigurationElement {
  { contributor, }
}

///|
pub fn GraphJsonTextConfigurationElement::get_contributor(
  self : GraphJsonTextConfigurationElement,
) -> String? {
  self.contributor
}

///|
pub struct GraphJsonTextExecutableExtension {
  set_initialization_data_fn : (
    GraphJsonTextConfigurationElement?,
    String?,
    GraphJsonTextInitializationData?,
  ) -> Unit
}

///|
pub fn new_graph_json_text_executable_extension(
  set_initialization_data_fn? : (
    GraphJsonTextConfigurationElement?,
    String?,
    GraphJsonTextInitializationData?,
  ) -> Unit = (_config, _property_name, _data) => (),
) -> GraphJsonTextExecutableExtension {
  { set_initialization_data_fn, }
}

///|
pub fn GraphJsonTextExecutableExtension::set_initialization_data(
  self : GraphJsonTextExecutableExtension,
  config : GraphJsonTextConfigurationElement?,
  property_name : String?,
  data : GraphJsonTextInitializationData?,
) -> Unit {
  (self.set_initialization_data_fn)(config, property_name, data)
}

///|
pub enum GraphJsonTextUiObject {
  GraphJsonTextUiObjectNamed(String)
  GraphJsonTextUiObjectExecutableExtension(GraphJsonTextExecutableExtension)
}

///|
pub fn graph_json_text_ui_object_named(value : String) -> GraphJsonTextUiObject {
  GraphJsonTextUiObjectNamed(value)
}

///|
pub fn graph_json_text_ui_object_executable_extension(
  value : GraphJsonTextExecutableExtension,
) -> GraphJsonTextUiObject {
  GraphJsonTextUiObjectExecutableExtension(value)
}

///|
pub fn graph_json_text_ui_object_tag(value : GraphJsonTextUiObject) -> String {
  match value {
    GraphJsonTextUiObjectNamed(_) => "named"
    GraphJsonTextUiObjectExecutableExtension(_) => "executable_extension"
  }
}

///|
pub struct GraphJsonTextUiBundle {
  symbolic_name : String
  classes : Map[String, Bool]
}

///|
pub fn new_graph_json_text_ui_bundle(
  symbolic_name? : String = graph_json_text_ui_plugin_id,
) -> GraphJsonTextUiBundle {
  { symbolic_name, classes: {} }
}

///|
pub fn GraphJsonTextUiBundle::register_class(
  self : GraphJsonTextUiBundle,
  class_name : String,
) -> Unit {
  self.classes[class_name] = true
}

///|
pub fn GraphJsonTextUiBundle::load_class(
  self : GraphJsonTextUiBundle,
  class_name : String,
) -> Bool {
  match self.classes.get(class_name) {
    Some(value) => value
    None => false
  }
}

///|
pub fn GraphJsonTextUiBundle::get_symbolic_name(
  self : GraphJsonTextUiBundle,
) -> String {
  self.symbolic_name
}

///|
pub struct GraphJsonTextUiInjector {
  providers : Map[String, () -> GraphJsonTextUiObject]
}

///|
pub fn new_graph_json_text_ui_injector() -> GraphJsonTextUiInjector {
  { providers: {} }
}

///|
pub fn GraphJsonTextUiInjector::register_provider(
  self : GraphJsonTextUiInjector,
  class_name : String,
  provider : () -> GraphJsonTextUiObject,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn GraphJsonTextUiInjector::get_instance(
  self : GraphJsonTextUiInjector,
  class_name : String,
) -> GraphJsonTextUiObject? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub fn GraphJsonTextUiInjector::provider_count(
  self : GraphJsonTextUiInjector,
) -> Int {
  self.providers.to_array().length()
}

///|
pub struct GraphJsonTextActivator {
  bundle : GraphJsonTextUiBundle
  injectors : Map[String, GraphJsonTextUiInjector]
}

///|
let graph_json_text_activator_instance_ref : Ref[GraphJsonTextActivator?] = Ref::new(
  None,
)

///|
pub fn new_graph_json_text_activator() -> GraphJsonTextActivator {
  { bundle: new_graph_json_text_ui_bundle(), injectors: {} }
}

///|
pub fn GraphJsonTextActivator::start(self : GraphJsonTextActivator) -> Unit {
  graph_json_text_activator_instance_ref.val = Some(self)
}

///|
pub fn GraphJsonTextActivator::stop(self : GraphJsonTextActivator) -> Unit {
  self.injectors.clear()
  graph_json_text_activator_instance_ref.val = None
}

///|
pub fn graph_json_text_activator_get_instance() -> GraphJsonTextActivator? {
  graph_json_text_activator_instance_ref.val
}

///|
pub fn graph_json_text_activator_reset_for_test() -> Unit {
  graph_json_text_activator_instance_ref.val = None
}

///|
pub fn GraphJsonTextActivator::get_bundle(
  self : GraphJsonTextActivator,
) -> GraphJsonTextUiBundle {
  self.bundle
}

///|
pub fn GraphJsonTextActivator::register_bundle_class(
  self : GraphJsonTextActivator,
  class_name : String,
) -> Unit {
  self.bundle.register_class(class_name)
}

///|
pub fn GraphJsonTextActivator::injector_count(
  self : GraphJsonTextActivator,
) -> Int {
  self.injectors.to_array().length()
}

///|
pub fn GraphJsonTextActivator::get_runtime_module(
  self : GraphJsonTextActivator,
  grammar : String,
) -> ElkGraphJsonRuntimeModule {
  ignore(self)
  if grammar == graph_json_text_ui_language_name {
    return new_elk_graph_json_runtime_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn GraphJsonTextActivator::get_ui_module(
  self : GraphJsonTextActivator,
  grammar : String,
) -> ElkGraphJsonUiModule {
  ignore(self)
  if grammar == graph_json_text_ui_language_name {
    return new_elk_graph_json_ui_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn GraphJsonTextActivator::get_shared_state_module(
  self : GraphJsonTextActivator,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.SharedStateModule"
}

///|
fn graph_json_text_ui_create_default_injector() -> GraphJsonTextUiInjector {
  let injector = new_graph_json_text_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.graph.json.text.ui.contentassist.ElkGraphJsonProposalProvider",
    () => graph_json_text_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.graph.json.text.ui.quickfix.ElkGraphJsonQuickfixProvider",
    () => graph_json_text_ui_object_named("quickfix_provider"),
  )
  injector
}

///|
pub fn GraphJsonTextActivator::create_injector(
  self : GraphJsonTextActivator,
  language : String,
) -> GraphJsonTextUiInjector {
  ignore(self.get_runtime_module(language))
  ignore(self.get_shared_state_module())
  ignore(self.get_ui_module(language))
  graph_json_text_ui_create_default_injector()
}

///|
pub fn GraphJsonTextActivator::get_injector(
  self : GraphJsonTextActivator,
  language : String,
) -> GraphJsonTextUiInjector {
  match self.injectors.get(language) {
    Some(injector) => injector
    None => {
      let injector = self.create_injector(language)
      self.injectors[language] = injector
      injector
    }
  }
}

///|
pub fn GraphJsonTextActivator::register_injector_provider(
  self : GraphJsonTextActivator,
  language_name : String,
  class_name : String,
  provider : () -> GraphJsonTextUiObject,
) -> Unit {
  let injector = self.get_injector(language_name)
  injector.register_provider(class_name, provider)
  self.injectors[language_name] = injector
}
