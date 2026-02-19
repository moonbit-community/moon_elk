///|
pub struct ElkGraphJsonValidatorConfigurationBlock {
  provider : ElkGraphJsonConfigurableIssueCodesProvider
}

///|
pub fn new_elk_graph_json_validator_configuration_block(
  provider? : ElkGraphJsonConfigurableIssueCodesProvider = new_elk_graph_json_configurable_issue_codes_provider(),
) -> ElkGraphJsonValidatorConfigurationBlock {
  { provider, }
}

///|
pub fn ElkGraphJsonValidatorConfigurationBlock::get_issue_code_prefix(
  self : ElkGraphJsonValidatorConfigurationBlock,
) -> String {
  self.provider.issue_code_prefix()
}
