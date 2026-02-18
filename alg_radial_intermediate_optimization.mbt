///|
pub fn radial_evaluate_translation(
  strategy : RadialTranslationStrategy,
  root : ElkNode,
) -> Double {
  if radial_translation_strategy_create(strategy) is Some(evaluator) {
    evaluator.evaluate(root)
  } else {
    0.0
  }
}
