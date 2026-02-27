///|
fn p2_basic_model_order_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn p2_basic_model_order_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "BasicModelOrder strategies run without layout errors" {
  reset_graph_model_for_test()
  p2_basic_model_order_test_setup_plain_java_layout()

  let graph = create_graph()
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.cycleBreaking.strategy", "MODEL_ORDER",
  )
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.layering.strategy", "BF_MODEL_ORDER",
  )

  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  layered_test_update_containment(Some(edge))

  p2_basic_model_order_test_layout(graph)

  assert_eq(
    @graph.node_get_string_property(graph, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
