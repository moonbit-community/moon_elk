///|
pub struct AbstractElkGraphSyntacticSequencer {
  grammar_access : ElkGraphGrammarAccess
  match_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q : String
}

///|
pub fn new_abstract_elk_graph_syntactic_sequencer(
  grammar_access? : ElkGraphGrammarAccess = new_elk_graph_grammar_access(),
) -> AbstractElkGraphSyntacticSequencer {
  {
    grammar_access,
    match_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q: "ElkEdge___LeftCurlyBracketKeyword_7_0_RightCurlyBracketKeyword_7_4__q",
  }
}

///|
pub fn AbstractElkGraphSyntacticSequencer::get_grammar_access(
  self : AbstractElkGraphSyntacticSequencer,
) -> ElkGraphGrammarAccess {
  self.grammar_access
}

///|
pub fn AbstractElkGraphSyntacticSequencer::get_unassigned_rule_call_token(
  self : AbstractElkGraphSyntacticSequencer,
  _semantic_object : String,
  _rule_call : String,
  _node : String,
) -> String {
  ignore(self)
  ""
}

///|
pub fn AbstractElkGraphSyntacticSequencer::emit_unassigned_tokens(
  self : AbstractElkGraphSyntacticSequencer,
  _semantic_object : String,
  ambiguous_syntaxes : Array[String],
) -> Array[String] {
  let accepted : Array[String] = []
  for syntax in ambiguous_syntaxes {
    if syntax ==
      self.match_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q {
      accepted.push("{}")
    } else {
      accepted.push(syntax)
    }
  }
  accepted
}

///|
pub fn[A, B, C] AbstractElkGraphSyntacticSequencer::emit_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q(
  self : AbstractElkGraphSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "{}"
}
