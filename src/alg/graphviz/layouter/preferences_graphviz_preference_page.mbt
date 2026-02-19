///|
pub let graphviz_preference_page_id : String = "org.eclipse.elk.alg.graphviz.preferences"

///|
let graphviz_preference_page_description : String = "Controls how the Eclipse Layout Kernel interacts with the Graphviz layout tools. " +
  "The Graphviz layout tools are available at http://www.graphviz.org/. " +
  "If the 'dot' executable cannot be found in default locations, " +
  "its path must be entered here."

///|
let graphviz_preference_page_graphviz_bundle_name : String = "Graphviz"

///|
let graphviz_preference_page_timeout_max_value : Int = @int.max_value

///|
pub enum GraphvizPreferenceFieldKind {
  GraphvizPreferenceFileField
  GraphvizPreferenceIntegerField
  GraphvizPreferenceBooleanField
}

///|
pub struct GraphvizPreferenceField {
  name : String
  label : String
  kind : GraphvizPreferenceFieldKind
  validate_on_key_stroke : Bool
  min_value : Int
  max_value : Int
}

///|
fn new_graphviz_preference_file_field(
  name : String,
  label : String,
) -> GraphvizPreferenceField {
  {
    name,
    label,
    kind: GraphvizPreferenceFileField,
    validate_on_key_stroke: true,
    min_value: 0,
    max_value: 0,
  }
}

///|
fn new_graphviz_preference_integer_field(
  name : String,
  label : String,
  min_value : Int,
  max_value : Int,
) -> GraphvizPreferenceField {
  {
    name,
    label,
    kind: GraphvizPreferenceIntegerField,
    validate_on_key_stroke: false,
    min_value,
    max_value,
  }
}

///|
fn new_graphviz_preference_boolean_field(
  name : String,
  label : String,
) -> GraphvizPreferenceField {
  {
    name,
    label,
    kind: GraphvizPreferenceBooleanField,
    validate_on_key_stroke: false,
    min_value: 0,
    max_value: 0,
  }
}

///|
pub fn GraphvizPreferenceField::get_name(
  self : GraphvizPreferenceField,
) -> String {
  self.name
}

///|
pub fn GraphvizPreferenceField::get_label(
  self : GraphvizPreferenceField,
) -> String {
  self.label
}

///|
pub fn GraphvizPreferenceField::get_kind(
  self : GraphvizPreferenceField,
) -> GraphvizPreferenceFieldKind {
  self.kind
}

///|
pub fn GraphvizPreferenceField::get_validate_on_key_stroke(
  self : GraphvizPreferenceField,
) -> Bool {
  self.validate_on_key_stroke
}

///|
pub fn GraphvizPreferenceField::get_min_value(
  self : GraphvizPreferenceField,
) -> Int {
  self.min_value
}

///|
pub fn GraphvizPreferenceField::get_max_value(
  self : GraphvizPreferenceField,
) -> Int {
  self.max_value
}

///|
pub struct GraphvizPreferencePage {
  fields : Array[GraphvizPreferenceField]
  mut preference_store : GraphvizPreferenceStore?
}

///|
pub fn new_graphviz_preference_page() -> GraphvizPreferencePage {
  { fields: [], preference_store: None }
}

///|
pub fn GraphvizPreferencePage::get_description(
  self : GraphvizPreferencePage,
) -> String {
  ignore(self)
  graphviz_preference_page_description
}

///|
pub fn GraphvizPreferencePage::create_field_editors(
  self : GraphvizPreferencePage,
) -> Unit {
  self.fields.clear()

  self.fields.push(
    new_graphviz_preference_file_field(
      graphviz_tool_pref_graphviz_executable, "Path to 'dot' executable:",
    ),
  )

  self.fields.push(
    new_graphviz_preference_integer_field(
      graphviz_tool_pref_timeout, "Timeout (ms):", graphviz_tool_process_min_timeout,
      graphviz_preference_page_timeout_max_value,
    ),
  )

  self.fields.push(
    new_graphviz_preference_boolean_field(
      graphviz_layout_provider_pref_graphviz_reuse_process, "Reuse single graphviz process for better performance",
    ),
  )
}

///|
pub fn GraphvizPreferencePage::get_fields(
  self : GraphvizPreferencePage,
) -> Array[GraphvizPreferenceField] {
  self.fields
}

///|
pub fn GraphvizPreferencePage::init(self : GraphvizPreferencePage) -> Unit {
  self.preference_store = Some(
    graphviz_layouter_preference_store_get_instance().get_preference_store(),
  )
}

///|
pub fn GraphvizPreferencePage::get_preference_store(
  self : GraphvizPreferencePage,
) -> GraphvizPreferenceStore? {
  self.preference_store
}

///|
pub fn GraphvizPreferencePage::perform_ok(
  self : GraphvizPreferencePage,
) -> Bool {
  ignore(self)
  for algorithm_data in @core.layout_meta_data_service_algorithm_data_values() {
    if algorithm_data.get_bundle_name() ==
      graphviz_preference_page_graphviz_bundle_name {
      algorithm_data.clear_instance_pool()
    }
  }
  true
}
