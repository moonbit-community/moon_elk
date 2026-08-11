///|
pub struct LayeredElkGraphTransformer {
  session : LayeredTransformSession
}

///|
pub fn new_layered_elk_graph_transformer() -> LayeredElkGraphTransformer {
  { session: new_layered_transform_session() }
}

///|
pub fn LayeredElkGraphTransformer::import_graph(
  self : LayeredElkGraphTransformer,
  graph : @graph.ElkNode,
) -> LGraph raise {
  new_layered_elk_graph_importer(self.session).import_graph(graph)
}

///|
pub fn LayeredElkGraphTransformer::apply_layout(
  self : LayeredElkGraphTransformer,
  layered_graph : LGraph,
) -> Unit {
  new_layered_elk_graph_layout_transferrer(self.session).apply_layout(
    layered_graph,
  )
}

///|
/// Releases importer indexes when a layout is canceled before transfer.
pub fn LayeredElkGraphTransformer::clear(
  self : LayeredElkGraphTransformer,
) -> Unit {
  self.session.clear()
}

///|
pub fn LayeredElkGraphTransformer::as_layered_igraph_transformer(
  self : LayeredElkGraphTransformer,
) -> LayeredIGraphTransformer[@graph.ElkNode] {
  new_layered_igraph_transformer(
    fn(graph : @graph.ElkNode) raise { Some(self.import_graph(graph)) },
    (layered_graph : LGraph) => self.apply_layout(layered_graph),
  )
}

///|
pub fn layered_elk_graph_transformer_get_origin_identifier(
  element : LGraphElement,
) -> String? {
  element.get_origin_identifier()
}
