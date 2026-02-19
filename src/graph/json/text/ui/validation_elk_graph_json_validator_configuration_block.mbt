///|
pub struct ElkGraphJsonValidatorConfigurationBlock {
  provider : @text.ElkGraphJsonConfigurableIssueCodesProvider
}

///|
pub fn new_elk_graph_json_validator_configuration_block(
  provider? : @text.ElkGraphJsonConfigurableIssueCodesProvider = @text.new_elk_graph_json_configurable_issue_codes_provider(),
) -> ElkGraphJsonValidatorConfigurationBlock {
  { provider, }
}

///|
pub fn ElkGraphJsonValidatorConfigurationBlock::get_issue_code_prefix(
  self : ElkGraphJsonValidatorConfigurationBlock,
) -> String {
  self.provider.issue_code_prefix()
}
