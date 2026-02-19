///|
fn export_make_graph_with_three_children() -> @graph.ElkNode {
  let graph = @graph.create_graph()
  ignore(@graph.create_node(Some(graph)))
  let node2 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(node2, "foo")
  ignore(@graph.create_node(Some(graph)))
  graph
}

///|
test "graph json export port-less edge" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let node1 = @graph.create_node(Some(graph))
  let node2 = @graph.create_node(Some(graph))
  ignore(@graph.create_simple_edge(node1, node2))
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"edges\""), true)
}

///|
test "graph json export unique ids" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let node1 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(node1, "foo")
  let node2 = @graph.create_node(Some(graph))
  @graph.node_set_identifier(node2, "foo")
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("foo_g"), true)
}

///|
test "graph json export ids increasing" {
  @graph.reset_graph_model_for_test()
  let graph = export_make_graph_with_three_children()
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"n1\""), true)
  assert_eq(json_text.contains("\"foo\""), true)
  assert_eq(json_text.contains("\"n2\""), true)
  assert_eq(json_text.contains("\"n3\""), false)
}

///|
test "graph json export does not add empty sections" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let node1 = @graph.create_node(Some(graph))
  let node2 = @graph.create_node(Some(graph))
  ignore(@graph.create_simple_edge(node1, node2))
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"sections\""), false)
}
