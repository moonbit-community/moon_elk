///|
pub struct LayeredElkGraphImporter {
  session : LayeredTransformSession
}

///|
pub fn new_layered_elk_graph_importer(
  session : LayeredTransformSession,
) -> LayeredElkGraphImporter {
  { session, }
}

///|
pub fn LayeredElkGraphImporter::import_graph(
  self : LayeredElkGraphImporter,
  graph : @graph.ElkNode,
) -> LGraph raise {
  match recursive_layered_import_graph_for_transform(self.session, graph) {
    Some(layered_graph) => layered_graph
    None => {
      @core.layout_runtime_raise_unsupported_graph(
        "The source or the target of an edge could not be found.",
      )
      new_l_graph()
    }
  }
}
