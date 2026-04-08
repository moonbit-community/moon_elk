///|
pub struct GraphJsonTextPropertyKeyValueConverter {
  mut id_rule : String
}

///|
pub suberror GraphJsonTextPropertyKeyValueConverterException {
  GraphJsonTextPropertyKeyValueConverterException(String)
} derive(Debug, ToJson)

///|
fn graph_json_text_property_key_value_converter_raise_unit(
  message : String,
) -> Unit raise GraphJsonTextPropertyKeyValueConverterException {
  raise GraphJsonTextPropertyKeyValueConverterException(message)
}

///|
pub fn new_graph_json_text_property_key_value_converter() -> GraphJsonTextPropertyKeyValueConverter {
  { id_rule: "ID" }
}

///|
pub fn GraphJsonTextPropertyKeyValueConverter::initialize(
  self : GraphJsonTextPropertyKeyValueConverter,
  grammar_access : ElkGraphJsonGrammarAccess,
) -> Unit {
  self.id_rule = grammar_access.get_id_rule()
}

///|
fn graph_json_text_split_dotted_segments(text : String) -> Array[String] {
  let segments : Array[String] = []
  let mut current = ""
  let mut idx = 0
  while idx < text.length() {
    let ch = text[idx].unsafe_to_char()
    if ch == '.' {
      segments.push(current)
      current = ""
    } else {
      current += ch.to_string()
    }
    idx += 1
  }
  segments.push(current)
  segments
}

///|
fn graph_json_text_join_dotted_segments(segments : Array[String]) -> String {
  segments.join(".")
}

///|
fn graph_json_text_property_key_is_keyword(text : String) -> Bool {
  text == "graph" ||
  text == "node" ||
  text == "label" ||
  text == "port" ||
  text == "layout" ||
  text == "position" ||
  text == "size" ||
  text == "edge" ||
  text == "incoming" ||
  text == "outgoing" ||
  text == "start" ||
  text == "end" ||
  text == "bends" ||
  text == "section" ||
  text == "null" ||
  text == "true" ||
  text == "false"
}

///|
fn graph_json_text_property_key_id_to_value(text : String) -> String {
  if text.length() > 0 && text.has_prefix("^") {
    text.unsafe_substring(start=1, end=text.length())
  } else {
    text
  }
}

///|
fn graph_json_text_property_key_id_to_string(text : String) -> String {
  if text == "" {
    return text
  }
  if graph_json_text_property_key_is_keyword(text) {
    return "^" + text
  }
  text
}

///|
fn graph_json_text_property_key_unquote_if_necessary(text : String) -> String {
  if text.length() >= 2 &&
    (
      (text.has_prefix("\"") && text.has_suffix("\"")) ||
      (text.has_prefix("'") && text.has_suffix("'"))
    ) {
    text.unsafe_substring(start=1, end=text.length() - 1)
  } else {
    text
  }
}

///|
pub fn GraphJsonTextPropertyKeyValueConverter::to_string(
  self : GraphJsonTextPropertyKeyValueConverter,
  value : GraphJsonTextPropertyKey?,
) -> String {
  ignore(self.id_rule)
  match value {
    None => {
      try
        graph_json_text_property_key_value_converter_raise_unit(
          "IProperty value may not be null.",
        )
      catch {
        GraphJsonTextPropertyKeyValueConverterException(message) =>
          @core.layout_runtime_report_unsupported_configuration(
            "org.eclipse.elk.graph.json.text.conversion.PropertyKeyValueConverter: " +
            message,
          )
      } noraise {
        _ => ()
      }
      ""
    }
    Some(key) => {
      let id = graph_json_text_property_key_id(key)
      let split = graph_json_text_split_dotted_segments(id)
      let mut suffix : String? = None
      let mut i = split.length() - 1
      while i >= 0 {
        let encoded = graph_json_text_property_key_id_to_string(split[i])
        suffix = match suffix {
          None => Some(encoded)
          Some(current) => Some(encoded + "." + current)
        }
        let maybe_suffix = match suffix {
          Some(current) => current
          None => ""
        }
        match
          @core.layout_meta_data_service_get_option_data_by_suffix(maybe_suffix) {
          Some(known_option) =>
            if known_option.get_group() == "" ||
              maybe_suffix.contains(known_option.get_group()) {
              return maybe_suffix
            }
          None => ()
        }
        i -= 1
      }
      let encoded_segments : Array[String] = []
      for segment in split {
        encoded_segments.push(
          graph_json_text_property_key_id_to_string(segment),
        )
      }
      graph_json_text_join_dotted_segments(encoded_segments)
    }
  }
}

///|
pub fn GraphJsonTextPropertyKeyValueConverter::to_value(
  self : GraphJsonTextPropertyKeyValueConverter,
  text : String,
) -> GraphJsonTextPropertyKey {
  ignore(self.id_rule)
  if text == "" {
    try
      graph_json_text_property_key_value_converter_raise_unit(
        "Cannot convert empty string to a property identifier.",
      )
    catch {
      GraphJsonTextPropertyKeyValueConverterException(message) =>
        @core.layout_runtime_report_unsupported_configuration(
          "org.eclipse.elk.graph.json.text.conversion.PropertyKeyValueConverter: " +
          message,
        )
    } noraise {
      _ => ()
    }
    return GraphJsonTextCustomProperty("")
  }
  let normalized = graph_json_text_property_key_unquote_if_necessary(text)
  let decoded_segments : Array[String] = []
  for segment in graph_json_text_split_dotted_segments(normalized) {
    decoded_segments.push(graph_json_text_property_key_id_to_value(segment))
  }
  let id_suffix = graph_json_text_join_dotted_segments(decoded_segments)
  match @core.layout_meta_data_service_get_option_data_by_suffix(id_suffix) {
    Some(option_data) => GraphJsonTextLayoutOption(option_data)
    None => GraphJsonTextCustomProperty(id_suffix)
  }
}
