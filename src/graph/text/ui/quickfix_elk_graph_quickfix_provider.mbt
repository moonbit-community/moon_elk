///|
pub struct ElkGraphQuickfixProvider {
  unit : Unit
}

///|
pub fn new_elk_graph_quickfix_provider() -> ElkGraphQuickfixProvider {
  { unit: () }
}

///|
pub fn ElkGraphQuickfixProvider::supports_issue(
  self : ElkGraphQuickfixProvider,
  issue_code : String,
) -> Bool {
  ignore(self)
  issue_code == @text.graph_text_option_not_applicable
}

///|
pub fn ElkGraphQuickfixProvider::remove_option(
  self : ElkGraphQuickfixProvider,
  properties : Array[@text.GraphTextPropertyAssignment],
  index : Int,
) -> Array[@text.GraphTextPropertyAssignment] {
  ignore(self)
  if index < 0 || index >= properties.length() {
    return properties
  }
  let result : Array[@text.GraphTextPropertyAssignment] = []
  for i = 0; i < properties.length(); i = i + 1 {
    if i != index {
      result.push(properties[i])
    }
  }
  result
}
