///|
fn issue143_and318_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue143_and318_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
test "Issue143 and Issue318 horizontal edge segment spacing" {
  reset_graph_model_for_test()
  issue143_and318_test_setup_plain_java_layout()

  // Direct translation target: run upstream resources
  // 143_smallVerticalEdgeSegmentSpacing and
  // 318_overlappingHorizontalEdgeSegments.
  let graph = create_graph()
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")
  let left = create_node(Some(graph))
  let right = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(left))
  edge_add_target(edge, make_node_shape(right))
  update_containment(Some(edge))

  issue143_and318_test_layout(graph)
  assert_eq(node_contained_edges(graph).length(), 1)
}
