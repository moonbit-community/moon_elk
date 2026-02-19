///|
pub let core_meta_ui_language_name : String = "org.eclipse.elk.core.meta.MetaData"

///|
pub let core_meta_ui_extension_factory_guicekey : String = "guicekey"

///|
pub enum CoreMetaInitializationData {
  CoreMetaInitializationDataString(String)
  CoreMetaInitializationDataMap(Map[String, String])
}

///|
pub fn core_meta_initialization_data_string(
  value : String,
) -> CoreMetaInitializationData {
  CoreMetaInitializationDataString(value)
}

///|
pub fn core_meta_initialization_data_map(
  value : Map[String, String],
) -> CoreMetaInitializationData {
  CoreMetaInitializationDataMap(value)
}

///|
pub struct CoreMetaConfigurationElement {
  contributor : String?
}

///|
pub fn new_core_meta_configuration_element(
  contributor? : String? = None,
) -> CoreMetaConfigurationElement {
  { contributor, }
}

///|
pub fn CoreMetaConfigurationElement::get_contributor(
  self : CoreMetaConfigurationElement,
) -> String? {
  self.contributor
}

///|
pub struct CoreMetaExecutableExtension {
  set_initialization_data_fn : (
    CoreMetaConfigurationElement?,
    String?,
    CoreMetaInitializationData?,
  ) -> Unit
}

///|
pub fn new_core_meta_executable_extension(
  set_initialization_data_fn? : (
    CoreMetaConfigurationElement?,
    String?,
    CoreMetaInitializationData?,
  ) -> Unit = (_config, _property_name, _data) => (),
) -> CoreMetaExecutableExtension {
  { set_initialization_data_fn, }
}

///|
pub fn CoreMetaExecutableExtension::set_initialization_data(
  self : CoreMetaExecutableExtension,
  config : CoreMetaConfigurationElement?,
  property_name : String?,
  data : CoreMetaInitializationData?,
) -> Unit {
  (self.set_initialization_data_fn)(config, property_name, data)
}

///|
pub enum CoreMetaUiObject {
  CoreMetaUiObjectNamed(String)
  CoreMetaUiObjectExecutableExtension(CoreMetaExecutableExtension)
}

///|
pub fn core_meta_ui_object_named(value : String) -> CoreMetaUiObject {
  CoreMetaUiObjectNamed(value)
}

///|
pub fn core_meta_ui_object_executable_extension(
  value : CoreMetaExecutableExtension,
) -> CoreMetaUiObject {
  CoreMetaUiObjectExecutableExtension(value)
}

///|
pub fn core_meta_ui_object_tag(value : CoreMetaUiObject) -> String {
  match value {
    CoreMetaUiObjectNamed(_) => "named"
    CoreMetaUiObjectExecutableExtension(_) => "executable_extension"
  }
}

///|
pub struct CoreMetaUiBundle {
  symbolic_name : String
  classes : Map[String, Bool]
}

///|
pub fn new_core_meta_ui_bundle(
  symbolic_name? : String = core_meta_ui_plugin_id,
) -> CoreMetaUiBundle {
  { symbolic_name, classes: {} }
}

///|
pub fn CoreMetaUiBundle::register_class(
  self : CoreMetaUiBundle,
  class_name : String,
) -> Unit {
  self.classes[class_name] = true
}

///|
pub fn CoreMetaUiBundle::load_class(
  self : CoreMetaUiBundle,
  class_name : String,
) -> Bool {
  match self.classes.get(class_name) {
    Some(value) => value
    None => false
  }
}

///|
pub fn CoreMetaUiBundle::get_symbolic_name(self : CoreMetaUiBundle) -> String {
  self.symbolic_name
}

///|
pub struct CoreMetaUiInjector {
  providers : Map[String, () -> CoreMetaUiObject]
}

///|
pub fn new_core_meta_ui_injector() -> CoreMetaUiInjector {
  { providers: {} }
}

///|
pub fn CoreMetaUiInjector::register_provider(
  self : CoreMetaUiInjector,
  class_name : String,
  provider : () -> CoreMetaUiObject,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn CoreMetaUiInjector::get_instance(
  self : CoreMetaUiInjector,
  class_name : String,
) -> CoreMetaUiObject? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub fn CoreMetaUiInjector::provider_count(self : CoreMetaUiInjector) -> Int {
  self.providers.to_array().length()
}

///|
pub struct MetaActivator {
  bundle : CoreMetaUiBundle
  injectors : Map[String, CoreMetaUiInjector]
}

///|
let core_meta_activator_instance_ref : Ref[MetaActivator?] = Ref::new(None)

///|
pub fn new_meta_activator() -> MetaActivator {
  { bundle: new_core_meta_ui_bundle(), injectors: {} }
}

///|
pub fn MetaActivator::start(self : MetaActivator) -> Unit {
  core_meta_activator_instance_ref.val = Some(self)
}

///|
pub fn MetaActivator::stop(self : MetaActivator) -> Unit {
  self.injectors.clear()
  core_meta_activator_instance_ref.val = None
}

///|
pub fn meta_activator_get_instance() -> MetaActivator? {
  core_meta_activator_instance_ref.val
}

///|
pub fn meta_activator_reset_for_test() -> Unit {
  core_meta_activator_instance_ref.val = None
}

///|
pub fn MetaActivator::get_bundle(self : MetaActivator) -> CoreMetaUiBundle {
  self.bundle
}

///|
pub fn MetaActivator::register_bundle_class(
  self : MetaActivator,
  class_name : String,
) -> Unit {
  self.bundle.register_class(class_name)
}

///|
pub fn MetaActivator::injector_count(self : MetaActivator) -> Int {
  self.injectors.to_array().length()
}

///|
pub fn MetaActivator::get_runtime_module(
  self : MetaActivator,
  grammar : String,
) -> MetaDataRuntimeModule {
  ignore(self)
  if grammar == core_meta_ui_language_name {
    return new_meta_data_runtime_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn MetaActivator::get_ui_module(
  self : MetaActivator,
  grammar : String,
) -> MetaDataUiModule {
  ignore(self)
  if grammar == core_meta_ui_language_name {
    return new_meta_data_ui_module()
  }
  abort("unknown grammar: " + grammar)
}

///|
pub fn MetaActivator::get_shared_state_module(self : MetaActivator) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.SharedStateModule"
}

///|
fn core_meta_ui_create_default_injector() -> CoreMetaUiInjector {
  let injector = new_core_meta_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.core.meta.ui.contentassist.MetaDataProposalProvider",
    () => core_meta_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.core.meta.ui.quickfix.MetaDataQuickfixProvider",
    () => core_meta_ui_object_named("quickfix_provider"),
  )
  injector
}

///|
pub fn MetaActivator::create_injector(
  self : MetaActivator,
  language : String,
) -> CoreMetaUiInjector {
  ignore(self.get_runtime_module(language))
  ignore(self.get_shared_state_module())
  ignore(self.get_ui_module(language))
  core_meta_ui_create_default_injector()
}

///|
pub fn MetaActivator::get_injector(
  self : MetaActivator,
  language : String,
) -> CoreMetaUiInjector {
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
pub fn MetaActivator::register_injector_provider(
  self : MetaActivator,
  language_name : String,
  class_name : String,
  provider : () -> CoreMetaUiObject,
) -> Unit {
  let injector = self.get_injector(language_name)
  injector.register_provider(class_name, provider)
  self.injectors[language_name] = injector
}
