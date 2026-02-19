///|
pub struct IGraphTransformer[G] {
  import_graph_fn : (G) -> DCGraph
  apply_layout_fn : () -> Unit
}

///|
pub fn[G] new_igraph_transformer(
  import_graph_fn : (G) -> DCGraph,
  apply_layout_fn : () -> Unit,
) -> IGraphTransformer[G] {
  { import_graph_fn, apply_layout_fn }
}

///|
pub fn[G] IGraphTransformer::import_graph(
  self : IGraphTransformer[G],
  graph : G,
) -> DCGraph {
  (self.import_graph_fn)(graph)
}

///|
pub fn[G] IGraphTransformer::apply_layout(self : IGraphTransformer[G]) -> Unit {
  (self.apply_layout_fn)()
}
