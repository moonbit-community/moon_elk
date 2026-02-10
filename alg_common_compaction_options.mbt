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
