///|
fn assert_json_import_error() -> Unit {
  match @core.layout_runtime_take_error_message() {
    Some(message) =>
      if message.is_empty() {
        abort("Expected non-empty Json import error message.")
      }
    None => abort("Expected Json import error message.")
  }
}

///|
test "graph json id no id reports runtime error" {
  ignore(elk_graph_json_for_graph("{}").to_elk())
  assert_json_import_error()
}

///|
test "graph json id wrong number type reports runtime error" {
  ignore(elk_graph_json_for_graph("{ id: 1.2 }").to_elk())
  assert_json_import_error()
}

///|
test "graph json id wrong object type reports runtime error" {
  ignore(elk_graph_json_for_graph("{ id: {} }").to_elk())
  assert_json_import_error()
}

///|
test "graph json id wrong array type reports runtime error" {
  ignore(elk_graph_json_for_graph("{ id: [] }").to_elk())
  assert_json_import_error()
}

///|
test "graph json id wrong boolean type reports runtime error" {
  ignore(elk_graph_json_for_graph("{ id: true }").to_elk())
  assert_json_import_error()
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
