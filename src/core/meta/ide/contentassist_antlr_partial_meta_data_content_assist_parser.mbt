///|
pub(all) struct PartialCoreMetaContentAssistParser {
  mut rule : String?
}

///|
pub fn new_partial_core_meta_content_assist_parser() -> PartialCoreMetaContentAssistParser {
  { rule: None }
}

///|
pub fn PartialCoreMetaContentAssistParser::initialize_for(
  self : PartialCoreMetaContentAssistParser,
  rule : String?,
) -> Unit {
  self.rule = rule
}

///|
pub fn PartialCoreMetaContentAssistParser::get_follow_elements(
  self : PartialCoreMetaContentAssistParser,
  parser : CoreMetaIdeParser,
) -> Array[String] {
  ignore(parser)
  match self.rule {
    Some(rule_name) => ["entryRule" + rule_name]
    None => []
  }
}
