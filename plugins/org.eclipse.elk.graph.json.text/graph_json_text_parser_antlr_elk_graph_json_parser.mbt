///|
pub struct ElkGraphJsonParser {
  mut grammar_access : ElkGraphJsonGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_elk_graph_json_parser(
  grammar_access? : ElkGraphJsonGrammarAccess = new_elk_graph_json_grammar_access(),
) -> ElkGraphJsonParser {
  {
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn ElkGraphJsonParser::set_initial_hidden_tokens(
  self : ElkGraphJsonParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn ElkGraphJsonParser::get_initial_hidden_tokens(
  self : ElkGraphJsonParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn ElkGraphJsonParser::create_parser(
  self : ElkGraphJsonParser,
  tokens : Array[ElkGraphJsonLexToken],
) -> InternalElkGraphJsonParser {
  new_internal_elk_graph_json_parser(
    tokens,
    grammar_access=self.get_grammar_access(),
  )
}

///|
pub fn ElkGraphJsonParser::get_default_rule_name(
  self : ElkGraphJsonParser,
) -> String {
  ignore(self)
  "ElkNode"
}

///|
pub fn ElkGraphJsonParser::get_grammar_access(
  self : ElkGraphJsonParser,
) -> ElkGraphJsonGrammarAccess {
  self.grammar_access
}

///|
pub fn ElkGraphJsonParser::set_grammar_access(
  self : ElkGraphJsonParser,
  grammar_access : ElkGraphJsonGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn ElkGraphJsonParser::parse(
  self : ElkGraphJsonParser,
  input : String,
) -> ElkNode {
  let lexer = new_internal_elk_graph_json_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_elk_node()
}
