///|
test "graph json import layout options" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("layoutOptions", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_has_string_property(root, direction), true)
  assert_eq(node_get_string_property(root, direction), "DOWN")
}

///|
test "graph json import legacy properties" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("properties", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_has_string_property(root, direction), true)
  assert_eq(node_get_string_property(root, direction), "DOWN")
}

///|
test "graph json layout options have priority over properties" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    ("layoutOptions", gj_obj([("elk.direction", gj_str("UP"))])),
    ("properties", gj_obj([("elk.direction", gj_str("DOWN"))])),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_has_string_property(root, direction), true)
  assert_eq(node_get_string_property(root, direction), "UP")
}

///|
test "graph json export layout options" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_string_property(root, direction, "UP")
  let json_text = elk_graph_json_for_elk_graph(root).to_json()
  assert_eq(json_text.contains("\"layoutOptions\""), true)
  assert_eq(json_text.contains("\"elk.direction\":\"UP\""), true)
}

///|
test "graph json export omit unknown options" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_string_property(root, direction, "RIGHT")
  node_set_layout_option_string_by_id(root, "foo.bar.dummy", "0")
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
