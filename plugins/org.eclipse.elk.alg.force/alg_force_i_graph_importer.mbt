///|
pub struct IGraphImporter[T] {
  import_graph_fn : (T) -> FGraph
  apply_layout_fn : (FGraph) -> Unit
}

///|
pub fn[T] new_igraph_importer(
  import_graph_fn : (T) -> FGraph,
  apply_layout_fn : (FGraph) -> Unit,
) -> IGraphImporter[T] {
  { import_graph_fn, apply_layout_fn }
}

///|
pub fn[T] IGraphImporter::import_graph(
  self : IGraphImporter[T],
  graph : T,
) -> FGraph {
  (self.import_graph_fn)(graph)
}

///|
pub fn[T] IGraphImporter::apply_layout(
  self : IGraphImporter[T],
  force_graph : FGraph,
) -> Unit {
  (self.apply_layout_fn)(force_graph)
}
