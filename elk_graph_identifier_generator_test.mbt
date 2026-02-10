///|
fn section_id_has_prefix(section : ElkEdgeSection, prefix : String) -> Bool {
  edge_section_identifier(section).has_prefix(prefix)
}

///|
test "graph identifier generator assert exists" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))
  let port = create_port(Some(child))
  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(child))
  edge_add_target(edge, make_port_shape(port))
  let section = create_edge_section(edge)
  let label = create_label(Some(make_node_label_parent(child)))
  let nested_label = create_label(Some(make_label_label_parent(label)))
  ignore(nested_label)

  ignore(graph_identifier_generator_for_graph(root).assert_exists().execute())

  assert_eq(node_identifier(root), "G1")
  assert_true(node_identifier(child).has_prefix("N"))
  assert_true(port_identifier(port).has_prefix("P"))
  assert_true(edge_identifier(edge).has_prefix("E"))
  assert_true(section_id_has_prefix(section, "ES"))
  assert_true(label_identifier(label).has_prefix("L"))
  assert_true(label_identifier(nested_label).has_prefix("L"))
}

///|
test "graph identifier generator assert valid" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))
  let port = create_port(Some(child))
  let edge = create_edge(Some(root))
  let section = create_edge_section(edge)
  let label = create_label(Some(make_edge_label_parent(edge)))

  node_set_identifier(root, "bad root")
  node_set_identifier(child, "1bad-id")
  port_set_identifier(port, "p-1")
  edge_set_identifier(edge, "edge!")
  edge_section_set_identifier(section, "sec tion")
  label_set_identifier(label, "label?")

  ignore(graph_identifier_generator_for_graph(root).assert_valid().execute())

  assert_eq(node_identifier(root), "bad_root")
  assert_eq(node_identifier(child), "_bad_id")
  assert_eq(port_identifier(port), "p_1")
  assert_eq(edge_identifier(edge), "edge_")
  assert_eq(edge_section_identifier(section), "sec_tion")
  assert_eq(label_identifier(label), "label_")
}

///|
test "graph identifier generator assert unique" {
  reset_graph_model_for_test()
  let root = create_graph()
  let node_a = create_node(Some(root))
  let node_b = create_node(Some(root))
  let port_a = create_port(Some(node_a))
  let port_b = create_port(Some(node_b))

  node_set_identifier(node_a, "dup")
  node_set_identifier(node_b, "dup")
  port_set_identifier(port_a, "dup_port")
  port_set_identifier(port_b, "dup_port")

  ignore(graph_identifier_generator_for_graph(root).assert_unique().execute())

  assert_eq(node_identifier(node_a), "dup")
  assert_true(node_identifier(node_b) != "dup")
  assert_true(node_identifier(node_b).has_prefix("dup_g"))
  assert_eq(port_identifier(port_a), "dup_port")
  assert_true(port_identifier(port_b) != "dup_port")
  assert_true(port_identifier(port_b).has_prefix("dup_port_g"))
}

///|
test "graph identifier generator avoids existing identifiers" {
  reset_graph_model_for_test()
  let root = create_graph()
  let node_with_id = create_node(Some(root))
  let node_without_id = create_node(Some(root))
  let edge_with_id = create_edge(Some(root))
  let edge_without_id = create_edge(Some(root))

  node_set_identifier(node_with_id, "N1")
  edge_set_identifier(edge_with_id, "E1")

  ignore(graph_identifier_generator_for_graph(root).assert_exists().execute())

  assert_eq(node_identifier(root), "G1")
  assert_eq(node_identifier(node_without_id), "N2")
  assert_eq(edge_identifier(edge_without_id), "E2")
}
