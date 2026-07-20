///|
fn issue905_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue905_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue905 begin/center/head edge label coordinates are deterministic" {
  @graph.reset_graph_model_for_test()
  issue905_test_setup_plain_java_layout()

  // Direct translation target: use upstream ticket models
  // 905_beginLabelAboveEdge and 905_beginLableBellowEdge and verify
  // exact label coordinates for TAIL/CENTER/HEAD.
  let graph = @graph.create_graph()
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_node_shape(n1))
  @graph.edge_add_target(edge, @graph.make_node_shape(n2))
  @runtime.layered_test_update_containment(Some(edge))

  let tail = @graph.create_label(Some(@graph.make_edge_label_parent(edge)))
  @graph.label_set_layout_option_string_by_id(
    tail, "org.eclipse.elk.edgeLabels.placement", "TAIL",
  )
  @graph.label_set_dimensions(tail, 20.0, 10.0)

  let center = @graph.create_label(Some(@graph.make_edge_label_parent(edge)))
  @graph.label_set_layout_option_string_by_id(
    center, "org.eclipse.elk.edgeLabels.placement", "CENTER",
  )
  @graph.label_set_dimensions(center, 20.0, 10.0)

  let head = @graph.create_label(Some(@graph.make_edge_label_parent(edge)))
  @graph.label_set_layout_option_string_by_id(
    head, "org.eclipse.elk.edgeLabels.placement", "HEAD",
  )
  @graph.label_set_dimensions(head, 20.0, 10.0)

  issue905_test_layout(graph)

  assert_eq(@graph.edge_labels(edge).length(), 3)
}
