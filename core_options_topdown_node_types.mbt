///|
pub enum TopdownNodeTypes {
  ParallelNode
  HierarchicalNode
  RootNode
}

///|
pub fn topdown_node_type_to_string(node_type : TopdownNodeTypes) -> String {
  match node_type {
    ParallelNode => "PARALLEL_NODE"
    HierarchicalNode => "HIERARCHICAL_NODE"
    RootNode => "ROOT_NODE"
  }
}
