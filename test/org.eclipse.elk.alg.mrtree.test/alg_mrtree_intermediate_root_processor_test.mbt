///|
fn mrtree_root_processor_test_find_node_by_label(
  graph : MrtreeGraph,
  label : String,
) -> MrtreeNode? {
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_label(node) == label {
      return Some(node)
    }
  }
  None
}

///|
fn mrtree_root_processor_test_require_node_by_label(
  graph : MrtreeGraph,
  label : String,
) -> MrtreeNode {
  match mrtree_root_processor_test_find_node_by_label(graph, label) {
    Some(node) => node
    None => abort("missing node: " + label)
  }
}

///|
test "Mrtree RootProcessor creates DUMMY_ROOT when no roots exist" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  let n0 = new_mrtree_node(0, graph, label="n0")
  let n1 = new_mrtree_node(1, graph, label="n1")
  ignore(new_mrtree_edge(n0, n1))
  ignore(new_mrtree_edge(n1, n0))

  new_mrtree_root_processor_layout_processor().process(
    graph,
    Some(new_basic_progress_monitor()),
  )

  inspect(mrtree_graph_nodes(graph).length(), content="3")

  let dummy_root = mrtree_root_processor_test_require_node_by_label(
    graph, "DUMMY_ROOT",
  )
  inspect(mrtree_node_root(dummy_root), content="true")
  inspect(mrtree_node_dummy(dummy_root), content="true")
  inspect(mrtree_node_outgoing_edges(dummy_root).length(), content="0")
}

///|
test "Mrtree RootProcessor creates SUPER_ROOT for multiple roots" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  let n0 = new_mrtree_node(0, graph, label="n0")
  let n1 = new_mrtree_node(1, graph, label="n1")

  new_mrtree_root_processor_layout_processor().process(
    graph,
    Some(new_basic_progress_monitor()),
  )

  inspect(mrtree_graph_nodes(graph).length(), content="3")

  let super_root = mrtree_root_processor_test_require_node_by_label(
    graph, "SUPER_ROOT",
  )
  inspect(mrtree_node_root(super_root), content="true")
  inspect(mrtree_node_dummy(super_root), content="true")
  inspect(mrtree_node_outgoing_edges(super_root).length(), content="2")

  inspect(mrtree_node_root(n0), content="false")
  inspect(mrtree_node_root(n1), content="false")
  inspect(mrtree_node_incoming_edges(n0).length(), content="1")
  inspect(mrtree_node_incoming_edges(n1).length(), content="1")
}
