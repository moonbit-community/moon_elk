///|
fn issue587_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue587_test_build_graph(edge_routing_value : String) -> ElkNode {
  let graph = create_graph()
  node_set_string_property(graph, edge_routing, edge_routing_value)
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))
  graph
}

///|
test "Issue587 all edge-routing strategies avoid exception" {
  reset_graph_model_for_test()
  issue587_test_setup_plain_java_layout()

  for routing in ["ORTHOGONAL", "POLYLINE", "SPLINES"] {
    let graph = issue587_test_build_graph(routing)
    let resolver = new_layout_algorithm_resolver()
    apply_visitors(graph, [resolver.to_visitor()])
    let layout_engine = new_recursive_graph_layout_engine()
    layout_engine.layout(graph, new_null_elk_progress_monitor())
    assert_eq(
      node_get_string_property(graph, resolved_algorithm),
      "org.eclipse.elk.layered",
    )
  }
}
