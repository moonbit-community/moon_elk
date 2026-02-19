///|
pub let graph_json_text_issue_code_prefix : String = "org.eclipse.elk.graph.json.text."

///|
pub struct ElkGraphJsonConfigurableIssueCodesProvider {
  marker : Unit
}

///|
pub fn new_elk_graph_json_configurable_issue_codes_provider() -> ElkGraphJsonConfigurableIssueCodesProvider {
  { marker: () }
}

///|
pub fn ElkGraphJsonConfigurableIssueCodesProvider::issue_code_prefix(
  self : ElkGraphJsonConfigurableIssueCodesProvider,
) -> String {
  ignore(self)
  graph_json_text_issue_code_prefix
}

///|
pub fn ElkGraphJsonConfigurableIssueCodesProvider::deprecated_model_part(
  self : ElkGraphJsonConfigurableIssueCodesProvider,
) -> String {
  self.issue_code_prefix() + "deprecatedModelPart"
}
