///|
pub struct LayeredLayoutProvider {
  layout_engine : RecursiveGraphLayoutEngine
}

///|
pub fn new_layered_layout_provider() -> LayeredLayoutProvider {
  { layout_engine: new_recursive_graph_layout_engine() }
}

///|
pub fn LayeredLayoutProvider::layout(
  self : LayeredLayoutProvider,
  elk_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  if recursive_layered_try_layout(elk_graph, progress_monitor) {
    return
  }
  self.layout_engine.layout(elk_graph, progress_monitor)
}

///|
pub fn layered_layout_provider_as_layout_provider(
  provider : LayeredLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
