///|
pub(all) struct InternalCoreMetaIdeParser {
  tokens : Array[@meta.CoreMetaLexToken]
  grammar_access : @meta.MetaDataGrammarAccess
}

///|
pub fn new_internal_core_meta_ide_parser(
  tokens : Array[@meta.CoreMetaLexToken],
  grammar_access? : @meta.MetaDataGrammarAccess = @meta.new_meta_data_grammar_access(),
) -> InternalCoreMetaIdeParser {
  { tokens, grammar_access }
}

///|
pub fn InternalCoreMetaIdeParser::get_token_names(
  self : InternalCoreMetaIdeParser,
) -> Array[String] {
  ignore(self)
  @meta.new_internal_meta_data_lexer("").get_token_names()
}

///|
pub fn InternalCoreMetaIdeParser::get_grammar_file_name(
  self : InternalCoreMetaIdeParser,
) -> String {
  ignore(self)
  "InternalMetaData.g"
}

///|
pub fn InternalCoreMetaIdeParser::get_first_rule_name(
  self : InternalCoreMetaIdeParser,
) -> String {
  ignore(self)
  "MdModel"
}

///|
pub fn InternalCoreMetaIdeParser::get_grammar_access(
  self : InternalCoreMetaIdeParser,
) -> @meta.MetaDataGrammarAccess {
  self.grammar_access
}

///|
pub fn InternalCoreMetaIdeParser::entry_rule_md_model(
  self : InternalCoreMetaIdeParser,
) -> @meta.CoreMetaMdModel {
  @meta.new_internal_meta_data_parser(
    self.tokens,
    grammar_access=self.grammar_access,
  ).entry_rule_md_model()
}

///|
pub fn InternalCoreMetaIdeParser::get_follow_elements(
  self : InternalCoreMetaIdeParser,
) -> Array[String] {
  ignore(self)
  []
}
