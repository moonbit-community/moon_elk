///|
pub fn vertiflex_find_root(graph : @graph.ElkNode) -> @graph.ElkNode? {
  for child in @graph.node_children(graph) {
    if @graph.node_incoming_edges(child).is_empty() {
      return Some(child)
    }
  }
  None
}
