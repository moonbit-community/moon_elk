///|
fn issue548_test_setup_plain_java_layout() -> Unit {

}

///|
test "Issue548 inside self loops do not trigger NPE path" {
  issue548_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let node = @graph.create_node(Some(graph))
  let source_port = @graph.create_port(Some(node))
  let target_port = @graph.create_port(Some(node))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_port_shape(source_port))
  @graph.edge_add_target(edge, @graph.make_port_shape(target_port))
  @runtime.layered_test_update_containment(Some(edge))

  @graph.node_set_bool_property(node, @core.inside_self_loops_activate, true)
  @graph.edge_set_layout_option_string_by_id(
    edge, "org.eclipse.elk.insideSelfLoops.yo", "true",
  )

  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, @core.resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
