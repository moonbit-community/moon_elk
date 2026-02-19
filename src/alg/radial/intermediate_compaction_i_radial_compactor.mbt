///|
pub struct IRadialCompactor {
  compact_fn : (@graph.ElkNode) -> Unit
}

///|
pub fn new_i_radial_compactor(compact : (@graph.ElkNode) -> Unit) -> IRadialCompactor {
  { compact_fn: compact }
}

///|
pub fn IRadialCompactor::compact(
  self : IRadialCompactor,
  graph : @graph.ElkNode,
) -> Unit {
  (self.compact_fn)(graph)
}
