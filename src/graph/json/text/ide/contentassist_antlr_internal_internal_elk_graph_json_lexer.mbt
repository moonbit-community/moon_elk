///|
pub struct InternalElkGraphJsonIdeLexer {
  delegate : @text.InternalElkGraphJsonLexer
}

///|
pub fn new_internal_elk_graph_json_ide_lexer(
  input : String,
) -> InternalElkGraphJsonIdeLexer {
  { delegate: @text.new_internal_elk_graph_json_lexer(input) }
}

///|
pub fn InternalElkGraphJsonIdeLexer::get_grammar_file_name(
  self : InternalElkGraphJsonIdeLexer,
) -> String {
  self.delegate.get_grammar_file_name()
}

///|
pub fn InternalElkGraphJsonIdeLexer::get_token_names(
  self : InternalElkGraphJsonIdeLexer,
) -> Array[String] {
  self.delegate.get_token_names()
}

///|
pub fn InternalElkGraphJsonIdeLexer::lex_all(
  self : InternalElkGraphJsonIdeLexer,
) -> Array[@text.ElkGraphJsonLexToken] {
  self.delegate.lex_all()
}
