///|
pub enum SelectionGraphElement {
  SelectionEdge(ElkEdge)
  SelectionPort(ElkPort)
}

///|
pub struct SelectionIterator {
  mut visited : Array[ElkPort]
}

///|
pub fn new_selection_iterator() -> SelectionIterator {
  { visited: [] }
}

///|
pub fn SelectionIterator::attach_visited_set(
  self : SelectionIterator,
  visited_set : Array[ElkPort],
) -> Unit {
  self.visited = visited_set
}
