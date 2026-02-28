///|
pub struct ElkGraphSyntacticSequencer {
  base : AbstractElkGraphSyntacticSequencer
}

///|
pub fn new_elk_graph_syntactic_sequencer(
  base? : AbstractElkGraphSyntacticSequencer = new_abstract_elk_graph_syntactic_sequencer(),
) -> ElkGraphSyntacticSequencer {
  { base, }
}

///|
pub fn[A, B, C] ElkGraphSyntacticSequencer::emit_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q(
  self : ElkGraphSyntacticSequencer,
  semantic_object : A,
  transition : B,
  nodes : Array[C],
) -> String {
  self.base.emit_elk_edge___left_curly_bracket_keyword_7_0_right_curly_bracket_keyword_7_4__q(
    semantic_object, transition, nodes,
  )
}
