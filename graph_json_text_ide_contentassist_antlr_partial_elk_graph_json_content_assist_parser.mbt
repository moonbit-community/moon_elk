///|
pub struct PartialElkGraphJsonContentAssistParser {
  mut rule : String?
}

///|
pub fn new_partial_elk_graph_json_content_assist_parser() -> PartialElkGraphJsonContentAssistParser {
  { rule: None }
}

///|
pub fn PartialElkGraphJsonContentAssistParser::initialize_for(
  self : PartialElkGraphJsonContentAssistParser,
  rule : String?,
) -> Unit {
  self.rule = rule
}

///|
pub fn PartialElkGraphJsonContentAssistParser::get_follow_elements(
  self : PartialElkGraphJsonContentAssistParser,
  parser : ElkGraphJsonIdeParser,
) -> Array[String] {
  ignore(parser)
  match self.rule {
    Some(rule_name) => ["entryRule" + rule_name]
    None => []
  }
}
