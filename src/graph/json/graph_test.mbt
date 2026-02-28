///|
fn graph_child_exists(parent : @graph.ElkNode, identifier : String) -> Bool {
  for child in @graph.node_children(parent) {
    if @graph.node_identifier(child) == identifier {
      return true
    }
  }
  false
}

///|
test "graph json graph must be object" {
  @graph.reset_graph_model_for_test()
  let root = elk_graph_json_for_graph("{\"id\": 1}").to_elk()
  assert_eq(@graph.node_identifier(root), "1")
}

///|
test "graph json graph must be object fail array reports runtime error" {
  @graph.reset_graph_model_for_test()
  ignore(elk_graph_json_for_graph("[]").to_elk())
  let error = @core.layout_runtime_take_error_message()
  assert_eq(error is Some(_), true)
  if error is Some(message) {
    assert_eq(message.is_empty(), false)
  }
}

///|
test "graph json small graph" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("properties", gj_obj([("elk.direction", gj_str("DOWN"))])),
    (
      "children",
      gj_arr([
        gj_obj([
          ("id", gj_str("n1")),
          ("width", gj_num(40)),
          ("height", gj_num(40)),
        ]),
        gj_obj([
          ("id", gj_str("n2")),
          ("width", gj_num(40)),
          ("height", gj_num(40)),
        ]),
      ]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("source", gj_str("n1")),
          ("target", gj_str("n2")),
        ]),
      ]),
    ),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(@graph.node_children(root).length(), 2)
  assert_eq(@graph.node_contained_edges(root).length(), 1)
  assert_eq(@graph.node_get_string_property(root, @core.direction), "DOWN")
}

///|
test "graph json reject sloppy json if not lenient reports runtime error" {
  @graph.reset_graph_model_for_test()
  let sloppy_json_graph = "{\n  // the root node\n  id: \"root\",\n  /* Now the graph */\n  \"children\": [ {\"id\": \"c\"}; {\"id\": \"c1\"} ],\n  'edges': [] // Endline comment\n}"
  ignore(elk_graph_json_for_graph(sloppy_json_graph).lenient(false).to_elk())
  let error = @core.layout_runtime_take_error_message()
  assert_eq(error is Some(_), true)
  if error is Some(message) {
    assert_eq(message.is_empty(), false)
  }
}

///|
test "graph json accept sloppy json if lenient" {
  @graph.reset_graph_model_for_test()
  let sloppy_json_graph = "{\n  // the root node\n  id: \"root\",\n  /* Now the graph */\n  \"children\": [ {\"id\": \"c\"}; {\"id\": \"c1\"} ],\n  'edges': [] // Endline comment\n}"
  let root = elk_graph_json_for_graph(sloppy_json_graph).to_elk()
  assert_eq(@graph.node_identifier(root), "root")
  assert_eq(@graph.node_children(root).length(), 2)
  assert_eq(graph_child_exists(root, "c"), true)
  assert_eq(graph_child_exists(root, "c1"), true)
}
