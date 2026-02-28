///|
pub(all) enum SelectionGraphElement {
  SelectionEdge(@graph.ElkEdge)
  SelectionPort(@graph.ElkPort)
}

///|
pub(all) struct SelectionIterator {
  mut visited : Array[@graph.ElkPort]
}

///|
pub fn new_selection_iterator() -> SelectionIterator {
  { visited: [] }
}

///|
pub fn SelectionIterator::attach_visited_set(
  self : SelectionIterator,
  visited_set : Array[@graph.ElkPort],
) -> Unit {
  self.visited = visited_set
}
