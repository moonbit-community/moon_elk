///|
pub struct LayoutOptionProxy {
  value : String
}

///|
pub fn new_layout_option_proxy(value : String) -> LayoutOptionProxy {
  { value, }
}

///|
pub fn layout_option_proxy_set_proxy_value(
  property_holder : Map[String, LayoutOptionProxy],
  key : String,
  value : String,
) -> Unit {
  property_holder[key] = new_layout_option_proxy(value)
}

///|
pub fn LayoutOptionProxy::resolve_value(
  self : LayoutOptionProxy,
  property : IProperty[String]?,
) -> String? {
  if property is Some(prop) {
    if layout_meta_data_service_get_option_data_opt(prop.get_id())
      is Some(option_data) {
      return Some(option_data.parse_value(self.value))
    }
  }
  None
}

///|
pub fn LayoutOptionProxy::resolve_value_with_option(
  self : LayoutOptionProxy,
  option_data : LayoutOptionData?,
) -> String? {
  if option_data is Some(data) {
    Some(data.parse_value(self.value))
  } else {
    None
  }
}

///|
pub fn LayoutOptionProxy::to_string(self : LayoutOptionProxy) -> String {
  self.value
}

///|
pub fn LayoutOptionProxy::equals(
  self : LayoutOptionProxy,
  other : LayoutOptionProxy,
) -> Bool {
  self.value == other.value
}

///|
pub fn LayoutOptionProxy::hash_code(self : LayoutOptionProxy) -> Int {
  self.value.hash()
}
