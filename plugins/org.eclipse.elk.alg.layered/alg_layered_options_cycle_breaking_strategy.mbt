///|
pub enum CycleBreakingStrategy {
  CbsGreedy
  CbsDepthFirst
  CbsInteractive
  CbsModelOrder
  CbsGreedyModelOrder
  CbsSccConnectivity
  CbsSccNodeType
  CbsDfsNodeOrder
  CbsBfsNodeOrder
}

///|
pub fn cycle_breaking_strategy_to_string(
  value : CycleBreakingStrategy,
) -> String {
  match value {
    CbsGreedy => "GREEDY"
    CbsDepthFirst => "DEPTH_FIRST"
    CbsInteractive => "INTERACTIVE"
    CbsModelOrder => "MODEL_ORDER"
    CbsGreedyModelOrder => "GREEDY_MODEL_ORDER"
    CbsSccConnectivity => "SCC_CONNECTIVITY"
    CbsSccNodeType => "SCC_NODE_TYPE"
    CbsDfsNodeOrder => "DFS_NODE_ORDER"
    CbsBfsNodeOrder => "BFS_NODE_ORDER"
  }
}

///|
pub fn cycle_breaking_strategy_values() -> Array[String] {
  [
    cycle_breaking_strategy_to_string(CbsGreedy),
    cycle_breaking_strategy_to_string(CbsDepthFirst),
    cycle_breaking_strategy_to_string(CbsInteractive),
    cycle_breaking_strategy_to_string(CbsModelOrder),
    cycle_breaking_strategy_to_string(CbsGreedyModelOrder),
    cycle_breaking_strategy_to_string(CbsSccConnectivity),
    cycle_breaking_strategy_to_string(CbsSccNodeType),
    cycle_breaking_strategy_to_string(CbsDfsNodeOrder),
    cycle_breaking_strategy_to_string(CbsBfsNodeOrder),
  ]
}
