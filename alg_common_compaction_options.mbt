///|
pub enum HighLevelSortingCriterion {
  NumOfExternalSidesThanNumOfExtensionsLast
  CornerCasesThanSingleSideLast
}

///|
pub enum LowLevelSortingCriterion {
  BySize
  BySizeAndShape
}

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
pub fn high_level_sorting_criterion_values() -> Array[HighLevelSortingCriterion] {
  [NumOfExternalSidesThanNumOfExtensionsLast, CornerCasesThanSingleSideLast]
}

///|
pub fn low_level_sorting_criterion_values() -> Array[LowLevelSortingCriterion] {
  [BySize, BySizeAndShape]
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
