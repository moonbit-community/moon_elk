///|
fn issue552_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue552_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue552 hierarchy self-loop ports are not left at y=0" {
  @graph.reset_graph_model_for_test()
  issue552_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 120.0, 80.0)

  let src_port = @graph.create_port(Some(node))
  @graph.port_set_dimensions(src_port, 10.0, 10.0)
  @graph.port_set_location(src_port, 5.0, 5.0)

  let dst_port = @graph.create_port(Some(node))
  @graph.port_set_dimensions(dst_port, 10.0, 10.0)
  @graph.port_set_location(dst_port, 15.0, 15.0)

  let self_loop = @graph.create_edge(None)
  @graph.edge_add_source(self_loop, @graph.make_port_shape(src_port))
  @graph.edge_add_target(self_loop, @graph.make_port_shape(dst_port))
  @runtime.layered_test_update_containment(Some(self_loop))

  issue552_test_layout(graph)

  for port in @graph.node_ports(node) {
    assert_true(@graph.port_y(port).abs() > 0.0)
  }
}
