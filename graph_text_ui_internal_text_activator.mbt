///|
pub let graph_text_ui_language_name : String = "org.eclipse.elk.graph.text.ElkGraph"

///|
pub let graph_text_ui_extension_factory_guicekey : String = "guicekey"

///|
pub enum GraphTextInitializationData {
  GraphTextInitializationDataString(String)
  GraphTextInitializationDataMap(Map[String, String])
}

///|
pub fn graph_text_initialization_data_string(
  value : String,
) -> GraphTextInitializationData {
  GraphTextInitializationDataString(value)
}

///|
pub fn graph_text_initialization_data_map(
  value : Map[String, String],
) -> GraphTextInitializationData {
  GraphTextInitializationDataMap(value)
}

///|
pub struct GraphTextConfigurationElement {
  contributor : String?
}

///|
pub fn new_graph_text_configuration_element(
  contributor? : String? = None,
) -> GraphTextConfigurationElement {
  { contributor, }
}

///|
pub fn GraphTextConfigurationElement::get_contributor(
  self : GraphTextConfigurationElement,
) -> String? {
  self.contributor
}

///|
pub struct GraphTextExecutableExtension {
  set_initialization_data_fn : (
    GraphTextConfigurationElement?,
    String?,
    GraphTextInitializationData?,
  ) -> Unit
}

///|
pub fn new_graph_text_executable_extension(
  set_initialization_data_fn? : (
    GraphTextConfigurationElement?,
    String?,
    GraphTextInitializationData?,
  ) -> Unit = (_config, _property_name, _data) => (),
) -> GraphTextExecutableExtension {
  { set_initialization_data_fn, }
}

///|
pub fn GraphTextExecutableExtension::set_initialization_data(
  self : GraphTextExecutableExtension,
  config : GraphTextConfigurationElement?,
  property_name : String?,
  data : GraphTextInitializationData?,
) -> Unit {
  (self.set_initialization_data_fn)(config, property_name, data)
}

///|
pub enum GraphTextUiObject {
  GraphTextUiObjectNamed(String)
  GraphTextUiObjectExecutableExtension(GraphTextExecutableExtension)
}

///|
pub fn graph_text_ui_object_named(value : String) -> GraphTextUiObject {
  GraphTextUiObjectNamed(value)
}

///|
pub fn graph_text_ui_object_executable_extension(
  value : GraphTextExecutableExtension,
) -> GraphTextUiObject {
  GraphTextUiObjectExecutableExtension(value)
}

///|
pub fn graph_text_ui_object_tag(value : GraphTextUiObject) -> String {
  match value {
    GraphTextUiObjectNamed(_) => "named"
    GraphTextUiObjectExecutableExtension(_) => "executable_extension"
  }
}

///|
pub struct GraphTextUiBundle {
  symbolic_name : String
  classes : Map[String, Bool]
}

///|
pub fn new_graph_text_ui_bundle(
  symbolic_name? : String = graph_text_ui_plugin_id,
) -> GraphTextUiBundle {
  { symbolic_name, classes: {} }
}

///|
pub fn GraphTextUiBundle::register_class(
  self : GraphTextUiBundle,
  class_name : String,
) -> Unit {
  self.classes[class_name] = true
}

///|
pub fn GraphTextUiBundle::load_class(
  self : GraphTextUiBundle,
  class_name : String,
) -> Bool {
  match self.classes.get(class_name) {
    Some(value) => value
    None => false
  }
}

///|
pub fn GraphTextUiBundle::get_symbolic_name(self : GraphTextUiBundle) -> String {
  self.symbolic_name
}

///|
pub struct GraphTextUiInjector {
  providers : Map[String, () -> GraphTextUiObject]
}

///|
pub fn new_graph_text_ui_injector() -> GraphTextUiInjector {
  { providers: {} }
}

///|
pub fn GraphTextUiInjector::register_provider(
  self : GraphTextUiInjector,
  class_name : String,
  provider : () -> GraphTextUiObject,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn GraphTextUiInjector::get_instance(
  self : GraphTextUiInjector,
  class_name : String,
) -> GraphTextUiObject? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub fn GraphTextUiInjector::provider_count(self : GraphTextUiInjector) -> Int {
  self.providers.to_array().length()
}

///|
pub struct TextActivator {
  bundle : GraphTextUiBundle
  injectors : Map[String, GraphTextUiInjector]
}

///|
let graph_text_activator_instance_ref : Ref[TextActivator?] = Ref::new(None)

///|
pub fn new_text_activator() -> TextActivator {
  { bundle: new_graph_text_ui_bundle(), injectors: {} }
}

///|
pub fn TextActivator::start(self : TextActivator) -> Unit {
  graph_text_activator_instance_ref.val = Some(self)
}

///|
pub fn TextActivator::stop(self : TextActivator) -> Unit {
  self.injectors.clear()
  graph_text_activator_instance_ref.val = None
}

///|
pub fn text_activator_get_instance() -> TextActivator? {
  graph_text_activator_instance_ref.val
}

///|
pub fn text_activator_reset_for_test() -> Unit {
  graph_text_activator_instance_ref.val = None
}

///|
pub fn TextActivator::get_bundle(self : TextActivator) -> GraphTextUiBundle {
  self.bundle
}

///|
pub fn TextActivator::register_bundle_class(
  self : TextActivator,
  class_name : String,
) -> Unit {
  self.bundle.register_class(class_name)
}

///|
pub fn TextActivator::injector_count(self : TextActivator) -> Int {
  self.injectors.to_array().length()
}

///|
pub fn TextActivator::get_runtime_module(
  self : TextActivator,
  grammar : String,
) -> ElkGraphRuntimeModule {
  ignore(self)
  if grammar == graph_text_ui_language_name {
    return new_elk_graph_runtime_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn TextActivator::get_ui_module(
  self : TextActivator,
  grammar : String,
) -> ElkGraphUiModule {
  ignore(self)
  if grammar == graph_text_ui_language_name {
    return new_elk_graph_ui_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn TextActivator::get_shared_state_module(self : TextActivator) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.SharedStateModule"
}

///|
fn graph_text_ui_create_default_injector() -> GraphTextUiInjector {
  let injector = new_graph_text_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.graph.text.ui.contentassist.ElkGraphProposalProvider",
    () => graph_text_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.graph.text.ui.quickfix.ElkGraphQuickfixProvider",
    () => graph_text_ui_object_named("quickfix_provider"),
  )
  injector
}

///|
pub fn TextActivator::create_injector(
  self : TextActivator,
  language : String,
) -> GraphTextUiInjector {
  ignore(self.get_runtime_module(language))
  ignore(self.get_shared_state_module())
  ignore(self.get_ui_module(language))
  graph_text_ui_create_default_injector()
}

///|
pub fn TextActivator::get_injector(
  self : TextActivator,
  language : String,
) -> GraphTextUiInjector {
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
pub fn TextActivator::register_injector_provider(
  self : TextActivator,
  language_name : String,
  class_name : String,
  provider : () -> GraphTextUiObject,
) -> Unit {
  let injector = self.get_injector(language_name)
  injector.register_provider(class_name, provider)
  self.injectors[language_name] = injector
}
