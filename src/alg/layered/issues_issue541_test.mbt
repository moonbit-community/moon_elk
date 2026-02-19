///|
fn issue541_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue541 end-label sorting path does not throw" {
  reset_graph_model_for_test()
  issue541_test_setup_plain_java_layout()

  let graph = create_graph()
  let left = @graph.create_node(Some(graph))
  let right = @graph.create_node(Some(graph))
  let shared_target_port = create_port(Some(right))

  let edge1 = create_edge(None)
  edge_add_source(edge1, make_node_shape(left))
  edge_add_target(edge1, make_port_shape(shared_target_port))
  update_containment(Some(edge1))

  let edge2 = create_edge(None)
  edge_add_source(edge2, make_node_shape(right))
  edge_add_target(edge2, make_port_shape(shared_target_port))
  update_containment(Some(edge2))

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
