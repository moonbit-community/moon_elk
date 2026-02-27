///|
fn issue548_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue548 inside self loops do not trigger NPE path" {
  reset_graph_model_for_test()
  issue548_test_setup_plain_java_layout()

  let graph = create_graph()
  let node = @graph.create_node(Some(graph))
  let source_port = create_port(Some(node))
  let target_port = create_port(Some(node))
  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(source_port))
  edge_add_target(edge, make_port_shape(target_port))
  layered_test_update_containment(Some(edge))

  @graph.node_set_bool_property(node, @core.inside_self_loops_activate, true)
  edge_set_layout_option_string_by_id(
    edge, "org.eclipse.elk.insideSelfLoops.yo", "true",
  )

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  assert_eq(
    @graph.node_get_string_property(graph, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
