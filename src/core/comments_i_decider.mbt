///|
pub type DeciderHeuristicResult[T] = Array[(T, Array[(Int, Double)])]

///|
pub(all) struct IDecider[T] {
  make_attachment_decision_fn : (DeciderHeuristicResult[T]) -> T? raise
}

///|
pub fn[T] new_decider(
  make_attachment_decision_fn : (DeciderHeuristicResult[T]) -> T? raise,
) -> IDecider[T] {
  { make_attachment_decision_fn, }
}

///|
pub fn[T] IDecider::make_attachment_decision(
  self : IDecider[T],
  normalized_heuristics : DeciderHeuristicResult[T],
) -> T? raise {
  (self.make_attachment_decision_fn)(normalized_heuristics)
}
