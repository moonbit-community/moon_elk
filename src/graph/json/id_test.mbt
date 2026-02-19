///|
test "panic graph json id no id" {
  ignore(elk_graph_json_for_graph("{}").to_elk())
}

///|
test "panic graph json id wrong number type" {
  ignore(elk_graph_json_for_graph("{ id: 1.2 }").to_elk())
}

///|
test "panic graph json id wrong object type" {
  ignore(elk_graph_json_for_graph("{ id: {} }").to_elk())
}

///|
test "panic graph json id wrong array type" {
  ignore(elk_graph_json_for_graph("{ id: [] }").to_elk())
}

///|
test "panic graph json id wrong boolean type" {
  ignore(elk_graph_json_for_graph("{ id: true }").to_elk())
}

///|
test "graph json id accepts string" {
  let graph = elk_graph_json_for_graph("{ id: 'foo' }").to_elk()
  assert_eq(@graph.node_identifier(graph), "foo")
}

///|
test "graph json id accepts int" {
  let graph = elk_graph_json_for_graph("{ id: 3 }").to_elk()
  assert_eq(@graph.node_identifier(graph), "3")
}
