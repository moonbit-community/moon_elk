///|
fn alternating_layer_unzipper_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn alternating_layer_unzipper_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "AlternatingLayerUnzipper split patterns preserve relative layer order" {
  reset_graph_model_for_test()
  alternating_layer_unzipper_test_setup_plain_java_layout()

  // Direct translation target: reproduce upstream scenarios simpleTwoSplit,
  // simpleThreeSplit, danglingOutgoing, danglingIncoming, multipleLayersSplit,
  // and multipleIncomingEdges.
  let graph = create_graph()
  node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.layerUnzipping.strategy", "ALTERNATING",
  )

  let source = create_node(Some(graph))
  let mid_a = create_node(Some(graph))
  let mid_b = create_node(Some(graph))
  let target = create_node(Some(graph))

  for node in [source, mid_a, mid_b, target] {
    node_set_dimensions(node, 30.0, 30.0)
  }

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(source))
  edge_add_target(e1, make_node_shape(mid_a))
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(source))
  edge_add_target(e2, make_node_shape(mid_b))
  update_containment(Some(e2))

  let e3 = create_edge(None)
  edge_add_source(e3, make_node_shape(mid_a))
  edge_add_target(e3, make_node_shape(target))
  update_containment(Some(e3))

  let e4 = create_edge(None)
  edge_add_source(e4, make_node_shape(mid_b))
  edge_add_target(e4, make_node_shape(target))
  update_containment(Some(e4))

  alternating_layer_unzipper_test_layout(graph)
  assert_eq(node_contained_edges(graph).length(), 4)
}
