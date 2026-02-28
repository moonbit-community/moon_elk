///|
pub(all) enum ElkGraphXmiDataType {
  IPropertyDataType
  PropertyValueDataType
  OtherDataType(String)
}

///|
pub let elk_graph_xmi_data_type_iproperty : ElkGraphXmiDataType = IPropertyDataType

///|
pub let elk_graph_xmi_data_type_property_value : ElkGraphXmiDataType = PropertyValueDataType

///|
pub fn new_elk_graph_xmi_data_type_other(name : String) -> ElkGraphXmiDataType {
  OtherDataType(name)
}

///|
pub(all) enum ElkGraphXmiValue {
  PropertyValue(LayoutOptionProxy)
  PropertyId(@graph.IProperty[String])
  RawValue(String)
}

///|
pub(all) struct ElkGraphXMIHelper {
  resource_uri : String
}

///|
pub fn new_elk_graph_xmi_helper(
  resource : ElkGraphResource,
) -> ElkGraphXMIHelper {
  { resource_uri: resource.get_uri() }
}

///|
pub fn ElkGraphXMIHelper::get_resource_uri(self : ElkGraphXMIHelper) -> String {
  self.resource_uri
}

///|
fn elk_graph_xmi_helper_create_i_property_from_string(
  id : String,
) -> @graph.IProperty[String] {
  if layout_meta_data_service_get_option_data_opt(id) is Some(option_data) {
    @graph.new_property(option_data.get_id(), "")
  } else {
    @graph.new_property(id, "")
  }
}

///|
fn elk_graph_xmi_helper_create_property_value_from_string(
  value : String,
) -> LayoutOptionProxy {
  new_layout_option_proxy(value)
}

///|
pub fn ElkGraphXMIHelper::create_from_string(
  self : ElkGraphXMIHelper,
  data_type : ElkGraphXmiDataType,
  value : String,
) -> ElkGraphXmiValue {
  ignore(self)
  match data_type {
    IPropertyDataType =>
      PropertyId(elk_graph_xmi_helper_create_i_property_from_string(value))
    PropertyValueDataType =>
      PropertyValue(
        elk_graph_xmi_helper_create_property_value_from_string(value),
      )
    OtherDataType(_) => RawValue(value)
  }
}
