///|
pub struct IOverlapRemoval {
  remove_overlaps_fn : (ElkNode, IElkProgressMonitor?) -> Unit
}

///|
pub fn new_i_overlap_removal(
  remove_overlaps : (ElkNode, IElkProgressMonitor?) -> Unit,
) -> IOverlapRemoval {
  { remove_overlaps_fn: remove_overlaps }
}

///|
pub fn IOverlapRemoval::remove_overlaps(
  self : IOverlapRemoval,
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  (self.remove_overlaps_fn)(graph, progress_monitor)
}
