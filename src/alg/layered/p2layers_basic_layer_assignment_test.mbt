///|
fn p2_basic_layer_assignment_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn p2_basic_layer_assignment_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn p2_basic_layer_assignment_test_build_dag() -> Array[@graph.ElkNode] {
  let graph = create_graph()
  let n0 = @graph.create_node(Some(graph))
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))
  let n4 = @graph.create_node(Some(graph))

  @graph.node_set_dimensions(n0, 16.0, 10.0)
  @graph.node_set_dimensions(n1, 16.0, 10.0)
  @graph.node_set_dimensions(n2, 16.0, 10.0)
  @graph.node_set_dimensions(n3, 16.0, 10.0)
  @graph.node_set_dimensions(n4, 16.0, 10.0)

  let e0 = create_edge(None)
  edge_add_source(e0, make_node_shape(n0))
  edge_add_target(e0, make_node_shape(n2))
  update_containment(Some(e0))

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(n1))
  edge_add_target(e1, make_node_shape(n2))
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(n2))
  edge_add_target(e2, make_node_shape(n3))
  update_containment(Some(e2))

  let e3 = create_edge(None)
  edge_add_source(e3, make_node_shape(n2))
  edge_add_target(e3, make_node_shape(n4))
  update_containment(Some(e3))

  let e4 = create_edge(None)
  edge_add_source(e4, make_node_shape(n1))
  edge_add_target(e4, make_node_shape(n4))
  update_containment(Some(e4))

  [graph, n0, n1, n2, n3, n4]
}

///|
fn p2_basic_layer_assignment_test_has_forward_x_for_all_edges(
  nodes : Array[@graph.ElkNode],
) -> Bool {
  let edge_pairs = [[1, 3], [2, 3], [3, 4], [3, 5], [2, 5]]
  for edge_pair in edge_pairs {
    let source_index = edge_pair[0]
    let target_index = edge_pair[1]
    if @graph.node_x(nodes[source_index]) >= @graph.node_x(nodes[target_index]) {
      return false
    }
  }
  true
}

///|
fn p2_basic_layer_assignment_test_set_interactive_positions(
  nodes : Array[@graph.ElkNode],
) -> Unit {
  @graph.node_set_location(nodes[1], 113.0, 907.0)
  @graph.node_set_location(nodes[2], 257.0, 121.0)
  @graph.node_set_location(nodes[3], 421.0, 743.0)
  @graph.node_set_location(nodes[4], 619.0, 337.0)
  @graph.node_set_location(nodes[5], 811.0, 529.0)
}

///|
fn p2_basic_layer_assignment_test_layout_ok_for_strategy(
  strategy : String,
) -> Bool {
  reset_graph_model_for_test()
  p2_basic_layer_assignment_test_setup_plain_java_layout()

  let nodes = p2_basic_layer_assignment_test_build_dag()
  let graph = nodes[0]
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.layering.strategy", strategy,
  )
  if strategy == "INTERACTIVE" {
    p2_basic_layer_assignment_test_set_interactive_positions(nodes)
  }

  p2_basic_layer_assignment_test_layout(graph)

  let algorithm_resolved = @graph.node_get_string_property(
      graph, resolved_algorithm,
    ) ==
    "org.eclipse.elk.layered"
  let edges_point_forward = p2_basic_layer_assignment_test_has_forward_x_for_all_edges(
    nodes,
  )
  algorithm_resolved && edges_point_forward
}

///|
test "BasicLayerAssignment LONGEST_PATH produces routed layered graph" {
  assert_true(
    p2_basic_layer_assignment_test_layout_ok_for_strategy("LONGEST_PATH"),
  )
}

///|
test "BasicLayerAssignment strategy matrix keeps DAG edges forward" {
  let strategies = [
    "COFFMAN_GRAHAM", "INTERACTIVE", "LONGEST_PATH", "LONGEST_PATH_SOURCE", "MIN_WIDTH",
    "NETWORK_SIMPLEX", "STRETCH_WIDTH",
  ]
  for strategy in strategies {
    assert_true(p2_basic_layer_assignment_test_layout_ok_for_strategy(strategy))
  }
}
