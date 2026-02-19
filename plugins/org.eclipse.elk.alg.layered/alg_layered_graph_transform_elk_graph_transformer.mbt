///|
pub struct LayeredElkGraphTransformer {
  unit : Unit
}

///|
pub fn new_layered_elk_graph_transformer() -> LayeredElkGraphTransformer {
  { unit: () }
}

///|
pub fn LayeredElkGraphTransformer::import_graph(
  self : LayeredElkGraphTransformer,
  graph : ElkNode,
) -> LGraph {
  ignore(self)
  new_layered_elk_graph_importer().import_graph(graph)
}

///|
pub fn LayeredElkGraphTransformer::apply_layout(
  self : LayeredElkGraphTransformer,
  layered_graph : LGraph,
) -> Unit {
  ignore(self)
  new_layered_elk_graph_layout_transferrer().apply_layout(layered_graph)
}

///|
pub fn LayeredElkGraphTransformer::as_layered_igraph_transformer(
  self : LayeredElkGraphTransformer,
) -> LayeredIGraphTransformer[ElkNode] {
  new_layered_igraph_transformer(
    (graph : ElkNode) => Some(self.import_graph(graph)),
    (layered_graph : LGraph) => self.apply_layout(layered_graph),
  )
}

///|
pub fn layered_elk_graph_transformer_get_origin_identifier(
  element : LGraphElement,
) -> String? {
  element.get_origin_identifier()
}
