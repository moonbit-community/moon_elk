///|
pub struct GraphvizPreferenceStore {
  symbolic_name : String
  int_values : Map[String, Int]
  int_defaults : Map[String, Int]
  string_values : Map[String, String]
  string_defaults : Map[String, String]
  bool_values : Map[String, Bool]
  bool_defaults : Map[String, Bool]
}

///|
pub fn new_graphviz_preference_store(
  symbolic_name : String,
) -> GraphvizPreferenceStore {
  {
    symbolic_name,
    int_values: {},
    int_defaults: {},
    string_values: {},
    string_defaults: {},
    bool_values: {},
    bool_defaults: {},
  }
}

///|
pub fn GraphvizPreferenceStore::get_symbolic_name(
  self : GraphvizPreferenceStore,
) -> String {
  self.symbolic_name
}

///|
pub fn GraphvizPreferenceStore::set_default_int(
  self : GraphvizPreferenceStore,
  name : String,
  value : Int,
) -> Unit {
  self.int_defaults[name] = value
}

///|
pub fn GraphvizPreferenceStore::set_default_string(
  self : GraphvizPreferenceStore,
  name : String,
  value : String,
) -> Unit {
  self.string_defaults[name] = value
}

///|
pub fn GraphvizPreferenceStore::set_default_boolean(
  self : GraphvizPreferenceStore,
  name : String,
  value : Bool,
) -> Unit {
  self.bool_defaults[name] = value
}

///|
pub fn GraphvizPreferenceStore::set_int(
  self : GraphvizPreferenceStore,
  name : String,
  value : Int,
) -> Unit {
  self.int_values[name] = value
}

///|
pub fn GraphvizPreferenceStore::set_string(
  self : GraphvizPreferenceStore,
  name : String,
  value : String,
) -> Unit {
  self.string_values[name] = value
}

///|
pub fn GraphvizPreferenceStore::set_boolean(
  self : GraphvizPreferenceStore,
  name : String,
  value : Bool,
) -> Unit {
  self.bool_values[name] = value
}

///|
pub fn GraphvizPreferenceStore::get_int(
  self : GraphvizPreferenceStore,
  name : String,
) -> Int {
  match self.int_values.get(name) {
    Some(value) => value
    None =>
      match self.int_defaults.get(name) {
        Some(value) => value
        None => 0
      }
  }
}

///|
pub fn GraphvizPreferenceStore::get_string(
  self : GraphvizPreferenceStore,
  name : String,
) -> String {
  match self.string_values.get(name) {
    Some(value) => value
    None =>
      match self.string_defaults.get(name) {
        Some(value) => value
        None => ""
      }
  }
}

///|
pub fn GraphvizPreferenceStore::get_boolean(
  self : GraphvizPreferenceStore,
  name : String,
) -> Bool {
  match self.bool_values.get(name) {
    Some(value) => value
    None =>
      match self.bool_defaults.get(name) {
        Some(value) => value
        None => false
      }
  }
}

///|
pub struct GraphvizLayouterPreferenceStore {
  mut preference_store : GraphvizPreferenceStore?
}

///|
let graphviz_layouter_preference_store_ref : Ref[
  GraphvizLayouterPreferenceStore?,
] = Ref(None)

///|
pub fn new_graphviz_layouter_preference_store() -> GraphvizLayouterPreferenceStore {
  { preference_store: None }
}

///|
pub fn graphviz_layouter_preference_store_get_instance() -> GraphvizLayouterPreferenceStore {
  match graphviz_layouter_preference_store_ref.val {
    Some(instance) => instance
    None => {
      let instance = new_graphviz_layouter_preference_store()
      graphviz_layouter_preference_store_ref.val = Some(instance)
      instance
    }
  }
}

///|
pub fn GraphvizLayouterPreferenceStore::get_preference_store(
  self : GraphvizLayouterPreferenceStore,
) -> GraphvizPreferenceStore {
  match self.preference_store {
    Some(store) => store
    None => {
      let symbolic_name = match graphviz_layouter_plugin_get_default() {
        Some(plugin) => plugin.get_bundle().get_symbolic_name()
        None => graphviz_layouter_plugin_id
      }
      let store = new_graphviz_preference_store(symbolic_name)
      self.preference_store = Some(store)
      store
    }
  }
}

///|
pub fn graphviz_layouter_preference_store_reset_for_test() -> Unit {
  graphviz_layouter_preference_store_ref.val = None
}
