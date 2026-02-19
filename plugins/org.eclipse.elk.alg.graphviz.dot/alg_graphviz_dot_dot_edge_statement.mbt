///|
pub struct DotEdgeStatement {
  mut source_node : DotNode?
  edge_targets : Array[DotEdgeTarget]
  attributes : Array[DotAttribute]
}

///|
pub fn dot_create_edge_statement() -> DotEdgeStatement {
  { source_node: None, edge_targets: [], attributes: [] }
}

///|
pub fn DotEdgeStatement::get_source_node(self : DotEdgeStatement) -> DotNode? {
  self.source_node
}

///|
pub fn DotEdgeStatement::set_source_node(
  self : DotEdgeStatement,
  value : DotNode?,
) -> Unit {
  self.source_node = value
}

///|
pub fn DotEdgeStatement::get_edge_targets(
  self : DotEdgeStatement,
) -> Array[DotEdgeTarget] {
  self.edge_targets
}

///|
pub fn DotEdgeStatement::get_attributes(
  self : DotEdgeStatement,
) -> Array[DotAttribute] {
  self.attributes
}
