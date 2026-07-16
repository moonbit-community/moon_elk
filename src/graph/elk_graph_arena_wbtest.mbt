///|
test "a standalone edge moves into the graph arena with its dependents" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source = create_node(Some(root))
  let target = create_node(Some(root))
  let edge = create_edge(None)
  let standalone_arena_id = edge_arena_store.val[edge]
  let section = create_edge_section(edge)
  let label = create_label(Some(make_edge_label_parent(edge)))

  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))

  let graph_arena_id = node_arena_store.val[root]
  assert_eq(edge_arena_store.val[edge], graph_arena_id)
  assert_eq(edge_section_arena_store.val[section], graph_arena_id)
  assert_eq(label_arena_store.val[label], graph_arena_id)
  assert_false(graph_arena_store.val[standalone_arena_id].alive)

  dispose_graph(root)
  assert_eq(edge_arena_store.val[edge], -1)
  assert_eq(edge_section_arena_store.val[section], -1)
  assert_eq(label_arena_store.val[label], -1)
}
