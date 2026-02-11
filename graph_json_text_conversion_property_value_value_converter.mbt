///|
pub struct GraphJsonTextPropertyValueValueConverter {
  qualified_name_converter : ElkGraphJsonQualifiedNameConverter
}

///|
pub fn new_graph_json_text_property_value_value_converter(
  qualified_name_converter? : ElkGraphJsonQualifiedNameConverter = new_elk_graph_json_qualified_name_converter(),
) -> GraphJsonTextPropertyValueValueConverter {
  { qualified_name_converter, }
}

///|
fn graph_json_text_property_value_parse_bool(text : String) -> Bool? {
  if text == "true" {
    Some(true)
  } else if text == "false" {
    Some(false)
  } else {
    None
  }
}

///|
fn graph_json_text_property_value_parse_number(text : String) -> Double? {
  let parsed : Result[Double, @strconv.StrConvError] = try? @strconv.parse_double(
    text,
  )
  match parsed {
    Ok(value) => Some(value)
    Err(_) => None
  }
}

///|
fn graph_json_text_property_value_is_id_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn graph_json_text_property_value_needs_quoting(text : String) -> Bool {
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
fn graph_json_text_property_value_quote_if_necessary(
  converter : ElkGraphJsonQualifiedNameConverter,
  text : String,
) -> String {
  if graph_json_text_property_value_needs_quoting(text) {
    "\"" + text + "\""
  } else {
    converter.to_string(converter.to_qualified_name(text))
  }
}

///|
fn graph_json_text_property_value_unquote_if_necessary(
  converter : ElkGraphJsonQualifiedNameConverter,
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
    if graph_json_text_property_value_is_id_start(first) || first == '^' {
      converter.to_qualified_name(text).join(".")
    } else {
      text
    }
  } else {
    text
  }
}

///|
fn graph_json_text_property_value_from_option_type(
  option_data : LayoutOptionData,
  text : String,
) -> GraphJsonTextPropertyValue {
  match option_data.get_type() {
    BoolType =>
      match graph_json_text_property_value_parse_bool(text) {
        Some(flag) => GraphJsonTextBooleanValue(flag)
        None => GraphJsonTextProxyValue(text)
      }
    IntType =>
      match graph_json_text_property_value_parse_number(text) {
        Some(number) => GraphJsonTextNumberValue(number.to_int().to_double())
        None => GraphJsonTextProxyValue(text)
      }
    DoubleType =>
      match graph_json_text_property_value_parse_number(text) {
        Some(number) => GraphJsonTextNumberValue(number)
        None => GraphJsonTextProxyValue(text)
      }
    _ => GraphJsonTextProxyValue(option_data.parse_value(text))
  }
}

///|
pub fn GraphJsonTextPropertyValueValueConverter::to_string(
  self : GraphJsonTextPropertyValueValueConverter,
  value : GraphJsonTextPropertyValue,
) -> String {
  match value {
    GraphJsonTextNullValue => "null"
    GraphJsonTextNumberValue(number) =>
      if number.to_int().to_double() == number {
        number.to_int().to_string()
      } else {
        number.to_string()
      }
    GraphJsonTextBooleanValue(flag) => if flag { "true" } else { "false" }
    GraphJsonTextStringValue(text) =>
      if text == "true" || text == "false" || text == "null" {
        text
      } else if graph_json_text_property_value_parse_number(text) is Some(_) {
        text
      } else {
        graph_json_text_property_value_quote_if_necessary(
          self.qualified_name_converter,
          text,
        )
      }
    GraphJsonTextProxyValue(text) => "\"" + text + "\""
  }
}

///|
pub fn GraphJsonTextPropertyValueValueConverter::to_value(
  self : GraphJsonTextPropertyValueValueConverter,
  text : String,
  property_key? : GraphJsonTextPropertyKey? = None,
) -> GraphJsonTextPropertyValue {
  if text == "" || text == "null" {
    return GraphJsonTextNullValue
  }
  let unquoted = graph_json_text_property_value_unquote_if_necessary(
    self.qualified_name_converter,
    text,
  )
  match property_key {
    Some(key) =>
      match graph_json_text_property_key_to_layout_option(key) {
        Some(option_data) =>
          graph_json_text_property_value_from_option_type(option_data, unquoted)
        None => GraphJsonTextProxyValue(unquoted)
      }
    None => GraphJsonTextProxyValue(unquoted)
  }
}
