///|
pub struct MrtreeIGraphImporter[T] {
  import_graph_fn : (T) -> MrtreeGraph raise
  apply_layout_fn : (MrtreeGraph) -> Unit raise
}

///|
pub fn[T] new_mrtree_igraph_importer(
  import_graph_fn : (T) -> MrtreeGraph raise,
  apply_layout_fn : (MrtreeGraph) -> Unit raise,
) -> MrtreeIGraphImporter[T] {
  { import_graph_fn, apply_layout_fn }
}

///|
pub fn[T] MrtreeIGraphImporter::import_graph(
  self : MrtreeIGraphImporter[T],
  graph : T,
) -> MrtreeGraph raise {
  (self.import_graph_fn)(graph)
}

///|
pub fn[T] MrtreeIGraphImporter::apply_layout(
  self : MrtreeIGraphImporter[T],
  graph : MrtreeGraph,
) -> Unit raise {
  (self.apply_layout_fn)(graph)
}
