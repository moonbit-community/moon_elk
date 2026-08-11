///|
pub struct ICompactor {
  compact_fn : (DCGraph) -> Unit raise
}

///|
pub fn new_icompactor(compact_fn : (DCGraph) -> Unit raise) -> ICompactor {
  { compact_fn, }
}

///|
pub fn ICompactor::compact(self : ICompactor, graph : DCGraph) -> Unit raise {
  (self.compact_fn)(graph)
}
