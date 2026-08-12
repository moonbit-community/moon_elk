///|
test "node identity distinguishes equal local ids across arenas" {
  let first = @graph.create_graph()
  let second = @graph.create_graph()
  let nodes : Map[@graph.ElkNode, String] = Map([])
  nodes[first] = "first"
  nodes[second] = "second"
  assert_false(first == second)
  assert_eq(nodes.length(), 2)
  assert_eq(nodes[first], "first")
  assert_eq(nodes[second], "second")
  @graph.dispose_graph(first)
  @graph.dispose_graph(second)
}
