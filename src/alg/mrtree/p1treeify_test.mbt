///|
priv struct MrtreeCycleFixture {
  graph : MrtreeGraph
  n0 : MrtreeNode
  n1 : MrtreeNode
  n2 : MrtreeNode
  e20 : MrtreeEdge
}

///|
fn mrtree_build_cycle_fixture(search_order : String) -> MrtreeCycleFixture {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  mrtree_graph_set_search_order(graph, search_order)
  let n0 = new_mrtree_node(0, graph)
  let n1 = new_mrtree_node(1, graph)
  let n2 = new_mrtree_node(2, graph)
  ignore(new_mrtree_edge(n0, n1))
  ignore(new_mrtree_edge(n1, n2))
  let e20 = new_mrtree_edge(n2, n0)
  { graph, n0, n1, n2, e20 }
}

///|
test "Mrtree DFSTreeifyer removes DFS back edge" {
  let fixture = mrtree_build_cycle_fixture("DFS")
  let phase = new_mrtree_dfs_treeifyer_layout_phase()
  phase.process(fixture.graph, Some(@core.new_basic_progress_monitor()))

  inspect(mrtree_graph_edges(fixture.graph).length(), content="3")
  inspect(mrtree_graph_removable_edges(fixture.graph).length(), content="1")
  inspect(
    mrtree_node_outgoing_edges(fixture.n2).contains(fixture.e20),
    content="false",
  )
  inspect(
    mrtree_node_incoming_edges(fixture.n0).contains(fixture.e20),
    content="false",
  )
}

///|
test "Mrtree DFSTreeifyer removes BFS back edge" {
  let fixture = mrtree_build_cycle_fixture("BFS")
  let phase = new_mrtree_dfs_treeifyer_layout_phase()
  phase.process(fixture.graph, Some(@core.new_basic_progress_monitor()))

  inspect(mrtree_graph_edges(fixture.graph).length(), content="3")
  inspect(mrtree_graph_removable_edges(fixture.graph).length(), content="1")
  inspect(
    mrtree_node_outgoing_edges(fixture.n2).contains(fixture.e20),
    content="false",
  )
  inspect(
    mrtree_node_incoming_edges(fixture.n0).contains(fixture.e20),
    content="false",
  )
}

///|
test "Mrtree pipeline detreeifies removed edges" {
  let fixture = mrtree_build_cycle_fixture("DFS")
  let tree = new_mrtree()
  ignore(tree.do_layout(fixture.graph, @core.new_basic_progress_monitor()))

  inspect(mrtree_graph_removable_edges(fixture.graph).length(), content="1")
  inspect(
    mrtree_node_outgoing_edges(fixture.n2).contains(fixture.e20),
    content="true",
  )
  inspect(
    mrtree_node_incoming_edges(fixture.n0).contains(fixture.e20),
    content="true",
  )
}
