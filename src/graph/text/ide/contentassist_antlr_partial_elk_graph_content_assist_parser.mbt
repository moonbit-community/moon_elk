///|
pub struct PartialElkGraphContentAssistParser {
  mut rule : String?
}

///|
pub fn new_partial_elk_graph_content_assist_parser() -> PartialElkGraphContentAssistParser {
  { rule: None }
}

///|
pub fn PartialElkGraphContentAssistParser::initialize_for(
  self : PartialElkGraphContentAssistParser,
  rule : String?,
) -> Unit {
  self.rule = rule
}

///|
pub fn PartialElkGraphContentAssistParser::get_follow_elements(
  self : PartialElkGraphContentAssistParser,
  parser : ElkGraphIdeParser,
) -> Array[String] {
  ignore(parser)
  match self.rule {
    Some(rule_name) => ["entryRule" + rule_name]
    None => []
  }
}
