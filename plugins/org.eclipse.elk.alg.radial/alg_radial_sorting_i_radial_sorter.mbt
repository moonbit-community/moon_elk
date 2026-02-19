///|
pub struct IRadialSorter {
  sort_fn : (Array[ElkNode]) -> Unit
  initialize_fn : (ElkNode) -> Unit
}

///|
pub fn new_i_radial_sorter(
  sort : (Array[ElkNode]) -> Unit,
  initialize? : (ElkNode) -> Unit = _ => (),
) -> IRadialSorter {
  { sort_fn: sort, initialize_fn: initialize }
}

///|
pub fn IRadialSorter::sort(
  self : IRadialSorter,
  nodes : Array[ElkNode],
) -> Unit {
  (self.sort_fn)(nodes)
}

///|
pub fn IRadialSorter::initialize(self : IRadialSorter, root : ElkNode) -> Unit {
  (self.initialize_fn)(root)
}
