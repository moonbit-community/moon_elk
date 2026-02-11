///|
pub fn rectpacking_node_size_compare(node0 : ElkNode, node1 : ElkNode) -> Int {
  let h0 = node_height(node0)
  let h1 = node_height(node1)
  if h1 > h0 {
    1
  } else if h1 < h0 {
    -1
  } else {
    0
  }
}
