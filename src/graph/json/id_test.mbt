///|
fn assert_json_import_error(source : String) -> Unit {
  let builder = elk_graph_json_for_graph(source)
  ignore(builder.to_elk())
  match builder.take_error_message() {
    Some(message) =>
      if message.is_empty() {
        abort("Expected non-empty Json import error message.")
      }
    None => abort("Expected Json import error message.")
  }
}

///|
test "graph json id no id reports runtime error" {
  assert_json_import_error("{}")
}

///|
test "graph json id wrong number type reports runtime error" {
  assert_json_import_error("{ id: 1.2 }")
}

///|
test "graph json id wrong object type reports runtime error" {
  assert_json_import_error("{ id: {} }")
}

///|
test "graph json id wrong array type reports runtime error" {
  assert_json_import_error("{ id: [] }")
}

///|
test "graph json id wrong boolean type reports runtime error" {
  assert_json_import_error("{ id: true }")
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

///|
test "graph json id accepts empty string and still imports descendants" {
  let graph = elk_graph_json_for_graph(
    "{ id: '', children: [{ id: 'n1', width: 10, height: 10 }] }",
  ).to_elk()
  assert_eq(@graph.node_identifier(graph), "")
  assert_eq(@graph.node_children(graph).length(), 1)
}
