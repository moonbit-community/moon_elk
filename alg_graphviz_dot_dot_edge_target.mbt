///|
pub struct DotEdgeTarget {
  mut operator : DotEdgeOperator
  mut target_subgraph : DotSubgraph?
  mut targetnode : DotNode?
}

///|
pub fn dot_create_edge_target() -> DotEdgeTarget {
  { operator: DotEdgeOperatorDirected, target_subgraph: None, targetnode: None }
}

///|
pub fn DotEdgeTarget::get_operator(self : DotEdgeTarget) -> DotEdgeOperator {
  self.operator
}

///|
pub fn DotEdgeTarget::set_operator(
  self : DotEdgeTarget,
  value : DotEdgeOperator?,
) -> Unit {
  match value {
    Some(v) => self.operator = v
    None => self.operator = DotEdgeOperatorDirected
  }
}

///|
pub fn DotEdgeTarget::get_target_subgraph(self : DotEdgeTarget) -> DotSubgraph? {
  self.target_subgraph
}

///|
pub fn DotEdgeTarget::set_target_subgraph(
  self : DotEdgeTarget,
  value : DotSubgraph?,
) -> Unit {
  self.target_subgraph = value
}

///|
pub fn DotEdgeTarget::get_targetnode(self : DotEdgeTarget) -> DotNode? {
  self.targetnode
}

///|
pub fn DotEdgeTarget::set_targetnode(
  self : DotEdgeTarget,
  value : DotNode?,
) -> Unit {
  self.targetnode = value
}
