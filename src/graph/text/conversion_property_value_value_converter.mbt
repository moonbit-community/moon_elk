///|
pub struct PropertyValueValueConverter {
  qualified_name_converter : ElkGraphQualifiedNameConverter
}

///|
pub fn new_property_value_value_converter(
  qualified_name_converter? : ElkGraphQualifiedNameConverter = new_elk_graph_qualified_name_converter(),
) -> PropertyValueValueConverter {
  { qualified_name_converter, }
}

///|
fn graph_text_property_value_parse_bool(text : String) -> Bool? {
  if text == "true" {
    Some(true)
  } else if text == "false" {
    Some(false)
  } else {
    None
  }
}

///|
fn graph_text_property_value_parse_number(text : String) -> Double? {
  let parsed : Result[Double, Error] = try? @string.parse_double(text)
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn graph_text_property_value_is_id_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn graph_text_property_value_needs_quoting(text : String) -> Bool {
  if text == "" {
    return true
  }
  let mut idx = 0
  while idx < text.length() {
    let ch = text[idx].unsafe_to_char()
    if (ch >= 'a' && ch <= 'z') ||
      (ch >= 'A' && ch <= 'Z') ||
      (ch >= '0' && ch <= '9') ||
      ch == '_' ||
      ch == '.' ||
      ch == '^' {
      idx += 1
      continue
    }
    return true
  }
  false
}

///|
fn graph_text_property_value_quote_if_necessary(
  converter : ElkGraphQualifiedNameConverter,
  text : String,
) -> String {
  if graph_text_property_value_needs_quoting(text) {
    "\"" + text + "\""
  } else {
    converter.to_string(converter.to_qualified_name(text))
  }
}

///|
fn graph_text_property_value_unquote_if_necessary(
  converter : ElkGraphQualifiedNameConverter,
  text : String,
) -> String {
  if text.length() >= 2 &&
    (
      (text.has_prefix("\"") && text.has_suffix("\"")) ||
      (text.has_prefix("'") && text.has_suffix("'"))
    ) {
    text.unsafe_substring(start=1, end=text.length() - 1)
  } else if text.length() >= 1 {
    let first = text[0].unsafe_to_char()
    if graph_text_property_value_is_id_start(first) || first == '^' {
      converter.to_qualified_name(text).join(".")
    } else {
      text
    }
  } else {
    text
  }
}

///|
fn graph_text_property_value_from_option_type(
  option_data : @core.LayoutOptionData,
  text : String,
) -> GraphTextPropertyValue {
  match option_data.get_type() {
    BoolType =>
      match graph_text_property_value_parse_bool(text) {
        Some(flag) => BooleanValue(flag)
        None => ProxyValue(text)
      }
    IntType =>
      match graph_text_property_value_parse_number(text) {
        Some(number) => NumberValue(number.to_int().to_double())
        None => ProxyValue(text)
      }
    DoubleType =>
      match graph_text_property_value_parse_number(text) {
        Some(number) => NumberValue(number)
        None => ProxyValue(text)
      }
    _ => ProxyValue(option_data.parse_value(text))
  }
}

///|
pub fn PropertyValueValueConverter::to_string(
  self : PropertyValueValueConverter,
  value : GraphTextPropertyValue,
) -> String {
  match value {
    NullValue => "null"
    NumberValue(number) =>
      if number.to_int().to_double() == number {
        number.to_int().to_string()
      } else {
        number.to_string()
      }
    BooleanValue(flag) => if flag { "true" } else { "false" }
    StringValue(text) =>
      if text == "true" || text == "false" || text == "null" {
        text
      } else if graph_text_property_value_parse_number(text) is Some(_) {
        text
      } else {
        graph_text_property_value_quote_if_necessary(
          self.qualified_name_converter,
          text,
        )
      }
    ProxyValue(text) =>
      graph_text_property_value_quote_if_necessary(
        self.qualified_name_converter,
        text,
      )
  }
}

///|
pub fn PropertyValueValueConverter::to_value(
  self : PropertyValueValueConverter,
  text : String,
  property_key? : GraphTextPropertyKey? = None,
) -> GraphTextPropertyValue {
  if text == "" || text == "null" {
    return NullValue
  }
  let unquoted = graph_text_property_value_unquote_if_necessary(
    self.qualified_name_converter,
    text,
  )
  match property_key {
    Some(key) =>
      match graph_text_property_key_to_layout_option(key) {
        Some(option_data) =>
          graph_text_property_value_from_option_type(option_data, unquoted)
        None => ProxyValue(unquoted)
      }
    None => ProxyValue(unquoted)
  }
}
