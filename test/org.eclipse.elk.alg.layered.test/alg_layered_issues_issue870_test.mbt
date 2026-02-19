///|
fn issue870_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue870 edge configuration does not fail layout" {
  reset_graph_model_for_test()
  issue870_test_setup_plain_java_layout()

  let graph = create_graph()
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let n3 = create_node(Some(graph))
  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(n1))
  edge_add_target(e1, make_node_shape(n2))
  update_containment(Some(e1))
  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(n2))
  edge_add_target(e2, make_node_shape(n3))
  update_containment(Some(e2))
  let e3 = create_edge(None)
  edge_add_source(e3, make_node_shape(n1))
  edge_add_target(e3, make_node_shape(n3))
  update_containment(Some(e3))

  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())

  assert_eq(
    node_get_string_property(graph, resolved_algorithm),
    "org.eclipse.elk.layered",
  )
}
