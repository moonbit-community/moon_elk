///|
pub struct PropertyKeyValueConverter {
  mut id_rule : String
}

///|
pub fn new_property_key_value_converter() -> PropertyKeyValueConverter {
  { id_rule: "ID" }
}

///|
pub fn PropertyKeyValueConverter::initialize(
  self : PropertyKeyValueConverter,
  grammar_access : ElkGraphGrammarAccess,
) -> Unit {
  self.id_rule = grammar_access.get_id_rule()
}

///|
fn graph_text_split_dotted_segments(text : String) -> Array[String] {
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
fn graph_text_join_dotted_segments(segments : Array[String]) -> String {
  segments.join(".")
}

///|
fn graph_text_property_key_is_keyword(text : String) -> Bool {
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
fn graph_text_property_key_id_to_value(text : String) -> String {
  if text.length() > 0 && text.has_prefix("^") {
    text.unsafe_substring(start=1, end=text.length())
  } else {
    text
  }
}

///|
fn graph_text_property_key_id_to_string(text : String) -> String {
  if text == "" {
    return text
  }
  if graph_text_property_key_is_keyword(text) {
    return "^" + text
  }
  text
}

///|
pub fn PropertyKeyValueConverter::to_string(
  self : PropertyKeyValueConverter,
  value : GraphTextPropertyKey?,
) -> String {
  ignore(self.id_rule)
  match value {
    None => abort("IProperty value may not be null.")
    Some(key) => {
      let id = graph_text_property_key_id(key)
      let split = graph_text_split_dotted_segments(id)
      let mut suffix : String? = None
      let mut i = split.length() - 1
      while i >= 0 {
        let encoded = graph_text_property_key_id_to_string(split[i])
        suffix = match suffix {
          None => Some(encoded)
          Some(current) => Some(encoded + "." + current)
        }
        let maybe_suffix = match suffix {
          Some(current) => current
          None => ""
        }
        match layout_meta_data_service_get_option_data_by_suffix(maybe_suffix) {
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
        encoded_segments.push(graph_text_property_key_id_to_string(segment))
      }
      graph_text_join_dotted_segments(encoded_segments)
    }
  }
}

///|
pub fn PropertyKeyValueConverter::to_value(
  self : PropertyKeyValueConverter,
  text : String,
) -> GraphTextPropertyKey {
  ignore(self.id_rule)
  if text == "" {
    abort("Cannot convert empty string to a property identifier.")
  }
  let decoded_segments : Array[String] = []
  for segment in graph_text_split_dotted_segments(text) {
    decoded_segments.push(graph_text_property_key_id_to_value(segment))
  }
  let id_suffix = graph_text_join_dotted_segments(decoded_segments)
  match layout_meta_data_service_get_option_data_by_suffix(id_suffix) {
    Some(option_data) => LayoutOption(option_data)
    None => CustomProperty(text)
  }
}
