///|
pub struct ElkGraphSemanticSequencer {
  base : AbstractElkGraphSemanticSequencer
  value_converter : PropertyValueValueConverter
}

///|
pub fn new_elk_graph_semantic_sequencer(
  base? : AbstractElkGraphSemanticSequencer = new_abstract_elk_graph_semantic_sequencer(),
  value_converter? : PropertyValueValueConverter = new_property_value_value_converter(),
) -> ElkGraphSemanticSequencer {
  { base, value_converter }
}

///|
fn graph_text_semantic_is_quoting_necessary(text : String) -> Bool {
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
pub fn ElkGraphSemanticSequencer::sequence_property(
  self : ElkGraphSemanticSequencer,
  context : String,
  semantic_object : GraphTextPropertyAssignment,
) -> GraphTextPropertyAssignment {
  let option = graph_text_property_key_to_layout_option(semantic_object.key)
  let resolved = match semantic_object.value {
    ProxyValue(proxy_text) =>
      match option {
        Some(option_data) =>
          self.value_converter.to_value(
            proxy_text,
            property_key=Some(LayoutOption(option_data)),
          )
        None => semantic_object.value
      }
    _ => semantic_object.value
  }
  let rendered = self.value_converter.to_string(resolved)
  let final_value = match resolved {
    StringValue(text) =>
      if graph_text_semantic_is_quoting_necessary(text) &&
        !rendered.has_prefix("\"") {
        StringValue("\"" + text + "\"")
      } else {
        resolved
      }
    _ => resolved
  }
  self.base.sequence_property(
    context,
    new_graph_text_property_assignment(semantic_object.key, final_value),
  )
}

///|
pub fn[T] ElkGraphSemanticSequencer::sequence(
  self : ElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.base.sequence(context, semantic_object)
}
