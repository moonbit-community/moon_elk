///|
pub let core_meta_grammar_name : String = "org.eclipse.elk.core.meta.MetaData"

///|
pub(all) struct MetaDataGrammarAccess {
  grammar : String
  rules : Map[String, String]
}

///|
pub fn new_meta_data_grammar_access() -> MetaDataGrammarAccess {
  let rules : Map[String, String] = {}
  rules["MdModel"] = "('package' name=QualifiedName importSection=XImportSection? bundle=MdBundle)?"
  rules["MdBundle"] = "{MdBundle} ('bundle' '{' (('label' label=STRING)? & ('metadataClass' targetClass=QualifiedName)? & ('documentationFolder' documentationFolder=Path)? & ('idPrefix' idPrefix=QualifiedName)?) '}')? members+=MdBundleMember*"
  rules["MdBundleMember"] = "MdGroupOrOption | MdAlgorithm | MdCategory"
  rules["MdGroupOrOption"] = "MdGroup | MdOption"
  rules["MdGroup"] = "'group' name=ID '{' ('documentation' documentation=STRING)? children+=MdGroupOrOption* '}'"
  rules["MdOption"] = "deprecated? ('advanced'|'programmatic'|'output'|'global')? 'option' name=ID (':' type=JvmTypeReference)? '{' ... '}'"
  rules["MdOptionDependency"] = "'requires' target=[MdOption|QualifiedName] ('==' value=XExpression)?"
  rules["MdAlgorithm"] = "deprecated? 'algorithm' name=ID '(' provider=JvmTypeReference ('#' parameter=ID)? ')' '{' ... '}'"
  rules["MdCategory"] = "deprecated? 'category' name=ID '{' ... '}'"
  rules["MdOptionSupport"] = "'supports' option=[MdOption|QualifiedName] ('=' value=XExpression)? ('documentation' documentation=STRING)?"
  rules["Path"] = "QualifiedName (('/'|'-') QualifiedName)*"
  rules["MdOptionTargetType"] = "parents | nodes | edges | ports | labels"
  rules["MdGraphFeature"] = "self_loops | inside_self_loops | multi_edges | edge_labels | ports | compound | clusters | disconnected"
  rules["ArrayBrackets"] = "'[' ']'"
  rules["OpSingleAssign"] = "'='"
  { grammar: core_meta_grammar_name, rules }
}

///|
pub fn MetaDataGrammarAccess::get_grammar(
  self : MetaDataGrammarAccess,
) -> String {
  self.grammar
}

///|
pub fn MetaDataGrammarAccess::get_rule(
  self : MetaDataGrammarAccess,
  rule_name : String,
) -> String? {
  self.rules.get(rule_name)
}

///|
pub fn MetaDataGrammarAccess::get_rule_names(
  self : MetaDataGrammarAccess,
) -> Array[String] {
  let names : Array[String] = []
  for pair in self.rules.to_array() {
    names.push(pair.0)
  }
  names
}

///|
pub fn MetaDataGrammarAccess::get_md_model_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("MdModel") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_md_bundle_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("MdBundle") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_md_option_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("MdOption") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_md_algorithm_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("MdAlgorithm") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_md_category_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("MdCategory") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_array_brackets_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("ArrayBrackets") {
    Some(rule) => rule
    None => ""
  }
}

///|
pub fn MetaDataGrammarAccess::get_op_single_assign_rule(
  self : MetaDataGrammarAccess,
) -> String {
  match self.get_rule("OpSingleAssign") {
    Some(rule) => rule
    None => ""
  }
}
