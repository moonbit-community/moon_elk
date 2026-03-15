///|
test "Mrtree EdgeRouter middle-to-middle routes to node borders" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  mrtree_graph_set_edge_routing_mode(graph, "MIDDLE_TO_MIDDLE")

  let source = new_mrtree_node(0, graph)
  let target = new_mrtree_node(1, graph)
  ignore(mrtree_node_position(source).set_xy(0.0, 0.0))
  ignore(mrtree_node_size(source).set_xy(10.0, 10.0))
  ignore(mrtree_node_position(target).set_xy(20.0, 20.0))
  ignore(mrtree_node_size(target).set_xy(10.0, 10.0))

  let edge = new_mrtree_edge(source, target)
  new_mrtree_edge_router_layout_phase().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )

  let bends = mrtree_edge_bend_points(edge)
  inspect(bends.size(), content="0")
}
