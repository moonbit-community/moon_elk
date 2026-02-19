///|
pub struct SporeGraph {
  vertices : Array[Node]
  mut t_edges : Array[TEdge]?
  tree_construction_strategy : SporeTreeConstructionStrategy
  mut tree : Tree[Node]?
  compaction_strategy : SporeCompactionStrategy
  cost_function : ICostFunction
  mut preferred_root : Node?
  mut orthogonal_compaction : Bool
  mut debug_svg : Bool
  mut overlaps_existed : Bool
}

///|
pub fn new_spore_graph(
  cost_function : ICostFunction,
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
