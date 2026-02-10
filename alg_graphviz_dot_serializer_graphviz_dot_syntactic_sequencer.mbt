///|
pub struct GraphvizDotSyntacticSequencer {
  base : AbstractGraphvizDotSyntacticSequencer
}

///|
pub fn new_graphviz_dot_syntactic_sequencer() -> GraphvizDotSyntacticSequencer {
  { base: new_abstract_graphviz_dot_syntactic_sequencer() }
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_attribute_statement_comma_keyword_2_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_attribute_statement_comma_keyword_2_1_0_q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_edge_statement_comma_keyword_2_1_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_edge_statement_comma_keyword_2_1_1_0_q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_edge_statement___left_square_bracket_keyword_2_0_right_square_bracket_keyword_2_2__q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_node_statement_comma_keyword_1_1_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_node_statement_comma_keyword_1_1_1_0_q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_node_statement___left_square_bracket_keyword_1_0_right_square_bracket_keyword_1_2__q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_statement_semicolon_keyword_1_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_statement_semicolon_keyword_1_q(
    _semantic_object, _transition, _nodes,
  )
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_subgraph_subgraph_keyword_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  self.base.emit_subgraph_subgraph_keyword_1_0_q(
    _semantic_object, _transition, _nodes,
  )
}
