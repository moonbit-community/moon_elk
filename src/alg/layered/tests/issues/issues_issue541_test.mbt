///|
fn issue541_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue541 end-label sorting path does not throw" {
  @graph.reset_graph_model_for_test()
  issue541_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let left = @graph.create_node(Some(graph))
  let right = @graph.create_node(Some(graph))
  let shared_target_port = @graph.create_port(Some(right))

  let edge1 = @graph.create_edge(None)
  @graph.edge_add_source(edge1, @graph.make_node_shape(left))
  @graph.edge_add_target(edge1, @graph.make_port_shape(shared_target_port))
  @layered.layered_test_update_containment(Some(edge1))

  let edge2 = @graph.create_edge(None)
  @graph.edge_add_source(edge2, @graph.make_node_shape(right))
  @graph.edge_add_target(edge2, @graph.make_port_shape(shared_target_port))
  @layered.layered_test_update_containment(Some(edge2))

  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
