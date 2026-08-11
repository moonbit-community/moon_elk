///|
pub struct IRadialCompactor {
  compact_fn : (@graph.ElkNode) -> Unit raise
}

///|
pub fn new_i_radial_compactor(
  compact : (@graph.ElkNode) -> Unit raise,
) -> IRadialCompactor {
  { compact_fn: compact }
}

///|
pub fn IRadialCompactor::compact(
  self : IRadialCompactor,
  graph : @graph.ElkNode,
) -> Unit raise {
  (self.compact_fn)(graph)
}
