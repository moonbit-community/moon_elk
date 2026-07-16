///|
test "a standalone edge moves into the graph arena with its dependents" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source = create_node(Some(root))
  let target = create_node(Some(root))
  let edge = create_edge(None)
  let standalone_arena_id = edge_arena_store.val[edge_slot(edge)]
  let standalone_arena_slot = graph_arena_slot(standalone_arena_id)
  let section = create_edge_section(edge)
  let label = create_label(Some(make_edge_label_parent(edge)))
  let edge_storage_slot = edge_slot(edge)
  let section_storage_slot = edge_section_slot(section)
  let label_storage_slot = label_slot(label)

  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))

  let graph_arena_id = node_arena_store.val[node_slot(root)]
  assert_eq(edge_arena_store.val[edge_slot(edge)], graph_arena_id)
  assert_eq(
    edge_section_arena_store.val[edge_section_slot(section)],
    graph_arena_id,
  )
  assert_eq(label_arena_store.val[label_slot(label)], graph_arena_id)
  assert_false(graph_arena_store.val[standalone_arena_slot].alive)

  dispose_graph(root)
  assert_eq(edge_arena_store.val[edge_storage_slot], -1)
  assert_eq(edge_section_arena_store.val[section_storage_slot], -1)
  assert_eq(label_arena_store.val[label_storage_slot], -1)
}

///|
test "disposed graph slots are reused with new handles" {
  reset_graph_model_for_test()
  let first_root = create_graph()
  let first_child = create_node(Some(first_root))
  let first_port = create_port(Some(first_child))
  let first_edge = create_edge(Some(first_root))
  let first_section = create_edge_section(first_edge)
  let first_label = create_label(Some(make_edge_label_parent(first_edge)))
  dispose_graph(first_root)
  let arena_capacity = graph_arena_store.val.length()
  let node_capacity = node_store.val.length()
  let port_capacity = port_store.val.length()
  let edge_capacity = edge_store.val.length()
  let section_capacity = edge_section_store.val.length()
  let label_capacity = label_store.val.length()

  let second_root = create_graph()
  let second_child = create_node(Some(second_root))
  let second_port = create_port(Some(second_child))
  let second_edge = create_edge(Some(second_root))
  let second_section = create_edge_section(second_edge)
  let second_label = create_label(Some(make_edge_label_parent(second_edge)))

  assert_eq(graph_arena_store.val.length(), arena_capacity)
  assert_eq(node_store.val.length(), node_capacity)
  assert_eq(port_store.val.length(), port_capacity)
  assert_eq(edge_store.val.length(), edge_capacity)
  assert_eq(edge_section_store.val.length(), section_capacity)
  assert_eq(label_store.val.length(), label_capacity)
  assert_true(first_root != second_root)
  assert_true(first_child != second_child)
  assert_true(first_port != second_port)
  assert_true(first_edge != second_edge)
  assert_true(first_section != second_section)
  assert_true(first_label != second_label)
  dispose_graph(second_root)
}
