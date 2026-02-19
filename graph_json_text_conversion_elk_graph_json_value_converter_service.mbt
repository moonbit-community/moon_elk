///|
pub struct ElkGraphJsonValueConverterService {
  number_value_converter : GraphJsonTextNumberValueConverter
  property_key_value_converter : GraphJsonTextPropertyKeyValueConverter
  property_value_value_converter : GraphJsonTextPropertyValueValueConverter
}

///|
pub fn new_elk_graph_json_value_converter_service(
  number_value_converter? : GraphJsonTextNumberValueConverter = new_graph_json_text_number_value_converter(),
  property_key_value_converter? : GraphJsonTextPropertyKeyValueConverter = new_graph_json_text_property_key_value_converter(),
  property_value_value_converter? : GraphJsonTextPropertyValueValueConverter = new_graph_json_text_property_value_value_converter(),
) -> ElkGraphJsonValueConverterService {
  {
    number_value_converter,
    property_key_value_converter,
    property_value_value_converter,
  }
}

///|
pub fn ElkGraphJsonValueConverterService::number(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextNumberValueConverter {
  self.number_value_converter
}

///|
pub fn ElkGraphJsonValueConverterService::property_key(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextPropertyKeyValueConverter {
  self.property_key_value_converter
}

///|
pub fn ElkGraphJsonValueConverterService::string_value(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextPropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphJsonValueConverterService::qualified_id_value(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextPropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphJsonValueConverterService::number_value(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextPropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphJsonValueConverterService::boolean_value(
  self : ElkGraphJsonValueConverterService,
) -> GraphJsonTextPropertyValueValueConverter {
  self.property_value_value_converter
}
