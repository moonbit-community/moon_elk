///|
pub struct LayeredAbstractGraphPlacer {
  _dummy : Unit
}

///|
pub fn new_layered_abstract_graph_placer() -> LayeredAbstractGraphPlacer {
  { _dummy: () }
}

///|
fn layered_abstract_graph_placer_offset_graph_contents(
  graph : LGraph,
  graph_offset : @core.KVector,
) -> Unit {
  for node in graph.get_layerless_nodes() {
    ignore(node.get_position().add(graph_offset))
    for port in node.get_ports() {
      for edge in port.get_outgoing_edges() {
        ignore(edge.get_bend_points().offset(graph_offset))
        if edge.has_property_kvector_chain(layered_options_junction_points) {
          ignore(
            edge
            .get_property_kvector_chain(layered_options_junction_points)
            .offset(graph_offset),
          )
        }
        for label in edge.get_labels() {
          ignore(label.get_position().add(graph_offset))
        }
      }
    }
  }
}

///|
pub fn LayeredAbstractGraphPlacer::move_graphs(
  self : LayeredAbstractGraphPlacer,
  dest_graph : LGraph,
  source_graphs : Array[LGraph],
  offsetx : Double,
  offsety : Double,
) -> Unit {
  ignore(self)
  for source_graph in source_graphs {
    self.move_graph(dest_graph, source_graph, offsetx, offsety)
  }
}

///|
pub fn LayeredAbstractGraphPlacer::move_graph(
  self : LayeredAbstractGraphPlacer,
  dest_graph : LGraph,
  source_graph : LGraph,
  offsetx : Double,
  offsety : Double,
) -> Unit {
  ignore(self)
  let graph_offset = source_graph.get_offset().add_xy(offsetx, offsety)
  layered_abstract_graph_placer_offset_graph_contents(
    source_graph, graph_offset,
  )

  for node in source_graph.get_layerless_nodes() {
    dest_graph.get_layerless_nodes().push(node)
    node.set_graph(Some(dest_graph))
  }
}

///|
pub fn LayeredAbstractGraphPlacer::offset_graphs(
  self : LayeredAbstractGraphPlacer,
  graphs : Array[LGraph],
  offsetx : Double,
  offsety : Double,
) -> Unit {
  ignore(self)
  for graph in graphs {
    self.offset_graph(graph, offsetx, offsety)
  }
}

///|
pub fn LayeredAbstractGraphPlacer::offset_graph(
  self : LayeredAbstractGraphPlacer,
  graph : LGraph,
  offsetx : Double,
  offsety : Double,
) -> Unit {
  ignore(self)
  let graph_offset = @core.new_kvector_xy(offsetx, offsety)
  layered_abstract_graph_placer_offset_graph_contents(graph, graph_offset)
}
