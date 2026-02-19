///|
fn layered_debug_util_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn layered_debug_util_test_graph_fixture() -> (LGraph, LNode, LNode, LEdge) {
  let graph = new_l_graph()

  let source_node = new_l_node(graph=Some(graph))
  source_node.set_id(1)
  ignore(source_node.get_size().set_xy(40.0, 20.0))

  let target_node = new_l_node(graph=Some(graph))
  target_node.set_id(2)
  ignore(target_node.get_position().set_xy(100.0, 0.0))
  ignore(target_node.get_size().set_xy(40.0, 20.0))

  graph.get_layerless_nodes().push(source_node)
  graph.get_layerless_nodes().push(target_node)

  let source_port = new_l_port()
  source_port.set_side(layered_debug_util_test_port_side("EAST"))
  source_node.add_port(source_port)

  let target_port = new_l_port()
  target_port.set_side(layered_debug_util_test_port_side("WEST"))
  target_node.add_port(target_port)

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  ignore(edge.get_bend_points().add_xy(60.0, 10.0))

  (graph, source_node, target_node, edge)
}

///|
test "Dot/Json debug graph generation for layered graph" {
  let (graph, _, _, _) = layered_debug_util_test_graph_fixture()

  let dot_text = dot_debug_util_create_debug_graph(graph)
  inspect(dot_text.contains("digraph"), content="true")
  inspect(dot_text.contains("rankdir=LR"), content="true")

  let json_text = json_debug_util_create_debug_graph(graph)
  inspect(json_text.contains("\"children\""), content="true")
  inspect(json_text.contains("\"edges\""), content="true")
}

///|
test "Dot/Json debug graph generation for segments and hypernodes" {
  let (graph, _, _, _) = layered_debug_util_test_graph_fixture()

  let dot_segment_text = dot_debug_util_create_debug_graph_linear_segments(
    graph,
    [],
    [],
  )
  inspect(dot_segment_text.contains("digraph"), content="true")

  let json_segment_text = json_debug_util_create_debug_graph_linear_segments(
    graph,
    [],
    [],
  )
  inspect(json_segment_text.contains("\"children\""), content="true")

  let strategy = new_west_to_east_routing_strategy()
  let hypernode_a = new_hyper_edge_segment(strategy)
  let hypernode_b = new_hyper_edge_segment(strategy)
  ignore(
    hyper_edge_segment_dependency_create_and_add_regular(
      hypernode_a, hypernode_b, 3,
    ),
  )

  let dot_hypernode_text = dot_debug_util_create_debug_graph_hypernodes(graph, [
    hypernode_a, hypernode_b,
  ])
  inspect(dot_hypernode_text.contains("->"), content="true")

  let json_hypernode_text = json_debug_util_create_debug_graph_hypernodes(
    graph,
    [hypernode_a, hypernode_b],
  )
  inspect(json_hypernode_text.contains("\"target\": \"n"), content="true")
}

///|
test "DebugUtil logs dot/json tags" {
  let monitor = new_elk_progress_monitor().with_logging(true)
  let (graph, _, _, _) = layered_debug_util_test_graph_fixture()

  let strategy = new_west_to_east_routing_strategy()
  let hypernode_a = new_hyper_edge_segment(strategy)
  let hypernode_b = new_hyper_edge_segment(strategy)
  ignore(
    hyper_edge_segment_dependency_create_and_add_regular(
      hypernode_a, hypernode_b, 1,
    ),
  )

  debug_util_log_debug_graph(monitor, graph, 3, "Before")
  debug_util_log_debug_graph_linear_segments(monitor, graph, [], [])
  debug_util_log_debug_graph_hypernodes(
    monitor,
    graph,
    0,
    [hypernode_a, hypernode_b],
    "orthogonal",
    "cycle",
  )

  let logged_graphs = monitor.get_logged_graphs()
  inspect(logged_graphs.length(), content="6")
  inspect(logged_graphs[0].tag.contains("[dot]"), content="true")
  inspect(logged_graphs[1].tag.contains("[json]"), content="true")
}
