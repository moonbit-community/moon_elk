///|
pub(all) struct MetaDataSyntacticSequencer {
  grammar_access : MetaDataGrammarAccess
  match_md_bundle___bundle_keyword_1_0_left_curly_bracket_keyword_1_1_right_curly_bracket_keyword_1_3__q : String
  match_x_block_expression_semicolon_keyword_2_1_q : String
  match_x_expression_in_closure_semicolon_keyword_1_1_q : String
  match_x_function_type_ref___left_parenthesis_keyword_0_0_right_parenthesis_keyword_0_2__q : String
  match_x_import_declaration_semicolon_keyword_2_q : String
  match_x_parenthesized_expression_left_parenthesis_keyword_0_a : String
  match_x_parenthesized_expression_left_parenthesis_keyword_0_p : String
}

///|
pub fn new_meta_data_syntactic_sequencer(
  grammar_access? : MetaDataGrammarAccess = new_meta_data_grammar_access(),
) -> MetaDataSyntacticSequencer {
  {
    grammar_access,
    match_md_bundle___bundle_keyword_1_0_left_curly_bracket_keyword_1_1_right_curly_bracket_keyword_1_3__q: "MdBundle___BundleKeyword_1_0_LeftCurlyBracketKeyword_1_1_RightCurlyBracketKeyword_1_3__q",
    match_x_block_expression_semicolon_keyword_2_1_q: "XBlockExpression_SemicolonKeyword_2_1_q",
    match_x_expression_in_closure_semicolon_keyword_1_1_q: "XExpressionInClosure_SemicolonKeyword_1_1_q",
    match_x_function_type_ref___left_parenthesis_keyword_0_0_right_parenthesis_keyword_0_2__q: "XFunctionTypeRef___LeftParenthesisKeyword_0_0_RightParenthesisKeyword_0_2__q",
    match_x_import_declaration_semicolon_keyword_2_q: "XImportDeclaration_SemicolonKeyword_2_q",
    match_x_parenthesized_expression_left_parenthesis_keyword_0_a: "XParenthesizedExpression_LeftParenthesisKeyword_0_a",
    match_x_parenthesized_expression_left_parenthesis_keyword_0_p: "XParenthesizedExpression_LeftParenthesisKeyword_0_p",
  }
}

///|
pub fn MetaDataSyntacticSequencer::get_grammar_access(
  self : MetaDataSyntacticSequencer,
) -> MetaDataGrammarAccess {
  self.grammar_access
}

///|
pub fn MetaDataSyntacticSequencer::get_unassigned_rule_call_token(
  self : MetaDataSyntacticSequencer,
  _semantic_object : String,
  rule_call : String,
  _node : String,
) -> String {
  ignore(self)
  if rule_call == "ArrayBrackets" {
    "[]"
  } else if rule_call == "OpSingleAssign" {
    "="
  } else {
    ""
  }
}

///|
pub fn MetaDataSyntacticSequencer::emit_unassigned_tokens(
  self : MetaDataSyntacticSequencer,
  _semantic_object : String,
  ambiguous_syntaxes : Array[String],
) -> Array[String] {
  let accepted : Array[String] = []
  for syntax in ambiguous_syntaxes {
    if syntax ==
      self.match_md_bundle___bundle_keyword_1_0_left_curly_bracket_keyword_1_1_right_curly_bracket_keyword_1_3__q {
      accepted.push("bundle{}")
    } else if syntax == self.match_x_block_expression_semicolon_keyword_2_1_q {
      accepted.push(";")
    } else if syntax ==
      self.match_x_expression_in_closure_semicolon_keyword_1_1_q {
      accepted.push(";")
    } else if syntax ==
      self.match_x_function_type_ref___left_parenthesis_keyword_0_0_right_parenthesis_keyword_0_2__q {
      accepted.push("()")
    } else if syntax == self.match_x_import_declaration_semicolon_keyword_2_q {
      accepted.push(";")
    } else if syntax ==
      self.match_x_parenthesized_expression_left_parenthesis_keyword_0_a {
      accepted.push("(")
    } else if syntax ==
      self.match_x_parenthesized_expression_left_parenthesis_keyword_0_p {
      accepted.push("(")
    } else {
      accepted.push(syntax)
    }
  }
  accepted
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_md_bundle___bundle_keyword_1_0_left_curly_bracket_keyword_1_1_right_curly_bracket_keyword_1_3__q(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "bundle{}"
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_block_expression_semicolon_keyword_2_1_q(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ";"
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_expression_in_closure_semicolon_keyword_1_1_q(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ";"
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_function_type_ref___left_parenthesis_keyword_0_0_right_parenthesis_keyword_0_2__q(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "()"
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_import_declaration_semicolon_keyword_2_q(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ";"
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_parenthesized_expression_left_parenthesis_keyword_0_a(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "("
}

///|
pub fn[A, B, C] MetaDataSyntacticSequencer::emit_x_parenthesized_expression_left_parenthesis_keyword_0_p(
  self : MetaDataSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "("
}
