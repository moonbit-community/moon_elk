///|
pub struct SporeIGraphImporter[T] {
  import_graph_fn : (T) -> SporeGraph
  apply_positions_fn : (SporeGraph) -> Unit
  update_graph_fn : (SporeGraph) -> Unit
}

///|
pub fn[T] new_spore_igraph_importer(
  import_graph_fn : (T) -> SporeGraph,
  apply_positions_fn : (SporeGraph) -> Unit,
  update_graph_fn : (SporeGraph) -> Unit,
) -> SporeIGraphImporter[T] {
  { import_graph_fn, apply_positions_fn, update_graph_fn }
}

///|
pub fn[T] SporeIGraphImporter::import_graph(
  self : SporeIGraphImporter[T],
  graph : T,
) -> SporeGraph {
  (self.import_graph_fn)(graph)
}

///|
pub fn[T] SporeIGraphImporter::apply_positions(
  self : SporeIGraphImporter[T],
  graph : SporeGraph,
) -> Unit {
  (self.apply_positions_fn)(graph)
}

///|
pub fn[T] SporeIGraphImporter::update_graph(
  self : SporeIGraphImporter[T],
  graph : SporeGraph,
) -> Unit {
  (self.update_graph_fn)(graph)
}
