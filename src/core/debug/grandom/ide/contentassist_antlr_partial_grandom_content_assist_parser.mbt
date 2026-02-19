///|
pub(all) struct PartialCoreDebugGRandomContentAssistParser {
  mut rule : String?
}

///|
pub fn new_partial_core_debug_grandom_content_assist_parser() -> PartialCoreDebugGRandomContentAssistParser {
  { rule: None }
}

///|
pub fn PartialCoreDebugGRandomContentAssistParser::initialize_for(
  self : PartialCoreDebugGRandomContentAssistParser,
  rule : String?,
) -> Unit {
  self.rule = rule
}

///|
pub fn PartialCoreDebugGRandomContentAssistParser::get_follow_elements(
  self : PartialCoreDebugGRandomContentAssistParser,
  parser : CoreDebugGRandomParser,
) -> Array[String] {
  ignore(parser)
  match self.rule {
    Some(rule_name) => ["entryRule" + rule_name]
    None => []
  }
}
