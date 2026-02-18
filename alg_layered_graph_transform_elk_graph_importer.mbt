///|
pub struct LayeredElkGraphImporter {
  marker : Int
}

///|
pub fn new_layered_elk_graph_importer() -> LayeredElkGraphImporter {
  { marker: 0 }
}

///|
pub fn LayeredElkGraphImporter::import_graph(
  self : LayeredElkGraphImporter,
  graph : ElkNode,
) -> LGraph {
  ignore(self)
  match recursive_layered_import_graph_for_transform(graph) {
    Some(layered_graph) => layered_graph
    None => abort("layered elk graph import failed")
  }
}
