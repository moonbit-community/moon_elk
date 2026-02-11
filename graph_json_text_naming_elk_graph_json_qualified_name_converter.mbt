///|
pub let elk_graph_json_qualified_name_converter_delimiter : Char = '.'

///|
pub struct ElkGraphJsonQualifiedNameConverter {
  mut id_rule : String
}

///|
pub fn new_elk_graph_json_qualified_name_converter() -> ElkGraphJsonQualifiedNameConverter {
  { id_rule: "ID" }
}

///|
pub fn ElkGraphJsonQualifiedNameConverter::initialize(
  self : ElkGraphJsonQualifiedNameConverter,
  grammar_access : ElkGraphJsonGrammarAccess,
) -> Unit {
  self.id_rule = grammar_access.get_id_rule()
}

///|
fn graph_json_text_is_keyword_for_id(text : String) -> Bool {
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
fn graph_json_text_is_id_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn graph_json_text_is_id_part(ch : Char) -> Bool {
  graph_json_text_is_id_start(ch) || (ch >= '0' && ch <= '9')
}

///|
fn graph_json_text_id_to_value(text : String) -> String {
  if text.length() > 0 && text.has_prefix("^") {
    text.unsafe_substring(start=1, end=text.length())
  } else {
    text
  }
}

///|
fn graph_json_text_id_to_string(text : String) -> String {
  if text == "" {
    return text
  }
  if graph_json_text_is_keyword_for_id(text) {
    return "^" + text
  }
  let first = text[0].unsafe_to_char()
  if !graph_json_text_is_id_start(first) {
    return "^" + text
  }
  let mut idx = 1
  while idx < text.length() {
    if !graph_json_text_is_id_part(text[idx].unsafe_to_char()) {
      return "^" + text
    }
    idx += 1
  }
  text
}

///|
pub fn ElkGraphJsonQualifiedNameConverter::to_qualified_name(
  self : ElkGraphJsonQualifiedNameConverter,
  qualified_name_as_text : String,
) -> Array[String] {
  ignore(self.id_rule)
  if qualified_name_as_text == "" {
    abort("Qualified name cannot be empty")
  }
  let parts : Array[String] = []
  let mut current = ""
  let mut idx = 0
  while idx < qualified_name_as_text.length() {
    let ch = qualified_name_as_text[idx].unsafe_to_char()
    if ch == elk_graph_json_qualified_name_converter_delimiter {
      parts.push(graph_json_text_id_to_value(current))
      current = ""
    } else {
      current += ch.to_string()
    }
    idx += 1
  }
  parts.push(graph_json_text_id_to_value(current))
  parts
}

///|
pub fn ElkGraphJsonQualifiedNameConverter::to_string(
  self : ElkGraphJsonQualifiedNameConverter,
  name : Array[String],
) -> String {
  ignore(self.id_rule)
  if name.length() == 0 {
    abort("Qualified name cannot be empty")
  }
  let parts : Array[String] = []
  for segment in name {
    parts.push(graph_json_text_id_to_string(segment))
  }
  parts.join(".")
}
