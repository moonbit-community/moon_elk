///|
pub struct ITopdownSizeApproximator {
  get_size_fn : (ElkNode) -> KVector
}

///|
pub fn new_topdown_size_approximator(
  get_size_fn : (ElkNode) -> KVector,
) -> ITopdownSizeApproximator {
  { get_size_fn, }
}

///|
pub fn ITopdownSizeApproximator::get_size(
  self : ITopdownSizeApproximator,
  node : ElkNode,
) -> KVector {
  (self.get_size_fn)(node)
}
