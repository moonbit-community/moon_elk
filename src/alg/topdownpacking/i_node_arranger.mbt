///|
pub struct INodeArranger {
  get_predicted_size_fn : (@graph.ElkNode) -> @core.KVector
}

///|
pub fn new_node_arranger(
  get_predicted_size_fn : (@graph.ElkNode) -> @core.KVector,
) -> INodeArranger {
  { get_predicted_size_fn, }
}

///|
pub fn INodeArranger::get_predicted_size(
  self : INodeArranger,
  graph : @graph.ElkNode,
) -> @core.KVector {
  (self.get_predicted_size_fn)(graph)
}
