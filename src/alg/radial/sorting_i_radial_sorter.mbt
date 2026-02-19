///|
pub struct IRadialSorter {
  sort_fn : (Array[@graph.ElkNode]) -> Unit
  initialize_fn : (@graph.ElkNode) -> Unit
}

///|
pub fn new_i_radial_sorter(
  sort : (Array[@graph.ElkNode]) -> Unit,
  initialize? : (@graph.ElkNode) -> Unit = _ => (),
) -> IRadialSorter {
  { sort_fn: sort, initialize_fn: initialize }
}

///|
pub fn IRadialSorter::sort(
  self : IRadialSorter,
  nodes : Array[@graph.ElkNode],
) -> Unit {
  (self.sort_fn)(nodes)
}

///|
pub fn IRadialSorter::initialize(
  self : IRadialSorter,
  root : @graph.ElkNode,
) -> Unit {
  (self.initialize_fn)(root)
}
