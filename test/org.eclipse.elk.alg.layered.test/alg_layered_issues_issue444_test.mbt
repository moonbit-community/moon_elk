///|
fn issue444_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue444 self-loop graph does not throw during layout" {
  reset_graph_model_for_test()
  issue444_test_setup_plain_java_layout()

  let graph = create_graph()
  let node = create_node(Some(graph))
  let source_port = create_port(Some(node))
  let target_port = create_port(Some(node))
  let edge = create_edge(None)
  edge_add_source(edge, make_port_shape(source_port))
  edge_add_target(edge, make_port_shape(target_port))
  update_containment(Some(edge))

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())

  assert_eq(
    node_get_string_property(graph, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
