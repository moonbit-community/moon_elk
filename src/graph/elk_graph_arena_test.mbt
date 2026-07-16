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
