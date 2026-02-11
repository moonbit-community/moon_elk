///|
pub struct CoreMetaNameMappings {
  mappings : Map[String, String]
}

///|
pub fn new_core_meta_name_mappings(
  grammar_access : MetaDataGrammarAccess,
) -> CoreMetaNameMappings {
  ignore(grammar_access)
  let mappings : Map[String, String] = {}
  mappings["MdModel.Group"] = "rule__MdModel__Group__0"
  mappings["MdBundle.Group"] = "rule__MdBundle__Group__0"
  mappings["MdOption.Group"] = "rule__MdOption__Group__0"
  mappings["MdAlgorithm.Group"] = "rule__MdAlgorithm__Group__0"
  mappings["MdCategory.Group"] = "rule__MdCategory__Group__0"
  mappings["MdOptionDependency.Group"] = "rule__MdOptionDependency__Group__0"
  mappings["MdOptionSupport.Group"] = "rule__MdOptionSupport__Group__0"
  { mappings, }
}

///|
pub fn CoreMetaNameMappings::get_rule_name(
  self : CoreMetaNameMappings,
  element_key : String,
) -> String? {
  self.mappings.get(element_key)
}

///|
pub struct MetaDataParser {
  mut name_mappings : CoreMetaNameMappings
  mut grammar_access : MetaDataGrammarAccess
  mut initial_hidden_tokens : Array[String]
}

///|
pub fn new_meta_data_parser(
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> MetaDataParser {
  {
    name_mappings: new_core_meta_name_mappings(grammar_access),
    grammar_access,
    initial_hidden_tokens: ["RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT"],
  }
}

///|
pub fn MetaDataParser::create_parser(
  self : MetaDataParser,
  tokens : Array[CoreMetaLexToken],
) -> InternalMetaDataParser {
  new_internal_meta_data_parser(tokens, grammar_access=self.grammar_access)
}

///|
pub fn MetaDataParser::get_rule_name(
  self : MetaDataParser,
  element_key : String,
) -> String? {
  self.name_mappings.get_rule_name(element_key)
}

///|
pub fn MetaDataParser::get_initial_hidden_tokens(
  self : MetaDataParser,
) -> Array[String] {
  self.initial_hidden_tokens
}

///|
pub fn MetaDataParser::set_initial_hidden_tokens(
  self : MetaDataParser,
  hidden_tokens : Array[String],
) -> Unit {
  self.initial_hidden_tokens = hidden_tokens
}

///|
pub fn MetaDataParser::get_default_rule_name(self : MetaDataParser) -> String {
  ignore(self)
  "MdModel"
}

///|
pub fn MetaDataParser::get_grammar_access(
  self : MetaDataParser,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
pub fn MetaDataParser::set_grammar_access(
  self : MetaDataParser,
  grammar_access : MetaDataGrammarAccess,
) -> Unit {
  self.grammar_access = grammar_access
}

///|
pub fn MetaDataParser::get_name_mappings(
  self : MetaDataParser,
) -> CoreMetaNameMappings {
  self.name_mappings
}

///|
pub fn MetaDataParser::set_name_mappings(
  self : MetaDataParser,
  name_mappings : CoreMetaNameMappings,
) -> Unit {
  self.name_mappings = name_mappings
}

///|
pub fn MetaDataParser::parse(
  self : MetaDataParser,
  input : String,
) -> CoreMetaMdModel {
  let lexer = new_internal_meta_data_lexer(input)
  let parser = self.create_parser(lexer.lex_all())
  parser.entry_rule_md_model()
}
