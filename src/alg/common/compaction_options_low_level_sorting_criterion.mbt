///|
pub enum LowLevelSortingCriterion {
  BySize
  BySizeAndShape
}

///|
pub fn low_level_sorting_criterion_values() -> Array[LowLevelSortingCriterion] {
  [BySize, BySizeAndShape]
}
