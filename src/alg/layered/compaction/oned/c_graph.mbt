///|
pub type LayeredCGraph = @compaction.CGraph

///|
pub type LayeredCNodeBuilder = @compaction.CNodeBuilder

///|
pub type LayeredCGroupBuilder = @compaction.CGroupBuilder

///|
pub fn reset_layered_compaction_oned_model_for_test() -> Unit {
  @compaction.reset_compaction_oned_model_for_test()
}

///|
pub fn new_layered_c_graph(
  supported_directions : Array[@core.Direction],
) -> LayeredCGraph {
  @compaction.new_cgraph(supported_directions)
}

///|
pub fn layered_cnode_of() -> LayeredCNodeBuilder {
  @compaction.cnode_of()
}

///|
pub fn layered_cgroup_of() -> LayeredCGroupBuilder {
  @compaction.cgroup_of()
}
