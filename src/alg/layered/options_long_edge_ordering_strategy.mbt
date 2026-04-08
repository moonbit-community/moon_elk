///|
pub enum LongEdgeOrderingStrategy {
  DummyNodeOver
  DummyNodeUnder
  Equal
}

///|
pub fn LongEdgeOrderingStrategy::return_value(
  self : LongEdgeOrderingStrategy,
) -> Int {
  match self {
    DummyNodeOver => @int.MAX_VALUE
    DummyNodeUnder => @int.MIN_VALUE
    Equal => 0
  }
}

///|
pub fn long_edge_ordering_strategy_return_values() -> Array[Int] {
  [
    LongEdgeOrderingStrategy::return_value(DummyNodeOver),
    LongEdgeOrderingStrategy::return_value(DummyNodeUnder),
    LongEdgeOrderingStrategy::return_value(Equal),
  ]
}
