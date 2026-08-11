///|
fn issue596_test_setup_plain_java_layout() -> Unit {

}

///|
fn issue596_test_layout(graph : @graph.ElkNode) -> Unit {
  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue596 single child stays centered in outer node" {
  issue596_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let outer = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(outer, 120.0, 80.0)

  let inner = @graph.create_node(Some(outer))
  @graph.node_set_dimensions(inner, 120.0, 40.0)
  @graph.node_set_location(inner, 0.0, 20.0)

  issue596_test_layout(graph)

  let expected_x = (@graph.node_width(outer) - @graph.node_width(inner)) / 2.0
  assert_true((@graph.node_x(inner) - expected_x).abs() <= 0.5)
}
