///|
pub struct AbstractLayoutProvider {
  graph_layout_engine : IGraphLayoutEngine
  initialize_fn : (String?) -> Unit
  dispose_fn : () -> Unit
}

///|
pub fn new_abstract_layout_provider(
  layout_fn : (ElkNode, IElkProgressMonitor) -> Unit,
  initialize_fn? : (String?) -> Unit = _ => (),
  dispose_fn? : () -> Unit = () => (),
) -> AbstractLayoutProvider {
  {
    graph_layout_engine: new_graph_layout_engine(layout_fn),
    initialize_fn,
    dispose_fn,
  }
}

///|
pub fn AbstractLayoutProvider::layout(
  self : AbstractLayoutProvider,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  self.graph_layout_engine.layout(layout_graph, progress_monitor)
}

///|
pub fn AbstractLayoutProvider::initialize(
  self : AbstractLayoutProvider,
  parameter : String?,
) -> Unit {
  (self.initialize_fn)(parameter)
}

///|
pub fn AbstractLayoutProvider::dispose(self : AbstractLayoutProvider) -> Unit {
  (self.dispose_fn)()
}

///|
pub fn AbstractLayoutProvider::as_graph_layout_engine(
  self : AbstractLayoutProvider,
) -> IGraphLayoutEngine {
  self.graph_layout_engine
}
