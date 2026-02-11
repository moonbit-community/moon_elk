///|
pub struct IRectangleStripOverlapRemovalStrategy {
  remove_overlaps : (RectangleStripOverlapRemover) -> Double
}

///|
pub fn new_irectangle_strip_overlap_removal_strategy(
  remove_overlaps : (RectangleStripOverlapRemover) -> Double,
) -> IRectangleStripOverlapRemovalStrategy {
  { remove_overlaps, }
}

///|
pub fn IRectangleStripOverlapRemovalStrategy::remove_overlaps(
  self : IRectangleStripOverlapRemovalStrategy,
  overlap_remover : RectangleStripOverlapRemover,
) -> Double {
  (self.remove_overlaps)(overlap_remover)
}
