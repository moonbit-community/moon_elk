///|
fn register_cycle_breaking_phase(
  registry : @runtime.LayeredPhaseRegistry,
  strategy : String,
  id : Int,
  create : () -> @core.TypedLayoutProcessor[@runtime.LGraph],
) -> Unit {
  registry.register_cycle_breaking_phase(strategy, id, create)
}

///|
pub fn register_cycle_breaking_phases(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  register_cycle_breaking_phase(
    registry, "DEPTH_FIRST", 21001, new_depth_first_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "INTERACTIVE", 21002, new_interactive_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "MODEL_ORDER", 21003, new_model_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "GREEDY_MODEL_ORDER", 21004, new_greedy_model_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "SCC_CONNECTIVITY", 21005, new_sc_connectivity_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "SCC_NODE_TYPE", 21006, new_scc_node_type_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "DFS_NODE_ORDER", 21007, new_dfs_node_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "BFS_NODE_ORDER", 21008, new_bfs_node_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    registry, "GREEDY", 21000, new_greedy_cycle_breaker_layout_phase,
  )
}
