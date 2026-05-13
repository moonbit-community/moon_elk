///|
pub let core_debug_grandom_ui_language_name : String = "org.eclipse.elk.core.debug.grandom.GRandom"

///|
pub let core_debug_grandom_ui_extension_factory_guicekey : String = "guicekey"

///|
priv suberror CoreDebugGrandomUiException {
  CoreDebugGrandomUiException(String)
} derive(Debug, ToJson)

///|
fn core_debug_grandom_ui_raise_unit(
  message : String,
) -> Unit raise CoreDebugGrandomUiException {
  raise CoreDebugGrandomUiException(message)
}

///|
pub(all) enum CoreDebugGRandomInitializationData {
  CoreDebugGRandomInitializationDataString(String)
  CoreDebugGRandomInitializationDataMap(Map[String, String])
}

///|
pub fn core_debug_grandom_initialization_data_string(
  value : String,
) -> CoreDebugGRandomInitializationData {
  CoreDebugGRandomInitializationDataString(value)
}

///|
pub fn core_debug_grandom_initialization_data_map(
  value : Map[String, String],
) -> CoreDebugGRandomInitializationData {
  CoreDebugGRandomInitializationDataMap(value)
}

///|
pub(all) struct CoreDebugGRandomConfigurationElement {
  contributor : String?
}

///|
pub fn new_core_debug_grandom_configuration_element(
  contributor? : String? = None,
) -> CoreDebugGRandomConfigurationElement {
  { contributor, }
}

///|
pub fn CoreDebugGRandomConfigurationElement::get_contributor(
  self : CoreDebugGRandomConfigurationElement,
) -> String? {
  self.contributor
}

///|
pub(all) struct CoreDebugGRandomExecutableExtension {
  set_initialization_data_fn : (
    CoreDebugGRandomConfigurationElement?,
    String?,
    CoreDebugGRandomInitializationData?,
  ) -> Unit
}

///|
pub fn new_core_debug_grandom_executable_extension(
  set_initialization_data_fn? : (
    CoreDebugGRandomConfigurationElement?,
    String?,
    CoreDebugGRandomInitializationData?,
  ) -> Unit = (_config, _property_name, _data) => (),
) -> CoreDebugGRandomExecutableExtension {
  { set_initialization_data_fn, }
}

///|
pub fn CoreDebugGRandomExecutableExtension::set_initialization_data(
  self : CoreDebugGRandomExecutableExtension,
  config : CoreDebugGRandomConfigurationElement?,
  property_name : String?,
  data : CoreDebugGRandomInitializationData?,
) -> Unit {
  (self.set_initialization_data_fn)(config, property_name, data)
}

///|
pub(all) enum CoreDebugGRandomUiObject {
  CoreDebugGRandomUiObjectNamed(String)
  CoreDebugGRandomUiObjectExecutableExtension(
    CoreDebugGRandomExecutableExtension
  )
}

///|
pub fn core_debug_grandom_ui_object_named(
  value : String,
) -> CoreDebugGRandomUiObject {
  CoreDebugGRandomUiObjectNamed(value)
}

///|
pub fn core_debug_grandom_ui_object_executable_extension(
  value : CoreDebugGRandomExecutableExtension,
) -> CoreDebugGRandomUiObject {
  CoreDebugGRandomUiObjectExecutableExtension(value)
}

///|
pub fn core_debug_grandom_ui_object_tag(
  value : CoreDebugGRandomUiObject,
) -> String {
  match value {
    CoreDebugGRandomUiObjectNamed(_) => "named"
    CoreDebugGRandomUiObjectExecutableExtension(_) => "executable_extension"
  }
}

///|
pub(all) struct CoreDebugGRandomUiBundle {
  symbolic_name : String
  classes : Map[String, Bool]
}

///|
pub fn new_core_debug_grandom_ui_bundle(
  symbolic_name? : String = core_debug_grandom_ui_plugin_id,
) -> CoreDebugGRandomUiBundle {
  { symbolic_name, classes: {} }
}

///|
pub fn CoreDebugGRandomUiBundle::register_class(
  self : CoreDebugGRandomUiBundle,
  class_name : String,
) -> Unit {
  self.classes[class_name] = true
}

///|
pub fn CoreDebugGRandomUiBundle::load_class(
  self : CoreDebugGRandomUiBundle,
  class_name : String,
) -> Bool {
  match self.classes.get(class_name) {
    Some(value) => value
    None => false
  }
}

///|
pub fn CoreDebugGRandomUiBundle::get_symbolic_name(
  self : CoreDebugGRandomUiBundle,
) -> String {
  self.symbolic_name
}

///|
pub(all) struct CoreDebugGRandomUiInjector {
  providers : Map[String, () -> CoreDebugGRandomUiObject]
}

///|
pub fn new_core_debug_grandom_ui_injector() -> CoreDebugGRandomUiInjector {
  { providers: {} }
}

///|
pub fn CoreDebugGRandomUiInjector::register_provider(
  self : CoreDebugGRandomUiInjector,
  class_name : String,
  provider : () -> CoreDebugGRandomUiObject,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn CoreDebugGRandomUiInjector::get_instance(
  self : CoreDebugGRandomUiInjector,
  class_name : String,
) -> CoreDebugGRandomUiObject? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub fn CoreDebugGRandomUiInjector::provider_count(
  self : CoreDebugGRandomUiInjector,
) -> Int {
  self.providers.to_array().length()
}

///|
pub(all) struct GrandomActivator {
  bundle : CoreDebugGRandomUiBundle
  injectors : Map[String, CoreDebugGRandomUiInjector]
}

///|
let core_debug_grandom_activator_instance_ref : Ref[GrandomActivator?] = Ref(
  None,
)

///|
pub fn new_grandom_activator() -> GrandomActivator {
  { bundle: new_core_debug_grandom_ui_bundle(), injectors: {} }
}

///|
pub fn GrandomActivator::start(self : GrandomActivator) -> Unit {
  core_debug_grandom_activator_instance_ref.val = Some(self)
}

///|
pub fn GrandomActivator::stop(self : GrandomActivator) -> Unit {
  self.injectors.clear()
  core_debug_grandom_activator_instance_ref.val = None
}

///|
pub fn grandom_activator_get_instance() -> GrandomActivator? {
  core_debug_grandom_activator_instance_ref.val
}

///|
pub fn grandom_activator_reset_for_test() -> Unit {
  core_debug_grandom_activator_instance_ref.val = None
}

///|
pub fn GrandomActivator::get_bundle(
  self : GrandomActivator,
) -> CoreDebugGRandomUiBundle {
  self.bundle
}

///|
pub fn GrandomActivator::register_bundle_class(
  self : GrandomActivator,
  class_name : String,
) -> Unit {
  self.bundle.register_class(class_name)
}

///|
pub fn GrandomActivator::injector_count(self : GrandomActivator) -> Int {
  self.injectors.to_array().length()
}

///|
pub fn GrandomActivator::get_runtime_module(
  self : GrandomActivator,
  grammar : String,
) -> @grandom.CoreDebugGRandomRuntimeModule {
  ignore(self)
  if grammar == core_debug_grandom_ui_language_name {
    return @grandom.new_core_debug_grandom_runtime_module()
  }
  try core_debug_grandom_ui_raise_unit("unknown grammar: " + grammar) catch {
    err => ignore(err)
  } noraise {
    _ => ()
  }
  @grandom.new_core_debug_grandom_runtime_module()
}

///|
pub fn GrandomActivator::get_ui_module(
  self : GrandomActivator,
  grammar : String,
) -> CoreDebugGRandomUiModule {
  ignore(self)
  if grammar == core_debug_grandom_ui_language_name {
    return new_core_debug_grandom_ui_module()
  }
  try core_debug_grandom_ui_raise_unit("unknown grammar: " + grammar) catch {
    err => ignore(err)
  } noraise {
    _ => ()
  }
  new_core_debug_grandom_ui_module()
}

///|
pub fn GrandomActivator::get_shared_state_module(
  self : GrandomActivator,
) -> String {
  ignore(self)
  "org.eclipse.xtext.ui.shared.SharedStateModule"
}

///|
fn core_debug_grandom_ui_create_default_injector() -> CoreDebugGRandomUiInjector {
  let injector = new_core_debug_grandom_ui_injector()
  injector.register_provider(
    "org.eclipse.elk.core.debug.grandom.ui.contentassist.GRandomProposalProvider",
    () => core_debug_grandom_ui_object_named("proposal_provider"),
  )
  injector.register_provider(
    "org.eclipse.elk.core.debug.grandom.ui.quickfix.GRandomQuickfixProvider",
    () => core_debug_grandom_ui_object_named("quickfix_provider"),
  )
  injector
}

///|
pub fn GrandomActivator::create_injector(
  self : GrandomActivator,
  language : String,
) -> CoreDebugGRandomUiInjector {
  ignore(self.get_runtime_module(language))
  ignore(self.get_shared_state_module())
  ignore(self.get_ui_module(language))
  core_debug_grandom_ui_create_default_injector()
}

///|
pub fn GrandomActivator::get_injector(
  self : GrandomActivator,
  language : String,
) -> CoreDebugGRandomUiInjector {
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
pub fn GrandomActivator::register_injector_provider(
  self : GrandomActivator,
  language_name : String,
  class_name : String,
  provider : () -> CoreDebugGRandomUiObject,
) -> Unit {
  let injector = self.get_injector(language_name)
  injector.register_provider(class_name, provider)
  self.injectors[language_name] = injector
}
