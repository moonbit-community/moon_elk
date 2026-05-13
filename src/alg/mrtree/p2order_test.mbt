///|
fn mrtree_run_p2_processors(graph : MrtreeGraph) -> Unit {
  new_mrtree_root_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_fan_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_level_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_node_orderer_layout_phase().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
}

///|
test "Mrtree NodeOrderer FAN weighting follows fan/leaf strategy" {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  mrtree_graph_set_weighting(graph, "FAN")

  let root = new_mrtree_node(0, graph)
  let a = new_mrtree_node(1, graph)
  let b = new_mrtree_node(2, graph)
  let c = new_mrtree_node(3, graph)
  let a1 = new_mrtree_node(4, graph)
  let a2 = new_mrtree_node(5, graph)
  let b1 = new_mrtree_node(6, graph)

  ignore(new_mrtree_edge(root, a))
  ignore(new_mrtree_edge(root, b))
  ignore(new_mrtree_edge(root, c))
  ignore(new_mrtree_edge(a, a1))
  ignore(new_mrtree_edge(a, a2))
  ignore(new_mrtree_edge(b, b1))

  mrtree_run_p2_processors(graph)

  debug_inspect(mrtree_node_position_in_level(a), content="0")
  debug_inspect(mrtree_node_position_in_level(b), content="2")
  debug_inspect(mrtree_node_position_in_level(c), content="1")
  debug_inspect(
    [
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[0])),
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[1])),
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[2])),
    ],
    content="[2, 3, 1]",
  )
}

///|
test "Mrtree NodeOrderer CONSTRAINT weighting enforces position constraints" {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  mrtree_graph_set_weighting(graph, "CONSTRAINT")

  let root = new_mrtree_node(0, graph)
  let n0 = new_mrtree_node(1, graph)
  let n1 = new_mrtree_node(2, graph)
  let n2 = new_mrtree_node(3, graph)

  mrtree_node_set_position_constraint(n0, 2)
  mrtree_node_set_position_constraint(n1, 0)
  mrtree_node_set_position_constraint(n2, -1)

  ignore(new_mrtree_edge(root, n0))
  ignore(new_mrtree_edge(root, n1))
  ignore(new_mrtree_edge(root, n2))

  mrtree_run_p2_processors(graph)

  debug_inspect(mrtree_node_position_in_level(n1), content="0")
  debug_inspect(mrtree_node_position_in_level(n2), content="1")
  debug_inspect(mrtree_node_position_in_level(n0), content="2")
  debug_inspect(
    [
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[0])),
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[1])),
      mrtree_node_id(mrtree_edge_target(mrtree_node_outgoing_edges(root)[2])),
    ],
    content="[2, 3, 1]",
  )
}
