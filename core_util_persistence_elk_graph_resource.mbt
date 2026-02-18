///|
pub let elk_graph_resource_default_encoding : String = "utf-8"

///|
pub struct ElkGraphResource {
  uri : String
  mut encoding : String
}

///|
pub fn new_elk_graph_resource(uri : String) -> ElkGraphResource {
  { uri, encoding: elk_graph_resource_default_encoding }
}

///|
pub fn ElkGraphResource::get_uri(self : ElkGraphResource) -> String {
  self.uri
}

///|
pub fn ElkGraphResource::get_encoding(self : ElkGraphResource) -> String {
  self.encoding
}

///|
pub fn ElkGraphResource::set_encoding(
  self : ElkGraphResource,
  encoding : String,
) -> Unit {
  self.encoding = encoding
}

///|
pub fn ElkGraphResource::create_xml_save(
  self : ElkGraphResource,
) -> ElkGraphXMISave {
  new_elk_graph_xmi_save(self.create_xml_helper())
}

///|
pub fn ElkGraphResource::create_xml_save_with_options(
  self : ElkGraphResource,
  options : Map[String, String],
) -> ElkGraphXMISave {
  ignore(options)
  self.create_xml_save()
}

///|
pub fn ElkGraphResource::create_xml_helper(
  self : ElkGraphResource,
) -> ElkGraphXMIHelper {
  new_elk_graph_xmi_helper(self)
}
