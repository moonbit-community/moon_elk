///|
pub struct AbstractElkGraphSemanticSequencer {
  grammar_access : ElkGraphGrammarAccess
}

///|
pub fn new_abstract_elk_graph_semantic_sequencer(
  grammar_access? : ElkGraphGrammarAccess = new_elk_graph_grammar_access(),
) -> AbstractElkGraphSemanticSequencer {
  { grammar_access, }
}

///|
pub fn AbstractElkGraphSemanticSequencer::get_grammar_access(
  self : AbstractElkGraphSemanticSequencer,
) -> ElkGraphGrammarAccess {
  self.grammar_access
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence(
  self : AbstractElkGraphSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  ignore(self)
  semantic_object
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_edge_layout_elk_edge(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_bend_point(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_edge_section(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_label_shape_layout(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_node_shape_layout(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_port_shape_layout(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_elk_single_edge_section(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_property(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}

///|
pub fn[T] AbstractElkGraphSemanticSequencer::sequence_root_node_shape_layout(
  self : AbstractElkGraphSemanticSequencer,
  context : String,
  semantic_object : T,
) -> T {
  self.sequence(context, semantic_object)
}
