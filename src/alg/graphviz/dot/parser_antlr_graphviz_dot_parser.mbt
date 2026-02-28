///|
pub struct GraphvizDotParser {
  mut grammar_access : GraphvizDotGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_graphviz_dot_parser(
  grammar_access? : GraphvizDotGrammarAccess = new_graphviz_dot_grammar_access(),
) -> GraphvizDotParser {
  {
    grammar_access,
    initial_hidden_tokens: [
      "RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT", "RULE_PREC_LINE",
    ],
  }
}

///|
pub fn GraphvizDotParser::set_initial_hidden_tokens(
  self : GraphvizDotParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn GraphvizDotParser::get_initial_hidden_tokens(
  self : GraphvizDotParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn GraphvizDotParser::create_parser(
  self : GraphvizDotParser,
  tokens : Array[GraphvizDotLexToken],
) -> InternalGraphvizDotParser {
  new_internal_graphviz_dot_parser(
    tokens,
    grammar_access=self.get_grammar_access(),
  )
}

///|
pub fn GraphvizDotParser::get_default_rule_name(
  self : GraphvizDotParser,
) -> String {
  ignore(self)
  "GraphvizModel"
}

///|
pub fn GraphvizDotParser::get_grammar_access(
  self : GraphvizDotParser,
) -> GraphvizDotGrammarAccess {
  self.grammar_access
}

///|
pub fn GraphvizDotParser::set_grammar_access(
  self : GraphvizDotParser,
  grammar_access : GraphvizDotGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn GraphvizDotParser::parse(
  self : GraphvizDotParser,
  input : String,
) -> DotGraphvizModel {
  let lexer = new_internal_graphviz_dot_lexer(input)
  let tokens = lexer.lex_all()
  let parser = self.create_parser(tokens)
  parser.entry_rule_graphviz_model()
}
