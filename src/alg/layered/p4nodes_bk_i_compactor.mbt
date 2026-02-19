///|
pub struct BkICompactor {
  horizontal_compaction_fn : (BKAlignedLayout) -> Unit
}

///|
pub fn new_bk_i_compactor(
  horizontal_compaction_fn : (BKAlignedLayout) -> Unit,
) -> BkICompactor {
  { horizontal_compaction_fn, }
}

///|
pub fn BkICompactor::horizontal_compaction(
  self : BkICompactor,
  bal : BKAlignedLayout,
) -> Unit {
  (self.horizontal_compaction_fn)(bal)
}
