///|
pub(all) struct ElkGraphXMISave {
  helper : ElkGraphXMIHelper
}

///|
fn elk_graph_xmi_save_can_parse_value(option_data : LayoutOptionData) -> Bool {
  match option_data.get_type() {
    ObjectType => false
    _ => true
  }
}

///|
pub fn new_elk_graph_xmi_save(helper : ElkGraphXMIHelper) -> ElkGraphXMISave {
  { helper, }
}

///|
pub fn ElkGraphXMISave::get_helper(self : ElkGraphXMISave) -> ElkGraphXMIHelper {
  self.helper
}

///|
pub fn ElkGraphXMISave::should_save_property_entry(
  self : ElkGraphXMISave,
  property_id : String?,
) -> Bool {
  ignore(self)
  if property_id is Some(id) {
    if layout_meta_data_service_get_option_data_opt(id) is Some(option_data) {
      elk_graph_xmi_save_can_parse_value(option_data)
    } else {
      false
    }
  } else {
    false
  }
}

///|
pub fn ElkGraphXMISave::save_property_entry(
  self : ElkGraphXMISave,
  sink : Map[String, String],
  property_id : String?,
  property_value : String,
) -> Bool {
  if !self.should_save_property_entry(property_id) {
    return false
  }
  if property_id is Some(id) {
    sink[id] = property_value
    true
  } else {
    false
  }
}
