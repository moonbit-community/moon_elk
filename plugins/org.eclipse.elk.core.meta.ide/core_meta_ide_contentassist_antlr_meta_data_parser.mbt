///|
pub struct CoreMetaIdeNameMappings {
  mappings : Map[String, String]
}

///|
pub fn new_core_meta_ide_name_mappings(
  grammar_access : MetaDataGrammarAccess,
) -> CoreMetaIdeNameMappings {
  ignore(grammar_access)
  let mappings : Map[String, String] = {}
  mappings["MdBundleMember.Alternatives"] = "rule__MdBundleMember__Alternatives"
  mappings["MdGroupOrOption.Alternatives"] = "rule__MdGroupOrOption__Alternatives"
  mappings["MdOption.Alternatives_1"] = "rule__MdOption__Alternatives_1"
  mappings["Path.Alternatives_1_0"] = "rule__Path__Alternatives_1_0"
  mappings["MdModel.Group"] = "rule__MdModel__Group__0"
  mappings["MdBundle.Group"] = "rule__MdBundle__Group__0"
  mappings["MdOption.Group"] = "rule__MdOption__Group__0"
  mappings["MdAlgorithm.Group"] = "rule__MdAlgorithm__Group__0"
  mappings["MdCategory.Group"] = "rule__MdCategory__Group__0"
  { mappings, }
}

///|
pub fn CoreMetaIdeNameMappings::get_rule_name(
  self : CoreMetaIdeNameMappings,
  element_key : String,
) -> String? {
  self.mappings.get(element_key)
}

///|
pub struct CoreMetaIdeParser {
  mut name_mappings : CoreMetaIdeNameMappings
  mut grammar_access : MetaDataGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_core_meta_ide_parser(
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> CoreMetaIdeParser {
  {
    name_mappings: new_core_meta_ide_name_mappings(grammar_access),
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn CoreMetaIdeParser::create_parser(
  self : CoreMetaIdeParser,
  tokens : Array[CoreMetaLexToken],
) -> InternalCoreMetaIdeParser {
  new_internal_core_meta_ide_parser(tokens, grammar_access=self.grammar_access)
}

///|
pub fn CoreMetaIdeParser::get_rule_name(
  self : CoreMetaIdeParser,
  element_key : String,
) -> String? {
  self.name_mappings.get_rule_name(element_key)
}

///|
pub fn CoreMetaIdeParser::get_initial_hidden_tokens(
  self : CoreMetaIdeParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn CoreMetaIdeParser::set_initial_hidden_tokens(
  self : CoreMetaIdeParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn CoreMetaIdeParser::get_grammar_access(
  self : CoreMetaIdeParser,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
pub fn CoreMetaIdeParser::set_grammar_access(
  self : CoreMetaIdeParser,
  grammar_access : MetaDataGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn CoreMetaIdeParser::get_name_mappings(
  self : CoreMetaIdeParser,
) -> CoreMetaIdeNameMappings {
  self.name_mappings
}

///|
pub fn CoreMetaIdeParser::set_name_mappings(
  self : CoreMetaIdeParser,
  name_mappings : CoreMetaIdeNameMappings,
) -> Unit {
  self.name_mappings = name_mappings
}

///|
pub fn CoreMetaIdeParser::parse(
  self : CoreMetaIdeParser,
  input : String,
) -> CoreMetaMdModel {
  let lexer = new_internal_core_meta_ide_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_md_model()
}
