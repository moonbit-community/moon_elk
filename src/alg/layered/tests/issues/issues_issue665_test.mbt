///|
fn issue665_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue665 nested graph imports and layouts without unsupported graph errors" {
  @graph.reset_graph_model_for_test()
  issue665_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let parent = @graph.create_node(Some(graph))
  let child = @graph.create_node(Some(parent))
  let sibling = @graph.create_node(Some(graph))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_node_shape(child))
  @graph.edge_add_target(edge, @graph.make_node_shape(sibling))
  @layered.layered_test_update_containment(Some(edge))

  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
