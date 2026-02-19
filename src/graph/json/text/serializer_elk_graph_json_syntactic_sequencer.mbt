///|
pub struct ElkGraphJsonSyntacticSequencer {
  base : AbstractElkGraphJsonSyntacticSequencer
}

///|
pub fn new_elk_graph_json_syntactic_sequencer(
  base? : AbstractElkGraphJsonSyntacticSequencer = new_abstract_elk_graph_json_syntactic_sequencer(),
) -> ElkGraphJsonSyntacticSequencer {
  { base, }
}

///|
pub fn[A, B, C] ElkGraphJsonSyntacticSequencer::emit_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q(
  self : ElkGraphJsonSyntacticSequencer,
  semantic_object : A,
  transition : B,
  nodes : Array[C],
) -> String {
  self.base.emit_json_object___left_curly_bracket_keyword_0_right_curly_bracket_keyword_3__q(
    semantic_object, transition, nodes,
  )
}
