///|
test "graph info holder disposal breaks crossing minimizer ownership cycle" {
  let graph = new_l_graph()
  let node = new_l_node()
  graph.get_layerless_nodes().push(node)
  node.set_graph(Some(graph))
  let holder = new_graph_info_holder_from_graph(graph, TwoSidedGreedySwitch, [])

  assert_true(holder.cross_minimizer_ref is Some(_))
  assert_true(holder.l_graph_ref is Some(_))

  holder.dispose()

  assert_true(holder.cross_minimizer_ref is None)
  assert_true(holder.l_graph_ref is Some(_))
}
