///|
pub struct AbstractElkGraphJsonSemanticSequencer {
  grammar_access : ElkGraphJsonGrammarAccess
}

///|
pub fn new_abstract_elk_graph_json_semantic_sequencer(
  grammar_access? : ElkGraphJsonGrammarAccess = new_elk_graph_json_grammar_access(),
) -> AbstractElkGraphJsonSemanticSequencer {
  { grammar_access, }
}

///|
pub fn AbstractElkGraphJsonSemanticSequencer::get_grammar_access(
  self : AbstractElkGraphJsonSemanticSequencer,
) -> ElkGraphJsonGrammarAccess {
  self.grammar_access
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence(
  self : AbstractElkGraphJsonSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  ignore(self)
  semantic_object
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_edge_layout_elk_edge(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_bend_point(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_edge_section(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_label_shape_layout(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_node_shape_layout(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_port_shape_layout(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_elk_single_edge_section(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_property(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphJsonSemanticSequencer::sequence_root_node_shape_layout(
  self : AbstractElkGraphJsonSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}
