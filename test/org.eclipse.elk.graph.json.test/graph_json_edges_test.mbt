///|
fn edges_find_node_by_id(parent : ElkNode, identifier : String) -> ElkNode {
  for child in node_children(parent) {
    if node_identifier(child) == identifier {
      return child
    }
  }
  abort("node not found")
}

///|
fn edges_first_source_node(edge : ElkEdge) -> ElkNode {
  match edge_sources(edge)[0] {
    NodeShape(node) => node
    _ => abort("missing source")
  }
}

///|
fn edges_first_target_node(edge : ElkEdge) -> ElkNode {
  match edge_targets(edge)[0] {
    NodeShape(node) => node
    _ => abort("missing target")
  }
}

///|
test "graph json extended edge" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([gj_obj([("id", gj_str("n1"))]), gj_obj([("id", gj_num(3))])]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("sources", gj_arr([gj_str("n1")])),
          ("targets", gj_arr([gj_num(3)])),
        ]),
      ]),
    ),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_children(root).length(), 2)
  assert_eq(node_contained_edges(root).length(), 1)
  let n1 = edges_find_node_by_id(root, "n1")
  let n3 = edges_find_node_by_id(root, "3")
  let edge = node_contained_edges(root)[0]
  assert_eq(edge_sources(edge).length(), 1)
  assert_eq(edges_first_source_node(edge), n1)
  assert_eq(edge_targets(edge).length(), 1)
  assert_eq(edges_first_target_node(edge), n3)
}

///|
test "graph json primitive edge" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([gj_obj([("id", gj_str("n1"))]), gj_obj([("id", gj_num(3))])]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("source", gj_str("n1")),
          ("target", gj_num(3)),
        ]),
      ]),
    ),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_children(root).length(), 2)
  assert_eq(node_contained_edges(root).length(), 1)
  let n1 = edges_find_node_by_id(root, "n1")
  let n3 = edges_find_node_by_id(root, "3")
  let edge = node_contained_edges(root)[0]
  assert_eq(edge_sources(edge).length(), 1)
  assert_eq(edges_first_source_node(edge), n1)
  assert_eq(edge_targets(edge).length(), 1)
  assert_eq(edges_first_target_node(edge), n3)
}

///|
test "graph json edge containment" {
  reset_graph_model_for_test()
  let graph = gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([
        gj_obj([("id", gj_str("p"))]),
        gj_obj([
          ("id", gj_str("q")),
          ("children", gj_arr([gj_obj([("id", gj_str("r"))])])),
          (
            "edges",
            gj_arr([
              gj_obj([
                ("id", gj_str("e")),
                ("source", gj_str("p")),
                ("target", gj_str("r")),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
  let root = elk_graph_json_for_json_graph(graph).to_elk()
  assert_eq(node_contained_edges(root).length(), 1)
}
