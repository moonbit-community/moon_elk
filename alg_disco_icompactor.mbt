///|
pub struct ICompactor {
  compact_fn : (DCGraph) -> Unit
}

///|
pub fn new_icompactor(compact_fn : (DCGraph) -> Unit) -> ICompactor {
  { compact_fn, }
}

///|
pub fn ICompactor::compact(self : ICompactor, graph : DCGraph) -> Unit {
  (self.compact_fn)(graph)
}
