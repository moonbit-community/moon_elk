///|
pub struct IEvaluation {
  evaluate_fn : ((@graph.ElkNode) -> Double raise)?
  pure_evaluate_fn : ((@graph.ElkNode) -> Double)?
}

///|
pub fn new_i_evaluation(
  evaluate : (@graph.ElkNode) -> Double raise,
) -> IEvaluation {
  { evaluate_fn: Some(evaluate), pure_evaluate_fn: None }
}

///|
pub fn new_pure_i_evaluation(
  evaluate : (@graph.ElkNode) -> Double,
) -> IEvaluation {
  { evaluate_fn: None, pure_evaluate_fn: Some(evaluate) }
}

///|
pub fn IEvaluation::evaluate(
  self : IEvaluation,
  graph : @graph.ElkNode,
) -> Double raise {
  match self.evaluate_fn {
    Some(evaluate) => evaluate(graph)
    None =>
      match self.pure_evaluate_fn {
        Some(evaluate) => evaluate(graph)
        None => 0.0
      }
  }
}
