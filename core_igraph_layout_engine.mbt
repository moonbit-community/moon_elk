///|
pub struct IGraphLayoutEngine {
  layout_fn : (ElkNode, IElkProgressMonitor) -> Unit
}

///|
pub fn new_graph_layout_engine(
  layout_fn : (ElkNode, IElkProgressMonitor) -> Unit,
) -> IGraphLayoutEngine {
  { layout_fn, }
}

///|
pub fn IGraphLayoutEngine::layout(
  self : IGraphLayoutEngine,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  (self.layout_fn)(layout_graph, progress_monitor)
}
