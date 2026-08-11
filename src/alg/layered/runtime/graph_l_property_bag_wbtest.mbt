///|
test "layered graph objects allocate property bags lazily" {
  let graph = new_l_graph()
  let node = new_l_node()
  let port = new_l_port()
  let edge = new_l_edge()
  let label = new_l_label()

  assert_true(graph.int_properties is None)
  assert_true(node.int_properties is None)
  assert_true(port.int_properties is None)
  assert_true(edge.int_properties is None)
  assert_true(label.bool_properties is None)

  let property = @graph.new_property("test.layered.lazy", 0)
  node.set_property_int(property, 42)
  assert_true(node.int_properties is Some(_))
  assert_eq(node.get_property_int(property), 42)
}
