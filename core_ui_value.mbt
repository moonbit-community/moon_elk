///|
pub enum CoreUiValue {
  CoreUiStringValue(String)
  CoreUiIntValue(Int)
  CoreUiDoubleValue(Double)
  CoreUiBoolValue(Bool)
  CoreUiStringsValue(Array[String])
  CoreUiNoValue
}

///|
pub fn core_ui_value_to_string(value : CoreUiValue) -> String {
  match value {
    CoreUiStringValue(text) => text
    CoreUiIntValue(number) => number.to_string()
    CoreUiDoubleValue(number) => number.to_string()
    CoreUiBoolValue(flag) => if flag { "true" } else { "false" }
    CoreUiStringsValue(values) => values.join(", ")
    CoreUiNoValue => ""
  }
}

///|
pub fn core_ui_value_as_string(value : CoreUiValue) -> String? {
  match value {
    CoreUiStringValue(text) => Some(text)
    _ => None
  }
}

///|
pub fn core_ui_value_as_int(value : CoreUiValue) -> Int? {
  match value {
    CoreUiIntValue(number) => Some(number)
    _ => None
  }
}

///|
pub fn core_ui_value_as_bool(value : CoreUiValue) -> Bool? {
  match value {
    CoreUiBoolValue(flag) => Some(flag)
    _ => None
  }
}

///|
pub fn core_ui_value_as_strings(value : CoreUiValue) -> Array[String]? {
  match value {
    CoreUiStringsValue(values) => Some(values)
    _ => None
  }
}
