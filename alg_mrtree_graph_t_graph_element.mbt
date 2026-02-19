///|
pub fn reset_mrtree_graph_model_for_test() -> Unit {
  mrtree_graph_store.val.clear()
  mrtree_node_store.val.clear()
  mrtree_edge_store.val.clear()
  mrtree_label_store.val.clear()
}
