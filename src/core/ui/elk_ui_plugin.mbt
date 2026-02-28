///|
pub let elk_ui_plugin_id : String = "org.eclipse.elk.core.ui"

///|
pub let elk_ui_img_choice : String = "obj16/prop_choice.gif"

///|
pub let elk_ui_img_double : String = "obj16/prop_double.gif"

///|
pub let elk_ui_img_int : String = "obj16/prop_int.gif"

///|
pub let elk_ui_img_text : String = "obj16/prop_text.gif"

///|
pub let elk_ui_img_true : String = "obj16/prop_true.gif"

///|
pub let elk_ui_img_false : String = "obj16/prop_false.gif"

///|
pub(all) struct CoreUiImageDescriptor {
  plugin_id : String
  path : String
}

///|
pub fn CoreUiImageDescriptor::to_string(self : CoreUiImageDescriptor) -> String {
  "\{self.plugin_id}:\{self.path}"
}

///|
pub(all) struct CoreUiImageRegistry {
  images : Map[String, CoreUiImageDescriptor]
}

///|
pub fn new_core_ui_image_registry() -> CoreUiImageRegistry {
  { images: {} }
}

///|
pub fn CoreUiImageRegistry::put(
  self : CoreUiImageRegistry,
  id : String,
  descriptor : CoreUiImageDescriptor,
) -> Unit {
  self.images[id] = descriptor
}

///|
pub fn CoreUiImageRegistry::get(
  self : CoreUiImageRegistry,
  id : String,
) -> CoreUiImageDescriptor? {
  self.images.get(id)
}

///|
pub fn CoreUiImageRegistry::size(self : CoreUiImageRegistry) -> Int {
  self.images.length()
}

///|
pub(all) struct CoreUiPreferenceStore {
  bool_values : Map[String, Bool]
  bool_defaults : Map[String, Bool]
  string_values : Map[String, String]
  string_defaults : Map[String, String]
}

///|
pub fn new_core_ui_preference_store() -> CoreUiPreferenceStore {
  { bool_values: {}, bool_defaults: {}, string_values: {}, string_defaults: {} }
}

///|
pub fn CoreUiPreferenceStore::set_default_boolean(
  self : CoreUiPreferenceStore,
  key : String,
  value : Bool,
) -> Unit {
  self.bool_defaults[key] = value
}

///|
pub fn CoreUiPreferenceStore::set_default_string(
  self : CoreUiPreferenceStore,
  key : String,
  value : String,
) -> Unit {
  self.string_defaults[key] = value
}

///|
pub fn CoreUiPreferenceStore::get_default_boolean(
  self : CoreUiPreferenceStore,
  key : String,
) -> Bool {
  match self.bool_defaults.get(key) {
    Some(value) => value
    None => false
  }
}

///|
pub fn CoreUiPreferenceStore::set_boolean(
  self : CoreUiPreferenceStore,
  key : String,
  value : Bool,
) -> Unit {
  self.bool_values[key] = value
}

///|
pub fn CoreUiPreferenceStore::set_string(
  self : CoreUiPreferenceStore,
  key : String,
  value : String,
) -> Unit {
  self.string_values[key] = value
}

///|
pub fn CoreUiPreferenceStore::get_boolean(
  self : CoreUiPreferenceStore,
  key : String,
) -> Bool {
  match self.bool_values.get(key) {
    Some(value) => value
    None =>
      match self.bool_defaults.get(key) {
        Some(default_value) => default_value
        None => false
      }
  }
}

///|
pub fn CoreUiPreferenceStore::get_string(
  self : CoreUiPreferenceStore,
  key : String,
) -> String {
  match self.string_values.get(key) {
    Some(value) => value
    None =>
      match self.string_defaults.get(key) {
        Some(default_value) => default_value
        None => ""
      }
  }
}

///|
pub fn CoreUiPreferenceStore::clear(self : CoreUiPreferenceStore) -> Unit {
  self.bool_values.clear()
  self.bool_defaults.clear()
  self.string_values.clear()
  self.string_defaults.clear()
}

///|
pub(all) struct ElkUiPlugin {
  mut started : Bool
  image_registry : CoreUiImageRegistry
  preference_store : CoreUiPreferenceStore
}

///|
let elk_ui_plugin_ref : Ref[ElkUiPlugin?] = Ref::new(None)

///|
pub fn new_elk_ui_plugin() -> ElkUiPlugin {
  {
    started: false,
    image_registry: new_core_ui_image_registry(),
    preference_store: new_core_ui_preference_store(),
  }
}

///|
fn elk_ui_plugin_register_image(
  plugin : ElkUiPlugin,
  image_id : String,
) -> Unit {
  plugin.image_registry.put(
    image_id,
    elk_ui_plugin_get_image_descriptor("icons/" + image_id),
  )
}

///|
fn elk_ui_plugin_initialize_image_registry(plugin : ElkUiPlugin) -> Unit {
  for
    image_id in [
      elk_ui_img_choice, elk_ui_img_double, elk_ui_img_int, elk_ui_img_text, elk_ui_img_true,
      elk_ui_img_false,
    ] {
    elk_ui_plugin_register_image(plugin, image_id)
  }
}

///|
pub fn ElkUiPlugin::start(self : ElkUiPlugin, _context? : String = "") -> Unit {
  self.started = true
  elk_ui_plugin_initialize_image_registry(self)
  elk_ui_plugin_ref.val = Some(self)
}

///|
pub fn ElkUiPlugin::stop(self : ElkUiPlugin, _context? : String = "") -> Unit {
  self.started = false
  self.preference_store.clear()
  self.image_registry.images.clear()
  elk_ui_plugin_ref.val = None
}

///|
pub fn ElkUiPlugin::is_started(self : ElkUiPlugin) -> Bool {
  self.started
}

///|
pub fn ElkUiPlugin::get_image_registry(
  self : ElkUiPlugin,
) -> CoreUiImageRegistry {
  self.image_registry
}

///|
pub fn ElkUiPlugin::get_preference_store(
  self : ElkUiPlugin,
) -> CoreUiPreferenceStore {
  self.preference_store
}

///|
pub fn elk_ui_plugin_get_instance() -> ElkUiPlugin {
  match elk_ui_plugin_ref.val {
    Some(plugin) => plugin
    None => {
      let plugin = new_elk_ui_plugin()
      elk_ui_plugin_ref.val = Some(plugin)
      plugin
    }
  }
}

///|
pub fn elk_ui_plugin_get_image_descriptor(
  path : String,
) -> CoreUiImageDescriptor {
  { plugin_id: elk_ui_plugin_id, path }
}

///|
pub fn elk_ui_plugin_reset_for_test() -> Unit {
  elk_ui_plugin_ref.val = None
}
