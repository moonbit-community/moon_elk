///|
pub struct SporeGraph {
  vertices : Array[@common.Node]
  mut t_edges : @common.JavaTEdgeSet?
  tree_construction_strategy : SporeTreeConstructionStrategy
  mut tree : @common.Tree[@common.Node]?
  compaction_strategy : SporeCompactionStrategy
  cost_function : @common.ICostFunction
  mut preferred_root : @common.Node?
  mut orthogonal_compaction : Bool
  mut debug_svg : Bool
  mut overlaps_existed : Bool
}

///|
pub fn new_spore_graph(
  cost_function : @common.ICostFunction,
  tree_strategy : SporeTreeConstructionStrategy,
  compaction_strategy : SporeCompactionStrategy,
) -> SporeGraph {
  {
    vertices: [],
    t_edges: None,
    tree_construction_strategy: tree_strategy,
    tree: None,
    compaction_strategy,
    cost_function,
    preferred_root: None,
    orthogonal_compaction: false,
    debug_svg: false,
    overlaps_existed: false,
  }
}
