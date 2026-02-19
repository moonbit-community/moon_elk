///|
pub fn rectpacking_node_size_compare(
  node0 : @graph.ElkNode,
  node1 : @graph.ElkNode,
) -> Int {
  let h0 = @graph.node_height(node0)
  let h1 = @graph.node_height(node1)
  if h1 > h0 {
    1
  } else if h1 < h0 {
    -1
  } else {
    0
  }
}
