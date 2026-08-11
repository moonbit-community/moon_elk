///|
pub struct IRadialSorter {
  sort_fn : ((Array[@graph.ElkNode]) -> Unit raise)?
  pure_sort_fn : ((Array[@graph.ElkNode]) -> Unit)?
  initialize_fn : ((@graph.ElkNode) -> Unit raise)?
}

///|
pub fn new_i_radial_sorter(
  sort : (Array[@graph.ElkNode]) -> Unit raise,
  initialize? : (@graph.ElkNode) -> Unit raise,
) -> IRadialSorter {
  { sort_fn: Some(sort), pure_sort_fn: None, initialize_fn: initialize }
}

///|
pub fn new_pure_i_radial_sorter(
  sort : (Array[@graph.ElkNode]) -> Unit,
) -> IRadialSorter {
  { sort_fn: None, pure_sort_fn: Some(sort), initialize_fn: None }
}

///|
pub fn IRadialSorter::sort(
  self : IRadialSorter,
  nodes : Array[@graph.ElkNode],
) -> Unit raise {
  match self.sort_fn {
    Some(sort) => sort(nodes)
    None =>
      match self.pure_sort_fn {
        Some(sort) => sort(nodes)
        None => ()
      }
  }
}

///|
pub fn IRadialSorter::initialize(
  self : IRadialSorter,
  root : @graph.ElkNode,
) -> Unit raise {
  match self.initialize_fn {
    Some(initialize) => initialize(root)
    None => ()
  }
}
