///|
pub enum LayoutOptionValueType {
  BoolType
  IntType
  DoubleType
  StringType
  EnumSetType
  ObjectType
}

///|
pub enum LayoutOptionTarget {
  ParentsTarget
  NodesTarget
  EdgesTarget
  PortsTarget
  LabelsTarget
}

///|
pub enum LayoutOptionVisibility {
  VisibleOption
  AdvancedOption
  HiddenOption
}

///|
pub struct LayoutOptionData {
  id : String
  name : String
  description : String
  group : String
  option_type : LayoutOptionValueType
  lower_bound : Double?
  lower_bound_exclusive : Bool
  targets : Array[LayoutOptionTarget]
  visibility : LayoutOptionVisibility
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
