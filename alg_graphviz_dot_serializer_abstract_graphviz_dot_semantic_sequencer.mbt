///|
pub struct AbstractGraphvizDotSemanticSequencer {
  grammar_access : GraphvizDotGrammarAccess
  marker : Unit
}

///|
pub fn new_abstract_graphviz_dot_semantic_sequencer(
  grammar_access? : GraphvizDotGrammarAccess = new_graphviz_dot_grammar_access(),
) -> AbstractGraphvizDotSemanticSequencer {
  { grammar_access, marker: () }
}

///|
pub fn AbstractGraphvizDotSemanticSequencer::get_grammar_access(
  self : AbstractGraphvizDotSemanticSequencer,
) -> GraphvizDotGrammarAccess {
  self.grammar_access
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  ignore(self)
  semantic_object
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_attribute_statement(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("AttributeStatement", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_attribute(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("Attribute", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_edge_statement(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("EdgeStatement", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_edge_target(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("EdgeTarget", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_graph(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("Graph", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_graphviz_model(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("GraphvizModel", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_list_attribute(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("ListAttribute", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_node_statement(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("NodeStatement", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_node(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("Node", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_port(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("Port", semantic_object)
}

///|
pub fn[T] AbstractGraphvizDotSemanticSequencer::sequence_subgraph(
  self : AbstractGraphvizDotSemanticSequencer,
  _context : String,
  semantic_object : T,
) -> T {
  self.sequence("Subgraph", semantic_object)
}
