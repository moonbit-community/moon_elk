///|
fn sections_find_node_by_id(parent : @graph.ElkNode, identifier : String) -> @graph.ElkNode {
  for child in @graph.node_children(parent) {
    if @graph.node_identifier(child) == identifier {
      return child
    }
  }
  abort("node not found")
}

///|
fn sections_find_by_id(edge : @graph.ElkEdge, identifier : String) -> @graph.ElkEdgeSection {
  for section in @graph.edge_sections(edge) {
    if @graph.edge_section_identifier(section) == identifier {
      return section
    }
  }
  abort("section not found")
}

///|
fn sections_shape_node(shape : @graph.ElkConnectableShape?) -> @graph.ElkNode {
  match shape {
    Some(NodeShape(node)) => node
    _ => abort("shape is not node")
  }
}

///|
test "graph json edge section import" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([gj_obj([("id", gj_str("n1"))]), gj_obj([("id", gj_str("n2"))])]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("sources", gj_arr([gj_str("n1")])),
          ("targets", gj_arr([gj_str("n2")])),
          (
            "sections",
            gj_arr([
              gj_obj([
                ("id", gj_str("s1")),
                ("startPoint", gj_obj([("x", gj_num(1)), ("y", gj_num(1))])),
                ("endPoint", gj_obj([("x", gj_num(2)), ("y", gj_num(2))])),
                ("incomingShape", gj_str("n1")),
                ("outgoingSections", gj_arr([gj_num(44)])),
              ]),
              gj_obj([
                ("id", gj_num(44)),
                ("startPoint", gj_obj([("x", gj_num(3)), ("y", gj_num(3))])),
                ("endPoint", gj_obj([("x", gj_num(4)), ("y", gj_num(4))])),
                ("incomingSections", gj_arr([gj_str("s1")])),
                ("outgoingShape", gj_str("n2")),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  let n1 = sections_find_node_by_id(root, "n1")
  let n2 = sections_find_node_by_id(root, "n2")
  let edge = @graph.node_contained_edges(root)[0]
  assert_eq(@graph.edge_sections(edge).length(), 2)
  let s1 = sections_find_by_id(edge, "s1")
  let s44 = sections_find_by_id(edge, "44")
  assert_eq(sections_shape_node(@graph.edge_section_incoming_shape(s1)), n1)
  assert_eq(sections_shape_node(@graph.edge_section_outgoing_shape(s44)), n2)
  assert_eq(@graph.edge_section_outgoing_sections(s1).length(), 1)
  assert_eq(@graph.edge_section_outgoing_sections(s1)[0], s44)
  assert_eq(@graph.edge_section_incoming_sections(s44).length(), 1)
  assert_eq(@graph.edge_section_incoming_sections(s44)[0], s1)
}

///|
test "graph json preserve section ids through transfer" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([
        gj_obj([
          ("id", gj_str("n1")),
          ("width", gj_num(10)),
          ("height", gj_num(10)),
        ]),
        gj_obj([
          ("id", gj_str("n2")),
          ("width", gj_num(10)),
          ("height", gj_num(10)),
        ]),
      ]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("sources", gj_arr([gj_str("n1")])),
          ("targets", gj_arr([gj_str("n2")])),
          (
            "sections",
            gj_arr([
              gj_obj([
                ("id", gj_str("xyz")),
                ("startPoint", gj_obj([("x", gj_num(0)), ("y", gj_num(0))])),
                ("endPoint", gj_obj([("x", gj_num(50)), ("y", gj_num(0))])),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  let edge = @graph.node_contained_edges(root)[0]
  assert_eq(sections_find_by_id(edge, "xyz") >= 0, true)
  required_importer(maybe_importer).transfer_layout(root)
  let json_text = graph.stringify()
  assert_eq(json_text.contains("\"id\":\"xyz\""), true)
}

///|
test "graph json transfer does not add empty sections for extended edge" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([gj_obj([("id", gj_str("n1"))]), gj_obj([("id", gj_str("n2"))])]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("sources", gj_arr([gj_str("n1")])),
          ("targets", gj_arr([gj_str("n2")])),
        ]),
      ]),
    ),
  ])
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  required_importer(maybe_importer).transfer_layout(root)
  assert_eq(graph.stringify().contains("\"sections\""), false)
}

///|
test "graph json transfer does not add empty sections for primitive edge" {
  @graph.reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([gj_obj([("id", gj_str("n1"))]), gj_obj([("id", gj_str("n2"))])]),
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
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  required_importer(maybe_importer).transfer_layout(root)
  assert_eq(graph.stringify().contains("\"sections\""), false)
}
