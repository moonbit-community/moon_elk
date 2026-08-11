///|
pub(all) struct AbstractLayoutProvider {
  graph_layout_engine : IGraphLayoutEngine
  initialize_fn : ((String?) -> Unit raise)?
  dispose_fn : (() -> Unit raise)?
}

///|
pub fn new_abstract_layout_provider(
  layout_fn : (@graph.ElkNode, IElkProgressMonitor) -> Unit raise,
  initialize_fn? : (String?) -> Unit raise,
  dispose_fn? : () -> Unit raise,
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
  layout_graph : @graph.ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit raise {
  self.graph_layout_engine.layout(layout_graph, progress_monitor)
}

///|
pub fn AbstractLayoutProvider::initialize(
  self : AbstractLayoutProvider,
  parameter : String?,
) -> Unit raise {
  match self.initialize_fn {
    Some(initialize) => initialize(parameter)
    None => ()
  }
}

///|
pub fn AbstractLayoutProvider::dispose(
  self : AbstractLayoutProvider,
) -> Unit raise {
  match self.dispose_fn {
    Some(dispose) => dispose()
    None => ()
  }
}

///|
pub fn AbstractLayoutProvider::as_graph_layout_engine(
  self : AbstractLayoutProvider,
) -> IGraphLayoutEngine {
  self.graph_layout_engine
}
