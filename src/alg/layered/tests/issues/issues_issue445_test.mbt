///|
fn issue445_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
test "Issue445 feedback edge tail labels are not left at origin" {
  @graph.reset_graph_model_for_test()
  issue445_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.padding", "[left=0,top=0,right=0,bottom=0]",
  )

  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_node_shape(n1))
  @graph.edge_add_target(edge, @graph.make_node_shape(n2))
  @layered.layered_test_update_containment(Some(edge))

  let tail_label = @graph.create_label(
    Some(@graph.make_edge_label_parent(edge)),
  )
  @graph.label_set_text(tail_label, "tail")
  @graph.label_set_layout_option_string_by_id(
    tail_label, "org.eclipse.elk.edgeLabels.placement", "TAIL",
  )
  @graph.label_set_dimensions(tail_label, 20.0, 10.0)

  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())

  let misplaced = @graph.label_x(tail_label).abs() <= 0.0001 &&
    @graph.label_y(tail_label).abs() <= 0.0001
  assert_false(misplaced)
}
