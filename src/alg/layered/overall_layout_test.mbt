///|
fn overall_layout_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn overall_layout_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn overall_layout_test_size_constraint_strings(
  constraints : Array[SizeConstraint],
) -> Array[String] {
  let values : Array[String] = []
  for constraint in constraints {
    values.push(size_constraint_to_string(constraint))
  }
  values
}

///|
fn overall_layout_test_create_simple_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")

  let fixed_constraints = overall_layout_test_size_constraint_strings(
    size_constraint_fixed(),
  )

  let node1 = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node1, 30.0, 30.0)
  node_set_string_set_property(node1, @core.node_size_constraints, fixed_constraints)

  let node2 = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node2, 30.0, 30.0)
  node_set_string_set_property(node2, @core.node_size_constraints, fixed_constraints)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(node1))
  edge_add_target(edge, make_node_shape(node2))
  update_containment(Some(edge))

  graph
}

///|
fn overall_layout_test_build_and_layout_simple_graph() -> @graph.ElkNode {
  reset_graph_model_for_test()
  overall_layout_test_setup_plain_java_layout()
  let graph = overall_layout_test_create_simple_graph()
  overall_layout_test_layout(graph)
  graph
}

///|
test "OverallLayoutTest node coordinates are positive" {
  let graph = overall_layout_test_build_and_layout_simple_graph()
  for node in @graph.node_children(graph) {
    assert_true(@graph.node_x(node) > 0.0)
    assert_true(@graph.node_y(node) > 0.0)
  }
}

///|
test "OverallLayoutTest edge coordinates are positive" {
  let graph = overall_layout_test_build_and_layout_simple_graph()
  for routed_edge in @graph.node_contained_edges(graph) {
    for section in @graph.edge_sections(routed_edge) {
      assert_true(@graph.edge_section_start_x(section) > 0.0)
      assert_true(@graph.edge_section_start_y(section) > 0.0)
      assert_true(@graph.edge_section_end_x(section) > 0.0)
      assert_true(@graph.edge_section_end_y(section) > 0.0)
    }
  }
}

///|
test "OverallLayoutTest graph size is positive" {
  let graph = overall_layout_test_build_and_layout_simple_graph()
  assert_true(@graph.node_width(graph) > 0.0)
  assert_true(@graph.node_height(graph) > 0.0)
}

///|
test "OverallLayoutTest edge routing is orthogonal" {
  let graph = overall_layout_test_build_and_layout_simple_graph()
  for routed_edge in @graph.node_contained_edges(graph) {
    for section in @graph.edge_sections(routed_edge) {
      assert_true(
        @graph.edge_section_start_x(section) == @graph.edge_section_end_x(section) ||
        @graph.edge_section_start_y(section) == @graph.edge_section_end_y(section),
      )
    }
  }
}
