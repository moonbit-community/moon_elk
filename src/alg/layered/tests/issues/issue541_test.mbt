///|
fn issue541_test_setup_plain_java_layout() -> Unit {

}

///|
test "Issue541 end-label sorting path does not throw" {
  issue541_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let left = @graph.create_node(Some(graph))
  let right = @graph.create_node(Some(graph))
  let shared_target_port = @graph.create_port(Some(right))

  let edge1 = @graph.create_edge(None)
  @graph.edge_add_source(edge1, @graph.make_node_shape(left))
  @graph.edge_add_target(edge1, @graph.make_port_shape(shared_target_port))
  @runtime.layered_test_update_containment(Some(edge1))

  let edge2 = @graph.create_edge(None)
  @graph.edge_add_source(edge2, @graph.make_node_shape(right))
  @graph.edge_add_target(edge2, @graph.make_port_shape(shared_target_port))
  @runtime.layered_test_update_containment(Some(edge2))

  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
