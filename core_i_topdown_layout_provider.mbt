///|
pub struct ITopdownLayoutProvider {
  get_predicted_graph_size_fn : (ElkNode) -> KVector
}

///|
pub fn new_topdown_layout_provider(
  get_predicted_graph_size_fn : (ElkNode) -> KVector,
) -> ITopdownLayoutProvider {
  { get_predicted_graph_size_fn, }
}

///|
pub fn ITopdownLayoutProvider::get_predicted_graph_size(
  self : ITopdownLayoutProvider,
  graph : ElkNode,
) -> KVector {
  (self.get_predicted_graph_size_fn)(graph)
}
