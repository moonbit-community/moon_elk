///|
test "a standalone edge moves into the graph arena with its dependents" {
  let root = create_graph()
  let source = create_node(Some(root))
  let target = create_node(Some(root))
  let edge = create_edge(None)
  let standalone_arena = edge.graph_arena()
  let section = create_edge_section(edge)
  let label = create_label(Some(make_edge_label_parent(edge)))

  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))

  let graph_arena = root.graph_arena()
  assert_true(physical_equal(edge.graph_arena(), graph_arena))
  assert_true(physical_equal(section.graph_arena(), graph_arena))
  assert_true(physical_equal(label.graph_arena(), graph_arena))
  assert_false(standalone_arena.is_alive())
  assert_eq(standalone_arena.edges.length(), 0)
  assert_eq(standalone_arena.edge_sections.length(), 0)
  assert_eq(standalone_arena.labels.length(), 0)
  assert_true(graph_arena.edges[edge.slot].data is Some(_))
  assert_true(graph_arena.edge_sections[section.slot].data is Some(_))
  assert_true(graph_arena.labels[label.slot].data is Some(_))

  dispose_graph(root)
  assert_false(graph_arena.is_alive())
}

///|
test "graph arena slots own every graph object payload" {
  let arena = new_graph_arena()
  let node = arena.create_graph()
  let port = create_port(Some(node))
  let edge = create_edge(Some(node))
  let section = create_edge_section(edge)
  let label = create_label(Some(make_edge_label_parent(edge)))
  node_set_identifier(node, "node")
  port_set_identifier(port, "port")
  edge_set_identifier(edge, "edge")
  edge_section_set_identifier(section, "section")
  label_set_identifier(label, "label")

  match arena.nodes[node.slot].data {
    Some(data) => assert_eq(data.identifier, "node")
    None => fail("expected arena-owned node payload")
  }
  match arena.ports[port.slot].data {
    Some(data) => assert_eq(data.identifier, "port")
    None => fail("expected arena-owned port payload")
  }
  match arena.edges[edge.slot].data {
    Some(data) => assert_eq(data.identifier, "edge")
    None => fail("expected arena-owned edge payload")
  }
  match arena.edge_sections[section.slot].data {
    Some(data) => assert_eq(data.identifier, "section")
    None => fail("expected arena-owned edge section payload")
  }
  match arena.labels[label.slot].data {
    Some(data) => assert_eq(data.identifier, "label")
    None => fail("expected arena-owned label payload")
  }
  arena.dispose()
}

///|
test "panic graph handles reject a mismatched slot generation" {
  let node = create_graph()
  let invalid : ElkNode = {
    arena: node.arena,
    slot: node.slot,
    generation: node.generation + 1,
    id: node.id,
  }
  ignore(node_identifier(invalid))
}

///|
test "separate graph arenas own independent handles" {
  let first_root = create_graph()
  let first_child = create_node(Some(first_root))
  let first_port = create_port(Some(first_child))
  let first_edge = create_edge(Some(first_root))
  let first_section = create_edge_section(first_edge)
  let first_label = create_label(Some(make_edge_label_parent(first_edge)))
  let first_arena = first_root.graph_arena()
  dispose_graph(first_root)

  let second_root = create_graph()
  let second_child = create_node(Some(second_root))
  let second_port = create_port(Some(second_child))
  let second_edge = create_edge(Some(second_root))
  let second_section = create_edge_section(second_edge)
  let second_label = create_label(Some(make_edge_label_parent(second_edge)))

  assert_false(first_arena.is_alive())
  assert_false(physical_equal(first_arena, second_root.graph_arena()))
  assert_true(first_root != second_root)
  assert_true(first_child != second_child)
  assert_true(first_port != second_port)
  assert_true(first_edge != second_edge)
  assert_true(first_section != second_section)
  assert_true(first_label != second_label)
  dispose_graph(second_root)
}
