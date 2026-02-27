///|
fn issue726_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue726_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue726_test_section_is_orthogonal(section : @graph.ElkEdgeSection) -> Bool {
  let tolerance = 0.01
  (@graph.edge_section_start_x(section) - @graph.edge_section_end_x(section)).abs() <=
  tolerance ||
  (@graph.edge_section_start_y(section) - @graph.edge_section_end_y(section)).abs() <=
  tolerance
}

///|
test "Issue726 orthogonal routing never emits diagonal sections" {
  reset_graph_model_for_test()
  issue726_test_setup_plain_java_layout()

  let graph = create_graph()
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")

  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(n1))
  edge_add_target(e1, make_node_shape(n2))
  layered_test_update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(n2))
  edge_add_target(e2, make_node_shape(n3))
  layered_test_update_containment(Some(e2))

  issue726_test_layout(graph)

  for edge in @graph.node_contained_edges(graph) {
    for section in @graph.edge_sections(edge) {
      assert_true(issue726_test_section_is_orthogonal(section))
    }
  }
}
