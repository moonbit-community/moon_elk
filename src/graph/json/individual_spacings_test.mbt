///|
fn individual_find_node_by_id(root : @graph.ElkNode, identifier : String) -> @graph.ElkNode {
  let stack = [root]
  while !stack.is_empty() {
    let node = stack.pop().unwrap()
    if @graph.node_identifier(node) == identifier {
      return node
    }
    for child in @graph.node_children(node) {
      stack.push(child)
    }
  }
  abort("node not found")
}

///|
fn individual_approx_equal(value : Double, expected : Double) -> Bool {
  (value - expected).abs() < 0.001
}

///|
fn individual_spacing_sample_graph() -> Json {
  gj_obj([
    ("id", gj_str("n0")),
    (
      "children",
      gj_arr([
        gj_obj([
          ("id", gj_str("outer")),
          (
            "layoutOptions",
            gj_obj([
              (
                "nodeLabels.padding",
                gj_str("[top=0.0,left=0.0,bottom=0.0,right=0.0]"),
              ),
            ]),
          ),
          (
            "children",
            gj_arr([
              gj_obj([
                ("id", gj_str("i1")),
                (
                  "layoutOptions",
                  gj_obj([
                    (
                      "nodeLabels.placement",
                      gj_str("[H_CENTER, V_TOP, INSIDE]"),
                    ),
                  ]),
                ),
                (
                  "labels",
                  gj_arr([
                    gj_obj([
                      ("text", gj_str("Node 1")),
                      ("width", Json::number(40.0)),
                      ("height", Json::number(15.0)),
                    ]),
                  ]),
                ),
                ("width", Json::number(60.0)),
                ("height", Json::number(40.0)),
              ]),
              gj_obj([
                ("id", gj_str("i2")),
                (
                  "layoutOptions",
                  gj_obj([
                    (
                      "nodeLabels.placement",
                      gj_str("[H_CENTER, V_TOP, INSIDE]"),
                    ),
                  ]),
                ),
                (
                  "individualSpacings",
                  gj_obj([
                    (
                      "nodeLabels.padding",
                      gj_str("[top=10.0,left=0.0,bottom=0.0,right=0.0]"),
                    ),
                  ]),
                ),
                (
                  "labels",
                  gj_arr([
                    gj_obj([
                      ("text", gj_str("Node 2")),
                      ("width", Json::number(40.0)),
                      ("height", Json::number(15.0)),
                    ]),
                  ]),
                ),
                ("width", Json::number(60.0)),
                ("height", Json::number(40.0)),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
}

///|
test "graph json import individual spacings" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_algorithms()
  let graph = individual_spacing_sample_graph()
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  let i1 = individual_find_node_by_id(root, "i1")
  let i2 = individual_find_node_by_id(root, "i2")
  assert_eq(
    @graph.node_individual_spacing_option_string_value(i1, "nodeLabels.padding")
    is Some(_),
    false,
  )
  assert_eq(
    @graph.node_individual_spacing_option_string_value(i2, "nodeLabels.padding")
    is Some(_),
    true,
  )
  let engine = @core.new_recursive_graph_layout_engine()
  engine.layout(root, @core.new_null_elk_progress_monitor())
  let l1 = @graph.node_labels(i1)[0]
  let l2 = @graph.node_labels(i2)[0]
  assert_eq(individual_approx_equal(@graph.label_y(l1), 0.0), true)
  assert_eq(individual_approx_equal(@graph.label_y(l2), 10.0), true)
}

///|
test "graph json export individual spacings" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, @core.spacing_node_node, 10.0)
  @graph.node_set_individual_spacing_option_string_by_id(
    graph,
    @core.spacing_node_node.get_id(),
    "20",
  )
  let json = elk_graph_json_for_elk_graph(graph)
    .omit_unknown_layout_options(true)
    .to_json()
  assert_eq(json.contains("individualSpacings"), true)
}

///|
test "graph json export no individual spacings" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let json = elk_graph_json_for_elk_graph(graph)
    .omit_unknown_layout_options(true)
    .to_json()
  assert_eq(json.contains("individualSpacings"), false)
}
