///|
fn issue587_test_setup_plain_java_layout() -> Unit {
  @core.layout_meta_data_service_reset_for_test()
  @test.plain_java_initialization_reset_for_test()
  @test.plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue587_test_build_graph() -> @graph.ElkNode {
  let graph = @graph.create_graph()
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let edge = @graph.create_edge(None)
  @graph.edge_add_source(edge, @graph.make_node_shape(n1))
  @graph.edge_add_target(edge, @graph.make_node_shape(n2))
  @runtime.layered_test_update_containment(Some(edge))
  graph
}

///|
fn issue587_test_layout_with_optional_routing(
  edge_routing_value : String?,
) -> @graph.ElkNode {
  @graph.reset_graph_model_for_test()
  issue587_test_setup_plain_java_layout()

  let graph = issue587_test_build_graph()
  match edge_routing_value {
    Some(value) =>
      @graph.node_set_string_property(graph, @core.edge_routing, value)
    None => ()
  }
  let resolver = @core.new_layout_algorithm_resolver()
  @core.apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = @core.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
  graph
}

///|
fn issue587_test_layout_success(graph : @graph.ElkNode) -> Bool {
  @graph.node_get_string_property(graph, @core.resolved_algorithm) ==
  "org.eclipse.elk.layered"
}

///|
test "Issue587 default routing avoids exception" {
  assert_true(
    issue587_test_layout_success(
      issue587_test_layout_with_optional_routing(None),
    ),
  )
}

///|
test "Issue587 ORTHOGONAL routing avoids exception" {
  assert_true(
    issue587_test_layout_success(
      issue587_test_layout_with_optional_routing(Some("ORTHOGONAL")),
    ),
  )
}

///|
test "Issue587 POLYLINE routing avoids exception" {
  assert_true(
    issue587_test_layout_success(
      issue587_test_layout_with_optional_routing(Some("POLYLINE")),
    ),
  )
}

///|
test "Issue587 SPLINES routing avoids exception" {
  assert_true(
    issue587_test_layout_success(
      issue587_test_layout_with_optional_routing(Some("SPLINES")),
    ),
  )
}
