///|
pub struct IGraphImporter[T] {
  import_graph_fn : (T) -> FGraph raise
  apply_layout_fn : (FGraph) -> Unit raise
}

///|
pub fn[T] new_igraph_importer(
  import_graph_fn : (T) -> FGraph raise,
  apply_layout_fn : (FGraph) -> Unit raise,
) -> IGraphImporter[T] {
  { import_graph_fn, apply_layout_fn }
}

///|
pub fn[T] IGraphImporter::import_graph(
  self : IGraphImporter[T],
  graph : T,
) -> FGraph raise {
  (self.import_graph_fn)(graph)
}

///|
pub fn[T] IGraphImporter::apply_layout(
  self : IGraphImporter[T],
  force_graph : FGraph,
) -> Unit raise {
  (self.apply_layout_fn)(force_graph)
}
