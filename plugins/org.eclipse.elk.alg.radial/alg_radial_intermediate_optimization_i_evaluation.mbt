///|
pub struct IEvaluation {
  evaluate_fn : (ElkNode) -> Double
}

///|
pub fn new_i_evaluation(evaluate : (ElkNode) -> Double) -> IEvaluation {
  { evaluate_fn: evaluate }
}

///|
pub fn IEvaluation::evaluate(self : IEvaluation, graph : ElkNode) -> Double {
  (self.evaluate_fn)(graph)
}
