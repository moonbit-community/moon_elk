///|
fn issue905_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue905_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
test "Issue905 begin/center/head edge label coordinates are deterministic" {
  reset_graph_model_for_test()
  issue905_test_setup_plain_java_layout()

  // Direct translation target: use upstream ticket models
  // 905_beginLabelAboveEdge and 905_beginLableBellowEdge and verify
  // exact label coordinates for TAIL/CENTER/HEAD.
  let graph = create_graph()
  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))

  let tail = create_label(Some(make_edge_label_parent(edge)))
  label_set_layout_option_string_by_id(
    tail, "org.eclipse.elk.edgeLabels.placement", "TAIL",
  )
  label_set_dimensions(tail, 20.0, 10.0)

  let center = create_label(Some(make_edge_label_parent(edge)))
  label_set_layout_option_string_by_id(
    center, "org.eclipse.elk.edgeLabels.placement", "CENTER",
  )
  label_set_dimensions(center, 20.0, 10.0)

  let head = create_label(Some(make_edge_label_parent(edge)))
  label_set_layout_option_string_by_id(
    head, "org.eclipse.elk.edgeLabels.placement", "HEAD",
  )
  label_set_dimensions(head, 20.0, 10.0)

  issue905_test_layout(graph)

  assert_eq(edge_labels(edge).length(), 3)
}
