///|
pub enum DotGraphElement {
  DotGraphElementNode(@graph.ElkNode)
  DotGraphElementEdge(@graph.ElkEdge)
  DotGraphElementPort(@graph.ElkPort)
  DotGraphElementLabel(@graph.ElkLabel)
}

///|
pub fn dot_graph_element_node(node : @graph.ElkNode) -> DotGraphElement {
  DotGraphElementNode(node)
}

///|
pub fn dot_graph_element_edge(edge : @graph.ElkEdge) -> DotGraphElement {
  DotGraphElementEdge(edge)
}

///|
pub fn dot_graph_element_port(port : @graph.ElkPort) -> DotGraphElement {
  DotGraphElementPort(port)
}

///|
pub fn dot_graph_element_label(label : @graph.ElkLabel) -> DotGraphElement {
  DotGraphElementLabel(label)
}

///|
pub fn dot_graph_element_as_node(graph_element : DotGraphElement) -> @graph.ElkNode? {
  match graph_element {
    DotGraphElementNode(node) => Some(node)
    _ => None
  }
}

///|
pub fn dot_graph_element_as_edge(graph_element : DotGraphElement) -> @graph.ElkEdge? {
  match graph_element {
    DotGraphElementEdge(edge) => Some(edge)
    _ => None
  }
}
