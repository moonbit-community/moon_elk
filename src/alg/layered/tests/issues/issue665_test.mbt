///|
fn issue665_test_setup_plain_java_layout() -> Unit {

}

///|
test "Issue665 nested graph imports and layouts without unsupported graph errors" {
  issue665_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let parent = @graph.create_node(Some(graph))
  let child = @graph.create_node(Some(parent))
  let sibling = @graph.create_node(Some(graph))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_node_shape(child))
  @graph.edge_add_target(edge, @graph.make_node_shape(sibling))
  @runtime.layered_test_update_containment(Some(edge))

  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
