///|
fn export_make_graph_with_three_children() -> ElkNode {
  let graph = create_graph()
  ignore(create_node(Some(graph)))
  let node2 = create_node(Some(graph))
  node_set_identifier(node2, "foo")
  ignore(create_node(Some(graph)))
  graph
}

///|
test "graph json export port-less edge" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  let node2 = create_node(Some(graph))
  ignore(create_simple_edge(node1, node2))
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"edges\""), true)
}

///|
test "graph json export unique ids" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  node_set_identifier(node1, "foo")
  let node2 = create_node(Some(graph))
  node_set_identifier(node2, "foo")
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("foo_g"), true)
}

///|
test "graph json export ids increasing" {
  reset_graph_model_for_test()
  let graph = export_make_graph_with_three_children()
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"n1\""), true)
  assert_eq(json_text.contains("\"foo\""), true)
  assert_eq(json_text.contains("\"n2\""), true)
  assert_eq(json_text.contains("\"n3\""), false)
}

///|
test "graph json export does not add empty sections" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let node1 = create_node(Some(graph))
  let node2 = create_node(Some(graph))
  ignore(create_simple_edge(node1, node2))
  let json_text = elk_graph_json_for_elk_graph(graph).to_json()
  assert_eq(json_text.contains("\"sections\""), false)
}
