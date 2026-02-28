///|
test "Mrtree Untreeifyer reinserts removable edges without deduplication" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  let source = new_mrtree_node(0, graph, label="source")
  let target = new_mrtree_node(1, graph, label="target")
  let edge = new_mrtree_edge(source, target)

  mrtree_node_remove_outgoing_edge(source, edge)
  mrtree_node_remove_incoming_edge(target, edge)
  mrtree_graph_set_removable_edges(graph, [edge, edge])

  inspect(mrtree_node_outgoing_edges(source).length(), content="0")
  inspect(mrtree_node_incoming_edges(target).length(), content="0")

  new_mrtree_untreeifyer_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )

  inspect(mrtree_node_outgoing_edges(source).length(), content="2")
  inspect(mrtree_node_incoming_edges(target).length(), content="2")
}
