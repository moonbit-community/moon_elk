///|
pub struct DotNode {
  mut name : String?
  mut port : DotPort?
}

///|
pub fn dot_create_node() -> DotNode {
  { name: None, port: None }
}

///|
pub fn DotNode::get_name(self : DotNode) -> String? {
  self.name
}

///|
pub fn DotNode::set_name(self : DotNode, value : String?) -> Unit {
  self.name = value
}

///|
pub fn DotNode::get_port(self : DotNode) -> DotPort? {
  self.port
}

///|
pub fn DotNode::set_port(self : DotNode, value : DotPort?) -> Unit {
  self.port = value
}
