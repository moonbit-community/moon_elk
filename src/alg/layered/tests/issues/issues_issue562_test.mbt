///|
fn issue562_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue562 inside self loops options do not fail layout" {
  @graph.reset_graph_model_for_test()
  issue562_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let node = @graph.create_node(Some(graph))
  let source_port = @graph.create_port(Some(node))
  let target_port = @graph.create_port(Some(node))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_port_shape(source_port))
  @graph.edge_add_target(edge, @graph.make_port_shape(target_port))
  @layered.layered_test_update_containment(Some(edge))

  @graph.node_set_bool_property(node, @core.inside_self_loops_activate, true)
  @graph.edge_set_layout_option_string_by_id(
    edge, "org.eclipse.elk.insideSelfLoops.yo", "true",
  )

  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
