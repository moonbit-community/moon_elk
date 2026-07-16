///|
fn issue870_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue870 edge configuration does not fail layout" {
  @graph.reset_graph_model_for_test()
  issue870_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))
  let e1 = @graph.create_edge(None)
  @graph.edge_add_source(e1, @graph.make_node_shape(n1))
  @graph.edge_add_target(e1, @graph.make_node_shape(n2))
  @layered.layered_test_update_containment(Some(e1))
  let e2 = @graph.create_edge(None)
  @graph.edge_add_source(e2, @graph.make_node_shape(n2))
  @graph.edge_add_target(e2, @graph.make_node_shape(n3))
  @layered.layered_test_update_containment(Some(e2))
  let e3 = @graph.create_edge(None)
  @graph.edge_add_source(e3, @graph.make_node_shape(n1))
  @graph.edge_add_target(e3, @graph.make_node_shape(n3))
  @layered.layered_test_update_containment(Some(e3))

  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
