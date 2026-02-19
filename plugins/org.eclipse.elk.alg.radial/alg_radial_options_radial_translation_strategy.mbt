///|
pub enum RadialTranslationStrategy {
  NONE
  EDGE_LENGTH
  EDGE_LENGTH_BY_POSITION
  CROSSING_MINIMIZATION_BY_POSITION
}

///|
pub fn radial_translation_strategy_create(
  strategy : RadialTranslationStrategy,
) -> IEvaluation? {
  match strategy {
    RadialTranslationStrategy::NONE => None
    RadialTranslationStrategy::EDGE_LENGTH =>
      Some(new_edge_length_optimization().as_i_evaluation())
    RadialTranslationStrategy::EDGE_LENGTH_BY_POSITION =>
      Some(new_edge_length_position_optimization().as_i_evaluation())
    RadialTranslationStrategy::CROSSING_MINIMIZATION_BY_POSITION =>
      Some(new_crossing_minimization_position().as_i_evaluation())
  }
}
