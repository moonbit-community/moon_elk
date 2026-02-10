///|
pub struct GraphvizDotSemanticSequencer {
  base : AbstractGraphvizDotSemanticSequencer
}

///|
pub fn new_graphviz_dot_semantic_sequencer() -> GraphvizDotSemanticSequencer {
  { base: new_abstract_graphviz_dot_semantic_sequencer() }
}

///|
pub fn[T] GraphvizDotSemanticSequencer::sequence(
  self : GraphvizDotSemanticSequencer,
  semantic_object : T,
) -> T {
  self.base.sequence("GraphvizDotSemanticSequencer", semantic_object)
}
