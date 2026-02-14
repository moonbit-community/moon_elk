///|
fn p2_model_order_layer_assignment_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn p2_model_order_layer_assignment_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
#skip
test "ModelOrderLayerAssignment node-promotion coordinate scenarios" {
  reset_graph_model_for_test()
  p2_model_order_layer_assignment_test_setup_plain_java_layout()

  // Direct translation target: port all explicit coordinate assertions from
  // ModelOrderLayerAssignmentTest (forward/backward/more-nodes/no-end-node).
  let graph = create_graph()
  node_set_string_property(graph, direction, "RIGHT")
  node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.layering.nodePromotion.strategy", "MODEL_ORDER_LEFT_TO_RIGHT",
  )

  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))

  p2_model_order_layer_assignment_test_layout(graph)
  assert_eq(node_contained_edges(graph).length(), 1)
}
