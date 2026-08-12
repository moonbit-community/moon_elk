///|
test "Dot/Json hypernode debug graph generation" {
  let graph = @runtime.new_l_graph()
  let strategy = new_west_to_east_routing_strategy()
  let hypernode_a = new_hyper_edge_segment(strategy)
  let hypernode_b = new_hyper_edge_segment(strategy)
  ignore(
    hyper_edge_segment_dependency_create_and_add_regular(
      hypernode_a, hypernode_b, 3,
    ),
  )
  let dot_text = dot_debug_util_create_debug_graph_hypernodes(graph, [
    hypernode_a, hypernode_b,
  ])
  inspect(dot_text.contains("->"), content="true")
  let json_text = json_debug_util_create_debug_graph_hypernodes(graph, [
    hypernode_a, hypernode_b,
  ])
  inspect(json_text.contains("\"target\": \"n"), content="true")
}

///|
test "Hypernode debug logging emits dot and json tags" {
  let monitor = new_elk_progress_monitor().with_logging(true)
  let graph = @runtime.new_l_graph()
  let strategy = new_west_to_east_routing_strategy()
  let hypernode_a = new_hyper_edge_segment(strategy)
  let hypernode_b = new_hyper_edge_segment(strategy)
  ignore(
    hyper_edge_segment_dependency_create_and_add_regular(
      hypernode_a, hypernode_b, 1,
    ),
  )
  debug_util_log_debug_graph_hypernodes(
    monitor,
    graph,
    0,
    [hypernode_a, hypernode_b],
    "orthogonal",
    "cycle",
  )
  let logged_graphs = monitor.get_logged_graphs()
  inspect(logged_graphs.length(), content="2")
  inspect(logged_graphs[0].tag.contains("[dot]"), content="true")
  inspect(logged_graphs[1].tag.contains("[json]"), content="true")
}
