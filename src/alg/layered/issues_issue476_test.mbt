///|
fn issue476_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue476_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue476 node labels remain horizontally centered" {
  reset_graph_model_for_test()
  issue476_test_setup_plain_java_layout()

  let graph = create_graph()
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 80.0, 40.0)

  let label_a = @graph.create_label(Some(make_node_label_parent(node)))
  @graph.label_set_text(label_a, "A")
  @graph.label_set_dimensions(label_a, 20.0, 10.0)
  @graph.label_set_location(label_a, 30.0, 0.0)

  let label_b = @graph.create_label(Some(make_node_label_parent(node)))
  @graph.label_set_text(label_b, "B")
  @graph.label_set_dimensions(label_b, 20.0, 10.0)
  @graph.label_set_location(label_b, 30.0, 12.0)

  issue476_test_layout(graph)

  for label in node_labels(node) {
    let center = @graph.label_x(label) + @graph.label_width(label) / 2.0
    assert_true((center - @graph.node_width(node) / 2.0).abs() <= 0.5)
  }
}
