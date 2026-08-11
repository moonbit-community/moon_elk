///|
pub struct IRectangleStripOverlapRemovalStrategy {
  remove_overlaps : ((RectangleStripOverlapRemover) -> Double raise)?
  pure_remove_overlaps : ((RectangleStripOverlapRemover) -> Double)?
}

///|
pub fn new_irectangle_strip_overlap_removal_strategy(
  remove_overlaps : (RectangleStripOverlapRemover) -> Double raise,
) -> IRectangleStripOverlapRemovalStrategy {
  { remove_overlaps: Some(remove_overlaps), pure_remove_overlaps: None }
}

///|
pub fn new_pure_irectangle_strip_overlap_removal_strategy(
  remove_overlaps : (RectangleStripOverlapRemover) -> Double,
) -> IRectangleStripOverlapRemovalStrategy {
  { remove_overlaps: None, pure_remove_overlaps: Some(remove_overlaps) }
}

///|
pub fn IRectangleStripOverlapRemovalStrategy::remove_overlaps(
  self : IRectangleStripOverlapRemovalStrategy,
  overlap_remover : RectangleStripOverlapRemover,
) -> Double raise {
  match self.remove_overlaps {
    Some(remove_overlaps) => remove_overlaps(overlap_remover)
    None =>
      match self.pure_remove_overlaps {
        Some(remove_overlaps) => remove_overlaps(overlap_remover)
        None => 0.0
      }
  }
}
