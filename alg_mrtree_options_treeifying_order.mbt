///|
pub enum MrtreeTreeifyingOrder {
  DFS
  BFS
}

///|
pub fn mrtree_treeifying_order_from_string(
  value : String,
) -> MrtreeTreeifyingOrder {
  if value == "BFS" {
    MrtreeTreeifyingOrder::BFS
  } else {
    MrtreeTreeifyingOrder::DFS
  }
}
