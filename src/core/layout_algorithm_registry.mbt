///|
pub type RecursiveGraphLayoutHandler = (
  LayoutRuntime,
  LayoutSession,
  @graph.ElkNode,
  IElkProgressMonitor,
) -> Unit raise

///|
priv struct AlgorithmRegistry {
  handlers : Map[String, RecursiveGraphLayoutHandler]
}

///|
fn new_algorithm_registry() -> AlgorithmRegistry {
  { handlers: Map([]) }
}

///|
pub fn LayoutRuntime::register_layout_algorithm(
  self : LayoutRuntime,
  algorithm_id : String,
  handler : RecursiveGraphLayoutHandler,
) -> Unit {
  self.algorithm_registry().handlers[algorithm_id] = handler
}

///|
fn LayoutRuntime::layout_algorithm(
  self : LayoutRuntime,
  algorithm_id : String,
) -> RecursiveGraphLayoutHandler? {
  self.algorithm_registry().handlers.get(algorithm_id)
}

///|
fn LayoutRuntime::layout_algorithm_ids(self : LayoutRuntime) -> Array[String] {
  let ids = []
  self.algorithm_registry().handlers.each((id, _handler) => ids.push(id))
  ids
}
