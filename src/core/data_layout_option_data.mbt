///|
pub(all) enum LayoutOptionValueType {
  BoolType
  IntType
  DoubleType
  StringType
  EnumSetType
  ObjectType
}

///|
pub fn LayoutOptionValueType::to_string(self : LayoutOptionValueType) -> String {
  match self {
    BoolType => "BOOLEAN"
    IntType => "INT"
    DoubleType => "DOUBLE"
    StringType => "STRING"
    EnumSetType => "ENUMSET"
    ObjectType => "OBJECT"
  }
}

///|
pub(all) enum LayoutOptionTarget {
  ParentsTarget
  NodesTarget
  EdgesTarget
  PortsTarget
  LabelsTarget
}

///|
pub fn LayoutOptionTarget::to_string(self : LayoutOptionTarget) -> String {
  match self {
    ParentsTarget => "PARENTS"
    NodesTarget => "NODES"
    EdgesTarget => "EDGES"
    PortsTarget => "PORTS"
    LabelsTarget => "LABELS"
  }
}

///|
pub(all) enum LayoutOptionVisibility {
  VisibleOption
  AdvancedOption
  HiddenOption
}

///|
pub fn LayoutOptionVisibility::to_string(
  self : LayoutOptionVisibility,
) -> String {
  match self {
    VisibleOption => "VISIBLE"
    AdvancedOption => "ADVANCED"
    HiddenOption => "HIDDEN"
  }
}

///|
pub(all) struct LayoutOptionDependency {
  option_id : String
  expected_value : String?
}

///|
pub fn new_layout_option_dependency(
  option_id : String,
  expected_value? : String? = None,
) -> LayoutOptionDependency {
  { option_id, expected_value }
}

///|
pub fn LayoutOptionDependency::get_option_id(
  self : LayoutOptionDependency,
) -> String {
  self.option_id
}

///|
pub fn LayoutOptionDependency::get_expected_value(
  self : LayoutOptionDependency,
) -> String? {
  self.expected_value
}

///|
pub(all) struct LayoutOptionData {
  id : String
  name : String
  description : String
  group : String
  option_type : LayoutOptionValueType
  lower_bound : Double?
  lower_bound_exclusive : Bool
  targets : Array[LayoutOptionTarget]
  visibility : LayoutOptionVisibility
  mut choices : Array[String]
  dependencies : Array[LayoutOptionDependency]
  advanced_choices : Array[String]
  experimental_choices : Array[String]
}

///|
pub fn new_layout_option_data(
  id : String,
  name? : String = "",
  description? : String = "",
  group? : String = "",
  option_type? : LayoutOptionValueType = ObjectType,
  lower_bound? : Double? = None,
  lower_bound_exclusive? : Bool = false,
  targets? : Array[LayoutOptionTarget] = [],
  visibility? : LayoutOptionVisibility = VisibleOption,
  choices? : Array[String] = [],
  dependencies? : Array[LayoutOptionDependency] = [],
  advanced_choices? : Array[String] = [],
  experimental_choices? : Array[String] = [],
) -> LayoutOptionData {
  {
    id,
    name,
    description,
    group,
    option_type,
    lower_bound,
    lower_bound_exclusive,
    targets,
    visibility,
    choices,
    dependencies,
    advanced_choices,
    experimental_choices,
  }
}

///|
pub fn LayoutOptionData::get_id(self : LayoutOptionData) -> String {
  self.id
}

///|
pub fn LayoutOptionData::get_name(self : LayoutOptionData) -> String {
  self.name
}

///|
pub fn LayoutOptionData::get_description(self : LayoutOptionData) -> String {
  self.description
}

///|
pub fn LayoutOptionData::get_group(self : LayoutOptionData) -> String {
  self.group
}

///|
pub fn LayoutOptionData::get_type(
  self : LayoutOptionData,
) -> LayoutOptionValueType {
  self.option_type
}

///|
pub fn LayoutOptionData::get_lower_bound(self : LayoutOptionData) -> Double? {
  self.lower_bound
}

///|
pub fn LayoutOptionData::is_lower_bound_exclusive(
  self : LayoutOptionData,
) -> Bool {
  self.lower_bound_exclusive
}

///|
pub fn LayoutOptionData::get_targets(
  self : LayoutOptionData,
) -> Array[LayoutOptionTarget] {
  self.targets
}

///|
pub fn LayoutOptionData::get_visibility(
  self : LayoutOptionData,
) -> LayoutOptionVisibility {
  self.visibility
}

///|
pub fn LayoutOptionData::set_choices(
  self : LayoutOptionData,
  choices : Array[String],
) -> Unit {
  self.choices = choices
}

///|
pub fn LayoutOptionData::add_choice(
  self : LayoutOptionData,
  choice : String,
) -> Unit {
  self.choices.push(choice)
}

///|
pub fn LayoutOptionData::get_choices(self : LayoutOptionData) -> Array[String] {
  self.choices
}

///|
pub fn LayoutOptionData::get_enum_value_count(self : LayoutOptionData) -> Int {
  self.choices.length()
}

///|
pub fn LayoutOptionData::get_enum_value(
  self : LayoutOptionData,
  index : Int,
) -> String {
  self.choices[index]
}

///|
pub fn LayoutOptionData::add_dependency(
  self : LayoutOptionData,
  option_id : String,
  expected_value? : String? = None,
) -> Unit {
  self.dependencies.push(
    new_layout_option_dependency(option_id, expected_value~),
  )
}

///|
pub fn LayoutOptionData::get_dependencies(
  self : LayoutOptionData,
) -> Array[LayoutOptionDependency] {
  self.dependencies
}

///|
pub fn LayoutOptionData::mark_advanced_choice(
  self : LayoutOptionData,
  choice : String,
) -> Unit {
  self.advanced_choices.push(choice)
}

///|
pub fn LayoutOptionData::mark_experimental_choice(
  self : LayoutOptionData,
  choice : String,
) -> Unit {
  self.experimental_choices.push(choice)
}

///|
fn layout_option_data_contains(values : Array[String], target : String) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
pub fn LayoutOptionData::is_advanced_choice(
  self : LayoutOptionData,
  choice : String,
) -> Bool {
  layout_option_data_contains(self.advanced_choices, choice)
}

///|
pub fn LayoutOptionData::is_experimental_choice(
  self : LayoutOptionData,
  choice : String,
) -> Bool {
  layout_option_data_contains(self.experimental_choices, choice)
}

///|
fn parse_bool_text(value : String) -> Bool? {
  let normalized = value.trim().to_lower()
  if normalized == "true" || normalized == "1" || normalized == "yes" {
    Some(true)
  } else if normalized == "false" || normalized == "0" || normalized == "no" {
    Some(false)
  } else {
    None
  }
}

///|
fn split_enumset_values(value : String) -> Array[String] {
  let normalized = value.replace(old=",", new=" ")
  let result : Array[String] = []
  for part in normalized.split(" ") {
    let trimmed = part.trim()
    if !trimmed.is_empty() {
      result.push(trimmed.to_string())
    }
  }
  result
}

///|
pub fn LayoutOptionData::parse_value(
  self : LayoutOptionData,
  value : String,
) -> String {
  match self.option_type {
    BoolType =>
      match parse_bool_text(value) {
        Some(parsed) => if parsed { "true" } else { "false" }
        None => value
      }
    IntType => {
      let parsed : Result[Int, Error] = try? @string.parse_int(value.trim())
      match parsed {
        Ok(parsed) => parsed.to_string()
        Err(_) => value
      }
    }
    DoubleType => {
      let parsed : Result[Double, Error] = try? @string.parse_double(
        value.trim(),
      )
      match parsed {
        Ok(parsed) => parsed.to_string()
        Err(_) => value
      }
    }
    EnumSetType => split_enumset_values(value).join(" ")
    _ => value
  }
}
