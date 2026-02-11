///|
pub type LayeredCGraph = CGraph

///|
pub type LayeredCNodeBuilder = CNodeBuilder

///|
pub type LayeredCGroupBuilder = CGroupBuilder

///|
pub fn reset_layered_compaction_oned_model_for_test() -> Unit {
  reset_compaction_oned_model_for_test()
}

///|
pub fn new_layered_c_graph(
  supported_directions : Array[Direction],
) -> LayeredCGraph {
  new_cgraph(supported_directions)
}

///|
pub fn layered_cnode_of() -> LayeredCNodeBuilder {
  cnode_of()
}

///|
pub fn layered_cgroup_of() -> LayeredCGroupBuilder {
  cgroup_of()
}
