///|
pub(all) struct ITopdownSizeApproximator {
  get_size_fn : (@graph.ElkNode) -> KVector raise
}

///|
pub fn new_topdown_size_approximator(
  get_size_fn : (@graph.ElkNode) -> KVector raise,
) -> ITopdownSizeApproximator {
  { get_size_fn, }
}

///|
pub fn ITopdownSizeApproximator::get_size(
  self : ITopdownSizeApproximator,
  node : @graph.ElkNode,
) -> KVector raise {
  (self.get_size_fn)(node)
}
