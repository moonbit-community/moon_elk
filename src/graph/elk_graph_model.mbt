///|
pub fn reset_graph_model_for_test() -> Unit {
  node_store.val.clear()
  port_store.val.clear()
  edge_store.val.clear()
  edge_section_store.val.clear()
  label_store.val.clear()
}
