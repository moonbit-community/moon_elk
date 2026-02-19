///|
pub struct IEvaluation {
  evaluate_fn : (@graph.ElkNode) -> Double
}

///|
pub fn new_i_evaluation(evaluate : (@graph.ElkNode) -> Double) -> IEvaluation {
  { evaluate_fn: evaluate }
}

///|
pub fn IEvaluation::evaluate(self : IEvaluation, graph : @graph.ElkNode) -> Double {
  (self.evaluate_fn)(graph)
}
