///|
fn issue870_test_setup_plain_java_layout() -> Unit {

}

///|
test "Issue870 edge configuration does not fail layout" {
  issue870_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))
  let e1 = @graph.create_edge(None)
  @graph.edge_add_source(e1, @graph.make_node_shape(n1))
  @graph.edge_add_target(e1, @graph.make_node_shape(n2))
  @runtime.layered_test_update_containment(Some(e1))
  let e2 = @graph.create_edge(None)
  @graph.edge_add_source(e2, @graph.make_node_shape(n2))
  @graph.edge_add_target(e2, @graph.make_node_shape(n3))
  @runtime.layered_test_update_containment(Some(e2))
  let e3 = @graph.create_edge(None)
  @graph.edge_add_source(e3, @graph.make_node_shape(n1))
  @graph.edge_add_target(e3, @graph.make_node_shape(n3))
  @runtime.layered_test_update_containment(Some(e3))

  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
