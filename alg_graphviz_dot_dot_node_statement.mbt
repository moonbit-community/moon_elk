///|
pub struct DotNodeStatement {
  mut node : DotNode?
  attributes : Array[DotAttribute]
}

///|
pub fn dot_create_node_statement() -> DotNodeStatement {
  { node: None, attributes: [] }
}

///|
pub fn DotNodeStatement::get_node(self : DotNodeStatement) -> DotNode? {
  self.node
}

///|
pub fn DotNodeStatement::set_node(
  self : DotNodeStatement,
  value : DotNode?,
) -> Unit {
  self.node = value
}

///|
pub fn DotNodeStatement::get_attributes(
  self : DotNodeStatement,
) -> Array[DotAttribute] {
  self.attributes
}
