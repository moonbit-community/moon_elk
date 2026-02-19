///|
pub struct InternalElkGraphJsonIdeParser {
  tokens : Array[ElkGraphJsonLexToken]
  grammar_access : ElkGraphJsonGrammarAccess
}

///|
pub fn new_internal_elk_graph_json_ide_parser(
  tokens : Array[ElkGraphJsonLexToken],
  grammar_access? : ElkGraphJsonGrammarAccess = new_elk_graph_json_grammar_access(),
) -> InternalElkGraphJsonIdeParser {
  { tokens, grammar_access }
}

///|
pub fn InternalElkGraphJsonIdeParser::get_token_names(
  self : InternalElkGraphJsonIdeParser,
) -> Array[String] {
  ignore(self)
  new_internal_elk_graph_json_lexer("").get_token_names()
}

///|
pub fn InternalElkGraphJsonIdeParser::get_grammar_file_name(
  self : InternalElkGraphJsonIdeParser,
) -> String {
  ignore(self)
  "InternalElkGraphJson.g"
}

///|
pub fn InternalElkGraphJsonIdeParser::get_first_rule_name(
  self : InternalElkGraphJsonIdeParser,
) -> String {
  ignore(self)
  "ElkNode"
}

///|
pub fn InternalElkGraphJsonIdeParser::get_grammar_access(
  self : InternalElkGraphJsonIdeParser,
) -> ElkGraphJsonGrammarAccess {
  self.grammar_access
}

///|
pub fn InternalElkGraphJsonIdeParser::entry_rule_root_node(
  self : InternalElkGraphJsonIdeParser,
) -> ElkNode {
  new_internal_elk_graph_json_parser(
    self.tokens,
    grammar_access=self.grammar_access,
  ).entry_rule_elk_node()
}

///|
pub fn InternalElkGraphJsonIdeParser::entry_rule_elk_node(
  self : InternalElkGraphJsonIdeParser,
) -> ElkNode {
  self.entry_rule_root_node()
}

///|
pub fn InternalElkGraphJsonIdeParser::get_follow_elements(
  self : InternalElkGraphJsonIdeParser,
) -> Array[String] {
  ignore(self)
  []
}
