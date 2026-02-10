///|
pub fn vertiflex_find_root(graph : ElkNode) -> ElkNode? {
  for child in node_children(graph) {
    if node_incoming_edges(child).is_empty() {
      return Some(child)
    }
  }
  None
}
