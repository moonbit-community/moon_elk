///|
pub enum HighLevelSortingCriterion {
  NumOfExternalSidesThanNumOfExtensionsLast
  CornerCasesThanSingleSideLast
}

///|
pub fn high_level_sorting_criterion_values() -> Array[HighLevelSortingCriterion] {
  [NumOfExternalSidesThanNumOfExtensionsLast, CornerCasesThanSingleSideLast]
}
