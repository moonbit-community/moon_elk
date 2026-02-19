///|
pub struct ElkGraphParser {
  mut grammar_access : ElkGraphGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_elk_graph_parser(
  grammar_access? : ElkGraphGrammarAccess = new_elk_graph_grammar_access(),
) -> ElkGraphParser {
  {
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn ElkGraphParser::set_initial_hidden_tokens(
  self : ElkGraphParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn ElkGraphParser::get_initial_hidden_tokens(
  self : ElkGraphParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn ElkGraphParser::create_parser(
  self : ElkGraphParser,
  tokens : Array[ElkGraphLexToken],
) -> InternalElkGraphParser {
  new_internal_elk_graph_parser(
    tokens,
    grammar_access=self.get_grammar_access(),
  )
}

///|
pub fn ElkGraphParser::get_default_rule_name(self : ElkGraphParser) -> String {
  ignore(self)
  "RootNode"
}

///|
pub fn ElkGraphParser::get_grammar_access(
  self : ElkGraphParser,
) -> ElkGraphGrammarAccess {
  self.grammar_access
}

///|
pub fn ElkGraphParser::set_grammar_access(
  self : ElkGraphParser,
  grammar_access : ElkGraphGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn ElkGraphParser::parse(self : ElkGraphParser, input : String) -> ElkNode {
  let lexer = new_internal_elk_graph_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_root_node()
}
