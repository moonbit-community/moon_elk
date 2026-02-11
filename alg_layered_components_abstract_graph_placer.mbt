///|
pub struct LayeredAbstractGraphPlacer {
  _dummy : Unit
}

///|
pub fn new_layered_abstract_graph_placer() -> LayeredAbstractGraphPlacer {
  { _dummy: () }
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
  _dest_graph : LGraph,
  source_graph : LGraph,
  offsetx : Double,
  offsety : Double,
) -> Unit {
  ignore(self)
  let graph_offset = source_graph.get_offset().clone().add_xy(offsetx, offsety)
  source_graph.set_offset_xy(graph_offset.x, graph_offset.y)
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
  let graph_offset = graph.get_offset().clone().add_xy(offsetx, offsety)
  graph.set_offset_xy(graph_offset.x, graph_offset.y)
}
