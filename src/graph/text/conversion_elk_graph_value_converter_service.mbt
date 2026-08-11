///|
pub struct ElkGraphValueConverterService {
  number_value_converter : NumberValueConverter
  property_key_value_converter : PropertyKeyValueConverter
  property_value_value_converter : PropertyValueValueConverter
}

///|
pub fn new_elk_graph_value_converter_service(
  metadata : @core.OptionMetadata,
  number_value_converter? : NumberValueConverter = new_number_value_converter(),
  property_key_value_converter? : PropertyKeyValueConverter,
  property_value_value_converter? : PropertyValueValueConverter,
) -> ElkGraphValueConverterService {
  let property_key_value_converter = property_key_value_converter.unwrap_or(
    new_property_key_value_converter(metadata),
  )
  let property_value_value_converter = property_value_value_converter.unwrap_or(
    new_property_value_value_converter(metadata),
  )
  {
    number_value_converter,
    property_key_value_converter,
    property_value_value_converter,
  }
}

///|
pub fn ElkGraphValueConverterService::number(
  self : ElkGraphValueConverterService,
) -> NumberValueConverter {
  self.number_value_converter
}

///|
pub fn ElkGraphValueConverterService::property_key(
  self : ElkGraphValueConverterService,
) -> PropertyKeyValueConverter {
  self.property_key_value_converter
}

///|
pub fn ElkGraphValueConverterService::string_value(
  self : ElkGraphValueConverterService,
) -> PropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphValueConverterService::qualified_id_value(
  self : ElkGraphValueConverterService,
) -> PropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphValueConverterService::number_value(
  self : ElkGraphValueConverterService,
) -> PropertyValueValueConverter {
  self.property_value_value_converter
}

///|
pub fn ElkGraphValueConverterService::boolean_value(
  self : ElkGraphValueConverterService,
) -> PropertyValueValueConverter {
  self.property_value_value_converter
}
