///|
fn register_cycle_breaking_phase(
  strategy : String,
  id : Int,
  create : () -> @core.ILayoutProcessor[@runtime.LayeredPhases, @runtime.LGraph],
) -> Unit {
  @runtime.register_layered_cycle_breaking_phase(
    strategy,
    @core.new_layout_processor_factory(id, 0, create),
  )
}

///|
fn init {
  register_cycle_breaking_phase(
    "DEPTH_FIRST", 21001, new_depth_first_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "INTERACTIVE", 21002, new_interactive_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "MODEL_ORDER", 21003, new_model_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "GREEDY_MODEL_ORDER", 21004, new_greedy_model_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "SCC_CONNECTIVITY", 21005, new_sc_connectivity_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "SCC_NODE_TYPE", 21006, new_scc_node_type_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "DFS_NODE_ORDER", 21007, new_dfs_node_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "BFS_NODE_ORDER", 21008, new_bfs_node_order_cycle_breaker_layout_phase,
  )
  register_cycle_breaking_phase(
    "GREEDY", 21000, new_greedy_cycle_breaker_layout_phase,
  )
}

///|
/// Referencing this marker ensures that the cycle phase package, including its
/// registration initializer, is linked into the final program.
pub let cycle_phase_linked : Bool = true
