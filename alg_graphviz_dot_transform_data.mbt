///|
pub enum DotGraphElement {
  DotGraphElementNode(ElkNode)
  DotGraphElementEdge(ElkEdge)
  DotGraphElementPort(ElkPort)
  DotGraphElementLabel(ElkLabel)
}

///|
pub fn dot_graph_element_node(node : ElkNode) -> DotGraphElement {
  DotGraphElementNode(node)
}

///|
pub fn dot_graph_element_edge(edge : ElkEdge) -> DotGraphElement {
  DotGraphElementEdge(edge)
}

///|
pub fn dot_graph_element_port(port : ElkPort) -> DotGraphElement {
  DotGraphElementPort(port)
}

///|
pub fn dot_graph_element_label(label : ElkLabel) -> DotGraphElement {
  DotGraphElementLabel(label)
}

///|
pub fn dot_graph_element_as_node(graph_element : DotGraphElement) -> ElkNode? {
  match graph_element {
    DotGraphElementNode(node) => Some(node)
    _ => None
  }
}

///|
pub fn dot_graph_element_as_edge(graph_element : DotGraphElement) -> ElkEdge? {
  match graph_element {
    DotGraphElementEdge(edge) => Some(edge)
    _ => None
  }
}
