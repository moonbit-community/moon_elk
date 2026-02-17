///|
pub struct DefaultSelectionIterator {
  base : SelectionIterator
  add_ports : Bool
  follow_edge_direction : Bool
  start_edge : ElkEdge
  mut initialized : Bool
  stack : Array[SelectionGraphElement]
}

///|
pub fn new_default_selection_iterator(
  edge : ElkEdge,
  add_ports : Bool,
  follow_edge_direction : Bool,
) -> DefaultSelectionIterator {
  {
    base: new_selection_iterator(),
    add_ports,
    follow_edge_direction,
    start_edge: edge,
    initialized: false,
    stack: [],
  }
}

///|
fn default_selection_iterator_append_children(
  iterator : DefaultSelectionIterator,
  children : Array[SelectionGraphElement],
) -> Unit {
  if children.is_empty() {
    return
  }
  let mut index = children.length() - 1
  while index >= 0 {
    iterator.stack.push(children[index])
    index = index - 1
  }
}

///|
fn default_selection_iterator_connected_port(
  edge : ElkEdge,
  follow_edge_direction : Bool,
) -> ElkPort? {
  let connected_shapes = if follow_edge_direction {
    edge_targets(edge)
  } else {
    edge_sources(edge)
  }
  if connected_shapes.is_empty() {
    return None
  }
  if connected_shapes[0] is PortShape(port) {
    Some(port)
  } else {
    None
  }
}

///|
fn default_selection_iterator_get_children(
  iterator : DefaultSelectionIterator,
  object : SelectionGraphElement,
) -> Array[SelectionGraphElement] {
  if object is SelectionEdge(edge) {
    let port = match
      default_selection_iterator_connected_port(
        edge,
        iterator.follow_edge_direction,
      ) {
      Some(value) => value
      None => return []
    }
    if iterator.base.visited.contains(port) {
      return []
    }
    iterator.base.visited.push(port)

    let result = []
    if iterator.add_ports {
      result.push(SelectionPort(port))
    }

    let result_edges = if iterator.follow_edge_direction {
      port_outgoing_edges(port)
    } else {
      port_incoming_edges(port)
    }
    for next_edge in result_edges {
      result.push(SelectionEdge(next_edge))
    }
    result
  } else {
    []
  }
}

///|
fn default_selection_iterator_initialize(
  iterator : DefaultSelectionIterator,
) -> Unit {
  if iterator.initialized {
    return
  }
  default_selection_iterator_append_children(
    iterator,
    default_selection_iterator_get_children(
      iterator,
      SelectionEdge(iterator.start_edge),
    ),
  )
  iterator.initialized = true
}

///|
pub fn DefaultSelectionIterator::attach_visited_set(
  self : DefaultSelectionIterator,
  visited_set : Array[ElkPort],
) -> Unit {
  self.base.attach_visited_set(visited_set)
}

///|
pub fn DefaultSelectionIterator::has_next(
  self : DefaultSelectionIterator,
) -> Bool {
  default_selection_iterator_initialize(self)
  !self.stack.is_empty()
}

///|
pub fn DefaultSelectionIterator::next(
  self : DefaultSelectionIterator,
) -> SelectionGraphElement? {
  default_selection_iterator_initialize(self)
  match self.stack.pop() {
    Some(element) => {
      default_selection_iterator_append_children(
        self,
        default_selection_iterator_get_children(self, element),
      )
      Some(element)
    }
    None => None
  }
}
