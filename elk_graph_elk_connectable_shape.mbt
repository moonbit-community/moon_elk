///|
pub enum ElkConnectableShape {
  NodeShape(ElkNode)
  PortShape(ElkPort)
}

///|
pub fn make_node_shape(node : ElkNode) -> ElkConnectableShape {
  NodeShape(node)
}

///|
pub fn make_port_shape(port : ElkPort) -> ElkConnectableShape {
  PortShape(port)
}
