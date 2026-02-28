///|
pub type LayeredCGraph = @common.CGraph

///|
pub type LayeredCNodeBuilder = @common.CNodeBuilder

///|
pub type LayeredCGroupBuilder = @common.CGroupBuilder

///|
pub fn reset_layered_compaction_oned_model_for_test() -> Unit {
  @common.reset_compaction_oned_model_for_test()
}

///|
pub fn new_layered_c_graph(
  supported_directions : Array[@core.Direction],
) -> LayeredCGraph {
  @common.new_cgraph(supported_directions)
}

///|
pub fn layered_cnode_of() -> LayeredCNodeBuilder {
  @common.cnode_of()
}

///|
pub fn layered_cgroup_of() -> LayeredCGroupBuilder {
  @common.cgroup_of()
}
