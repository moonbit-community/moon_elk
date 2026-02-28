///|
fn issue552_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue552_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue552 hierarchy self-loop ports are not left at y=0" {
  reset_graph_model_for_test()
  issue552_test_setup_plain_java_layout()

  let graph = create_graph()
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 120.0, 80.0)

  let src_port = create_port(Some(node))
  port_set_dimensions(src_port, 10.0, 10.0)
  port_set_location(src_port, 5.0, 5.0)

  let dst_port = create_port(Some(node))
  port_set_dimensions(dst_port, 10.0, 10.0)
  port_set_location(dst_port, 15.0, 15.0)

  let self_loop = create_edge(None)
  edge_add_source(self_loop, make_port_shape(src_port))
  edge_add_target(self_loop, make_port_shape(dst_port))
  layered_test_update_containment(Some(self_loop))

  issue552_test_layout(graph)

  for port in @graph.node_ports(node) {
    assert_true(port_y(port).abs() > 0.0)
  }
}
