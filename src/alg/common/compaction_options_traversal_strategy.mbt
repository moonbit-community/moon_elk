///|
pub enum TraversalStrategy {
  Spiral
  LineByLine
  Manhattan
  Jitter
  QuadrantsLineByLine
  QuadrantsManhattan
  QuadrantsJitter
  CombineLineByLineManhattan
  CombineJitterManhattan
}

///|
pub fn traversal_strategy_values() -> Array[TraversalStrategy] {
  [
    Spiral,
    LineByLine,
    Manhattan,
    Jitter,
    QuadrantsLineByLine,
    QuadrantsManhattan,
    QuadrantsJitter,
    CombineLineByLineManhattan,
    CombineJitterManhattan,
  ]
}
