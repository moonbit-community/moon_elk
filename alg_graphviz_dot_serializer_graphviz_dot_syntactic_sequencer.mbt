///|
pub struct GraphvizDotSyntacticSequencer {
  marker : Unit
}

///|
pub fn new_graphviz_dot_syntactic_sequencer() -> GraphvizDotSyntacticSequencer {
  { marker: () }
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_attribute_statement_comma_keyword_2_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_edge_statement_comma_keyword_2_1_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_node_statement_comma_keyword_1_1_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ","
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_statement_semicolon_keyword_1_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  ";"
}

///|
pub fn[A, B, C] GraphvizDotSyntacticSequencer::emit_subgraph_subgraph_keyword_1_0_q(
  self : GraphvizDotSyntacticSequencer,
  _semantic_object : A,
  _transition : B,
  _nodes : Array[C],
) -> String {
  ignore(self)
  "subgraph"
}
