///|
pub type ElkLabel = Int

///|
pub enum ElkLabelParent {
  NodeLabelParent(ElkNode)
  PortLabelParent(ElkPort)
  EdgeLabelParent(ElkEdge)
  LabelLabelParent(ElkLabel)
}

///|
pub fn make_node_label_parent(node : ElkNode) -> ElkLabelParent {
  NodeLabelParent(node)
}

///|
pub fn make_port_label_parent(port : ElkPort) -> ElkLabelParent {
  PortLabelParent(port)
}

///|
pub fn make_edge_label_parent(edge : ElkEdge) -> ElkLabelParent {
  EdgeLabelParent(edge)
}

///|
pub fn make_label_label_parent(label : ElkLabel) -> ElkLabelParent {
  LabelLabelParent(label)
}
