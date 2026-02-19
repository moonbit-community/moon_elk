///|
pub struct InternalElkGraphIdeParser {
  tokens : Array[@text.ElkGraphLexToken]
  grammar_access : @text.ElkGraphGrammarAccess
}

///|
pub fn new_internal_elk_graph_ide_parser(
  tokens : Array[@text.ElkGraphLexToken],
  grammar_access? : @text.ElkGraphGrammarAccess = @text.new_elk_graph_grammar_access(),
) -> InternalElkGraphIdeParser {
  { tokens, grammar_access }
}

///|
pub fn InternalElkGraphIdeParser::get_token_names(
  self : InternalElkGraphIdeParser,
) -> Array[String] {
  ignore(self)
  @text.new_internal_elk_graph_lexer("").get_token_names()
}

///|
pub fn InternalElkGraphIdeParser::get_grammar_file_name(
  self : InternalElkGraphIdeParser,
) -> String {
  ignore(self)
  "InternalElkGraph.g"
}

///|
pub fn InternalElkGraphIdeParser::get_first_rule_name(
  self : InternalElkGraphIdeParser,
) -> String {
  ignore(self)
  "RootNode"
}

///|
pub fn InternalElkGraphIdeParser::get_grammar_access(
  self : InternalElkGraphIdeParser,
) -> @text.ElkGraphGrammarAccess {
  self.grammar_access
}

///|
pub fn InternalElkGraphIdeParser::entry_rule_root_node(
  self : InternalElkGraphIdeParser,
) -> @graph.ElkNode {
  @text.new_internal_elk_graph_parser(self.tokens, grammar_access=self.grammar_access).entry_rule_root_node()
}

///|
pub fn InternalElkGraphIdeParser::get_follow_elements(
  self : InternalElkGraphIdeParser,
) -> Array[String] {
  ignore(self)
  []
}
