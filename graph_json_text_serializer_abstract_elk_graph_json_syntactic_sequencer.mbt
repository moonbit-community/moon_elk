///|
pub struct AbstractElkGraphJsonSyntacticSequencer {
  grammar_access : ElkGraphJsonGrammarAccess
  match_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q : String
}

///|
pub fn new_abstract_elk_graph_json_syntactic_sequencer(
  grammar_access? : ElkGraphJsonGrammarAccess = new_elk_graph_json_grammar_access(),
) -> AbstractElkGraphJsonSyntacticSequencer {
  {
    grammar_access,
    match_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q: "JsonObject___LeftCurlyBracketKeyword_0_RightCurlyBracketKeyword_3__q",
  }
}

///|
pub fn AbstractElkGraphJsonSyntacticSequencer::get_grammar_access(
  self : AbstractElkGraphJsonSyntacticSequencer,
) -> ElkGraphJsonGrammarAccess {
  self.grammar_access
}

///|
pub fn AbstractElkGraphJsonSyntacticSequencer::get_unassigned_rule_call_token(
  self : AbstractElkGraphJsonSyntacticSequencer,
  _semantic_object : String,
  _rule_call : String,
  _node : String,
) -> String {
  ignore(self)
  ""
}

///|
pub fn AbstractElkGraphJsonSyntacticSequencer::emit_unassigned_tokens(
  self : AbstractElkGraphJsonSyntacticSequencer,
  _semantic_object : String,
  ambiguous_syntaxes : Array[String],
) -> Array[String] {
  let accepted : Array[String] = []
  for syntax in ambiguous_syntaxes {
    if syntax ==
      self.match_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q {
      accepted.push("{}")
    } else {
      accepted.push(syntax)
    }
  }
  accepted
}

///|
pub fn[A, B, C] AbstractElkGraphJsonSyntacticSequencer::emit_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q(
  self : AbstractElkGraphJsonSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "{}"
}
