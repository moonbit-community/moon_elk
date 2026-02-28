///|
pub struct InternalElkGraphIdeLexer {
  delegate : @text.InternalElkGraphLexer
}

///|
pub fn new_internal_elk_graph_ide_lexer(
  input : String,
) -> InternalElkGraphIdeLexer {
  { delegate: @text.new_internal_elk_graph_lexer(input) }
}

///|
pub fn InternalElkGraphIdeLexer::get_grammar_file_name(
  self : InternalElkGraphIdeLexer,
) -> String {
  self.delegate.get_grammar_file_name()
}

///|
pub fn InternalElkGraphIdeLexer::get_token_names(
  self : InternalElkGraphIdeLexer,
) -> Array[String] {
  self.delegate.get_token_names()
}

///|
pub fn InternalElkGraphIdeLexer::lex_all(
  self : InternalElkGraphIdeLexer,
) -> Array[@text.ElkGraphLexToken] {
  self.delegate.lex_all()
}
