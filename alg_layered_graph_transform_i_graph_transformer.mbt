///|
pub struct LayeredIGraphTransformer[T] {
  import_graph_fn : (T) -> LGraph?
  apply_layout_fn : (LGraph) -> Unit
}

///|
pub fn[T] new_layered_igraph_transformer(
  import_graph : (T) -> LGraph?,
  apply_layout : (LGraph) -> Unit,
) -> LayeredIGraphTransformer[T] {
  { import_graph_fn: import_graph, apply_layout_fn: apply_layout }
}

///|
pub fn[T] LayeredIGraphTransformer::import_graph(
  self : LayeredIGraphTransformer[T],
  graph : T,
) -> LGraph? {
  (self.import_graph_fn)(graph)
}

///|
pub fn[T] LayeredIGraphTransformer::apply_layout(
  self : LayeredIGraphTransformer[T],
  layered_graph : LGraph,
) -> Unit {
  (self.apply_layout_fn)(layered_graph)
}
