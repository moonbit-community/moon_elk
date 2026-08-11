///|
test "force graph objects allocate property bags lazily" {
  let node = new_fnode()
  let edge = new_fedge()
  let label = new_flabel(edge)

  assert_true(node.data.int_properties is None)
  assert_true(edge.data.int_properties is None)
  assert_true(label.data.bool_properties is None)

  let property = @graph.new_property("test.force.lazy", 0)
  fnode_set_int_property(node, property, 42)
  assert_true(node.data.int_properties is Some(_))
  assert_eq(fnode_get_int_property(node, property), 42)
}
