///|
pub struct IRadialCompactor {
  compact_fn : (ElkNode) -> Unit
}

///|
pub fn new_i_radial_compactor(compact : (ElkNode) -> Unit) -> IRadialCompactor {
  { compact_fn: compact }
}

///|
pub fn IRadialCompactor::compact(
  self : IRadialCompactor,
  graph : ElkNode,
) -> Unit {
  (self.compact_fn)(graph)
}
