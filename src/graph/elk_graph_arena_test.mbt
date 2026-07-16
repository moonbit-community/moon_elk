///|
test "disposing a graph arena leaves other graph handles valid" {
  reset_graph_model_for_test()
  let first_arena = new_graph_arena()
  let first_root = first_arena.create_graph()
  let first_child = create_node(Some(first_root))
  let first_port = create_port(Some(first_child))
  let first_edge = create_edge(Some(first_root))
  edge_add_source(first_edge, make_node_shape(first_child))
  edge_add_target(first_edge, make_port_shape(first_port))
  ignore(create_edge_section(first_edge))
  ignore(create_label(Some(make_edge_label_parent(first_edge))))

  let second_arena = new_graph_arena()
  let second_root = second_arena.create_graph()
  node_set_identifier(second_root, "still-alive")

  first_arena.dispose()
  inspect(node_identifier(second_root), content="still-alive")

  second_arena.dispose()
}

///|
test "dispose_graph releases the arena that owns the root" {
  reset_graph_model_for_test()
  let root = create_graph()
  ignore(create_node(Some(root)))
  dispose_graph(root)

  let replacement = create_graph()
  node_set_identifier(replacement, "replacement")
  inspect(node_identifier(replacement), content="replacement")
  dispose_graph(replacement)
}

///|
test "a stale arena handle cannot dispose a reused arena slot" {
  reset_graph_model_for_test()
  let stale_arena = new_graph_arena()
  ignore(stale_arena.create_graph())
  stale_arena.dispose()

  let active_arena = new_graph_arena()
  let active_root = active_arena.create_graph()
  node_set_identifier(active_root, "active")
  stale_arena.dispose()

  inspect(node_identifier(active_root), content="active")
  active_arena.dispose()
}

///|
test "graph collection queries do not expose mutable model storage" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))
  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(child))

  node_children(root).push(root)
  edge_sources(edge).clear()

  assert_eq(node_children(root), [child])
  assert_eq(edge_sources(edge).length(), 1)
  match edge_sources(edge)[0] {
    NodeShape(source) => assert_eq(source, child)
    PortShape(_) => fail("expected node source")
  }
  dispose_graph(root)
}

///|
test "panic edges cannot retain targets from another graph arena" {
  reset_graph_model_for_test()
  let first_root = create_graph()
  let edge = create_edge(Some(first_root))
  let second_root = create_graph()
  let second_node = create_node(Some(second_root))

  edge_add_target(edge, make_node_shape(second_node))
}

///|
test "panic edge section relations cannot create cycles" {
  reset_graph_model_for_test()
  let root = create_graph()
  let edge = create_edge(Some(root))
  let first = create_edge_section(edge)
  let second = create_edge_section(edge)

  edge_section_add_outgoing_section(first, second)
  edge_section_add_outgoing_section(second, first)
}

///|
test "panic incoming edge section relations cannot create cycles" {
  reset_graph_model_for_test()
  let root = create_graph()
  let edge = create_edge(Some(root))
  let first = create_edge_section(edge)
  let second = create_edge_section(edge)

  edge_section_add_incoming_section(first, second)
  edge_section_add_incoming_section(second, first)
}

///|
test "a graph arena owns detached graph objects explicitly" {
  reset_graph_model_for_test()
  let arena = new_graph_arena()
  let node = arena.create_node()
  let port = arena.create_port()
  let edge = arena.create_edge()
  let section = create_edge_section(edge)
  let label = arena.create_label()

  node_set_identifier(node, "node")
  port_set_identifier(port, "port")
  edge_set_identifier(edge, "edge")
  edge_section_set_identifier(section, "section")
  label_set_identifier(label, "label")

  inspect(node_identifier(node), content="node")
  inspect(port_identifier(port), content="port")
  inspect(edge_identifier(edge), content="edge")
  inspect(edge_section_identifier(section), content="section")
  inspect(label_identifier(label), content="label")
  arena.dispose()
}

///|
test "panic a stale graph handle cannot access a reused slot" {
  reset_graph_model_for_test()
  let first_root = create_graph()
  dispose_graph(first_root)
  let second_root = create_graph()
  node_set_identifier(second_root, "second")

  ignore(node_identifier(first_root))
}
