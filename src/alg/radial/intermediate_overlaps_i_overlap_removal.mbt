///|
pub struct IOverlapRemoval {
  remove_overlaps_fn : (@graph.ElkNode, @core.IElkProgressMonitor?) -> Unit
}

///|
pub fn new_i_overlap_removal(
  remove_overlaps : (@graph.ElkNode, @core.IElkProgressMonitor?) -> Unit,
) -> IOverlapRemoval {
  { remove_overlaps_fn: remove_overlaps }
}

///|
pub fn IOverlapRemoval::remove_overlaps(
  self : IOverlapRemoval,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  (self.remove_overlaps_fn)(graph, progress_monitor)
}
