///|
test "graph json import layout options" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("layoutOptions", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(@graph.node_has_string_property(root, @core.direction), true)
  assert_eq(@graph.node_get_string_property(root, @core.direction), "DOWN")
}

///|
test "graph json import legacy properties" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("properties", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(@graph.node_has_string_property(root, @core.direction), true)
  assert_eq(@graph.node_get_string_property(root, @core.direction), "DOWN")
}

///|
test "graph json layout options have priority over properties" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("layoutOptions", gj_obj([("elk.direction", gj_str("UP"))])),
    ("properties", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(@graph.node_has_string_property(root, @core.direction), true)
  assert_eq(@graph.node_get_string_property(root, @core.direction), "UP")
}

///|
test "graph json export layout options" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_string_property(root, @core.direction, "UP")
  let json_text = elk_graph_json_for_elk_graph(root).to_json()
  assert_eq(json_text.contains("\"layoutOptions\""), true)
  assert_eq(json_text.contains("\"elk.direction\":\"UP\""), true)
}

///|
test "graph json export omit unknown options" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_string_property(root, @core.direction, "RIGHT")
  @graph.node_set_layout_option_string_by_id(root, "foo.bar.dummy", "0")
  let json_without_unknown = elk_graph_json_for_elk_graph(root)
    .omit_unknown_layout_options(true)
    .to_json()
  assert_eq(json_without_unknown.contains("\"elk.direction\""), true)
  assert_eq(json_without_unknown.contains("foo.bar.dummy"), false)
  let json_with_unknown = elk_graph_json_for_elk_graph(root)
    .omit_unknown_layout_options(false)
    .to_json()
  assert_eq(json_with_unknown.contains("foo.bar.dummy"), true)
}
