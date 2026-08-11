///|
test "graph objects allocate property bags lazily" {
  let arena = new_graph_arena()
  let node = arena.create_graph()
  let port = arena.create_port()
  let edge = arena.create_edge()
  let label = arena.create_label()

  assert_true(node_data(node).properties is None)
  assert_true(node_data(node).layout_options is None)
  assert_true(node_data(node).individual_spacings is None)
  assert_true(port_data(port).layout_options is None)
  assert_true(edge_data(edge).layout_options is None)
  assert_true(label_data(label).layout_options is None)

  let property = new_property("org.eclipse.elk.test.compact", 0)
  node_set_int_property(node, property, 7)
  assert_true(node_data(node).properties is Some(_))
  assert_eq(node_get_int_property(node, property), 7)
  arena.dispose()
}

///|
test "typed option lookup shares the compact external option id" {
  let node = create_graph()
  let property = new_property("org.eclipse.elk.test.fromJson", 3)
  node_set_layout_option_string_by_id(node, property.get_id(), "19")
  assert_eq(node_get_int_property(node, property), 19)
  dispose_graph(node)
}
