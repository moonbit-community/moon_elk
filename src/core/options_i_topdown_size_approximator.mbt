///|
pub(all) struct ITopdownSizeApproximator {
  get_size_fn : (@graph.ElkNode) -> KVector
}

///|
pub fn new_topdown_size_approximator(
  get_size_fn : (@graph.ElkNode) -> KVector,
) -> ITopdownSizeApproximator {
  { get_size_fn, }
}

///|
pub fn ITopdownSizeApproximator::get_size(
  self : ITopdownSizeApproximator,
  node : @graph.ElkNode,
) -> KVector {
  (self.get_size_fn)(node)
}
