///|
pub(all) struct InternalCoreMetaIdeLexer {
  delegate : @meta.InternalMetaDataLexer
}

///|
pub fn new_internal_core_meta_ide_lexer(
  input : String,
) -> InternalCoreMetaIdeLexer {
  { delegate: @meta.new_internal_meta_data_lexer(input) }
}

///|
pub fn InternalCoreMetaIdeLexer::get_grammar_file_name(
  self : InternalCoreMetaIdeLexer,
) -> String {
  self.delegate.get_grammar_file_name()
}

///|
pub fn InternalCoreMetaIdeLexer::get_token_names(
  self : InternalCoreMetaIdeLexer,
) -> Array[String] {
  self.delegate.get_token_names()
}

///|
pub fn InternalCoreMetaIdeLexer::lex_all(
  self : InternalCoreMetaIdeLexer,
) -> Array[@meta.CoreMetaLexToken] {
  self.delegate.lex_all()
}
