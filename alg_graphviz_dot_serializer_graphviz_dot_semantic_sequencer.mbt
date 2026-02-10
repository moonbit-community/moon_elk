///|
pub struct GraphvizDotSemanticSequencer {
  marker : Unit
}

///|
pub fn new_graphviz_dot_semantic_sequencer() -> GraphvizDotSemanticSequencer {
  { marker: () }
}

///|
pub fn[T] GraphvizDotSemanticSequencer::sequence(
  self : GraphvizDotSemanticSequencer,
  semantic_object : T,
) -> T {
  ignore(self)
  semantic_object
}
