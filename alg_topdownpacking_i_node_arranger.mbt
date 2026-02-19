///|
pub struct INodeArranger {
  get_predicted_size_fn : (ElkNode) -> KVector
}

///|
pub fn new_node_arranger(
  get_predicted_size_fn : (ElkNode) -> KVector,
) -> INodeArranger {
  { get_predicted_size_fn, }
}

///|
pub fn INodeArranger::get_predicted_size(
  self : INodeArranger,
  graph : ElkNode,
) -> KVector {
  (self.get_predicted_size_fn)(graph)
}
