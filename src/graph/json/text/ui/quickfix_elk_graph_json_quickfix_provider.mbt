///|
pub struct ElkGraphJsonQuickfixProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_json_quickfix_provider() -> ElkGraphJsonQuickfixProvider {
  { unit: () }
}

///|
pub fn ElkGraphJsonQuickfixProvider::supports_issue(
  self : ElkGraphJsonQuickfixProvider,
  issue_code : String,
) -> Bool {
  ignore(self)
  issue_code == @text.graph_json_text_option_not_applicable ||
  issue_code ==
  @text.new_elk_graph_json_configurable_issue_codes_provider().deprecated_model_part()
}

///|
pub fn ElkGraphJsonQuickfixProvider::remove_option(
  self : ElkGraphJsonQuickfixProvider,
  properties : Array[@text.GraphJsonTextPropertyAssignment],
  index : Int,
) -> Array[@text.GraphJsonTextPropertyAssignment] {
  ignore(self)
  if index < 0 || index >= properties.length() {
    return properties
  }
  let result : Array[@text.GraphJsonTextPropertyAssignment] = []
  for i = 0; i < properties.length(); i = i + 1 {
    if i != index {
      result.push(properties[i])
    }
  }
  result
}
