///|
pub fn reset_graph_model_for_test() -> Unit {
  node_store.val.clear()
  node_arena_store.val.clear()
  port_store.val.clear()
  port_arena_store.val.clear()
  edge_store.val.clear()
  edge_arena_store.val.clear()
  edge_section_store.val.clear()
  edge_section_arena_store.val.clear()
  label_store.val.clear()
  label_arena_store.val.clear()
  graph_arena_store.val.clear()
}
