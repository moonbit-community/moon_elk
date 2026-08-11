///|
fn issue476_test_setup_plain_java_layout() -> Unit {

}

///|
fn issue476_test_layout(graph : @graph.ElkNode) -> Unit {
  let layout_engine = @test.new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue476 node labels remain horizontally centered" {
  issue476_test_setup_plain_java_layout()

  let graph = @graph.create_graph()
  let node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(node, 80.0, 40.0)

  let label_a = @graph.create_label(Some(@graph.make_node_label_parent(node)))
  @graph.label_set_text(label_a, "A")
  @graph.label_set_dimensions(label_a, 20.0, 10.0)
  @graph.label_set_location(label_a, 30.0, 0.0)

  let label_b = @graph.create_label(Some(@graph.make_node_label_parent(node)))
  @graph.label_set_text(label_b, "B")
  @graph.label_set_dimensions(label_b, 20.0, 10.0)
  @graph.label_set_location(label_b, 30.0, 12.0)

  issue476_test_layout(graph)

  for label in @graph.node_labels(node) {
    let center = @graph.label_x(label) + @graph.label_width(label) / 2.0
    assert_true((center - @graph.node_width(node) / 2.0).abs() <= 0.5)
  }
}
