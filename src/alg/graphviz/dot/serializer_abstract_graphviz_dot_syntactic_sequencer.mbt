///|
pub struct AbstractGraphvizDotSyntacticSequencer {
  grammar_access : GraphvizDotGrammarAccess
  match_attribute_statement_comma_keyword_2_1_0_q : String
  match_edge_statement_comma_keyword_2_1_1_0_q : String
  match_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q : String
  match_node_statement_comma_keyword_1_1_1_0_q : String
  match_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q : String
  match_statement_semicolon_keyword_1_q : String
  match_subgraph_subgraph_keyword_1_0_q : String
}

///|
pub fn new_abstract_graphviz_dot_syntactic_sequencer(
  grammar_access? : GraphvizDotGrammarAccess = new_graphviz_dot_grammar_access(),
) -> AbstractGraphvizDotSyntacticSequencer {
  {
    grammar_access,
    match_attribute_statement_comma_keyword_2_1_0_q: "AttributeStatement_CommaKeyword_2_1_0_q",
    match_edge_statement_comma_keyword_2_1_1_0_q: "EdgeStatement_CommaKeyword_2_1_1_0_q",
    match_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q: "EdgeStatement___LeftSquareBracketKeyword_2_0_RightSquareBracketKeyword_2_2__q",
    match_node_statement_comma_keyword_1_1_1_0_q: "NodeStatement_CommaKeyword_1_1_1_0_q",
    match_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q: "NodeStatement___LeftSquareBracketKeyword_1_0_RightSquareBracketKeyword_1_2__q",
    match_statement_semicolon_keyword_1_q: "Statement_SemicolonKeyword_1_q",
    match_subgraph_subgraph_keyword_1_0_q: "Subgraph_SubgraphKeyword_1_0_q",
  }
}

///|
pub fn AbstractGraphvizDotSyntacticSequencer::get_grammar_access(
  self : AbstractGraphvizDotSyntacticSequencer,
) -> GraphvizDotGrammarAccess {
  self.grammar_access
}

///|
pub fn AbstractGraphvizDotSyntacticSequencer::get_unassigned_rule_call_token(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : String,
  _rule_call : String,
  _node : String,
) -> String {
  ignore(self)
  ""
}

///|
pub fn AbstractGraphvizDotSyntacticSequencer::emit_unassigned_tokens(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : String,
  ambiguous_syntaxes : Array[String],
) -> Array[String] {
  let accepted : Array[String] = []
  for syntax in ambiguous_syntaxes {
    if syntax == self.match_attribute_statement_comma_keyword_2_1_0_q {
      accepted.push(",")
    } else if syntax == self.match_edge_statement_comma_keyword_2_1_1_0_q {
      accepted.push(",")
    } else if syntax ==
      self.match_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q {
      accepted.push("[]")
    } else if syntax == self.match_node_statement_comma_keyword_1_1_1_0_q {
      accepted.push(",")
    } else if syntax ==
      self.match_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q {
      accepted.push("[]")
    } else if syntax == self.match_statement_semicolon_keyword_1_q {
      accepted.push(";")
    } else if syntax == self.match_subgraph_subgraph_keyword_1_0_q {
      accepted.push("subgraph")
    } else {
      accepted.push(syntax)
    }
  }
  accepted
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_attribute_statement_comma_keyword_2_1_0_q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_edge_statement_comma_keyword_2_1_1_0_q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "[]"
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_node_statement_comma_keyword_1_1_1_0_q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "[]"
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_statement_semicolon_keyword_1_q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ";"
}

///|
pub fn[A, B, C] AbstractGraphvizDotSyntacticSequencer::emit_subgraph_subgraph_keyword_1_0_q(
  self : AbstractGraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "subgraph"
}
