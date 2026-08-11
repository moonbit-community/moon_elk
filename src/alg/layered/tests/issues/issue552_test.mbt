///|
fn issue552_test_setup_plain_java_layout() -> Unit {

}

///|
fn issue552_test_layout(graph : @graph.ElkNode) -> Unit {
  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue552 hierarchy self-loop ports are not left at y=0" {
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
