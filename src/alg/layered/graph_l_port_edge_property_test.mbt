///|
test "LPort supports int properties with defaults and presence checks" {
  let port = new_l_port()
  let property : @graph.IProperty[Int] = @graph.new_property(
    "moon_elk.test.port.int", -7,
  )

  assert_eq(port.get_property_int(property), -7)
  assert_eq(port.has_property_int(property), false)

  port.set_property_int(property, 42)
  assert_eq(port.has_property_int(property), true)
  assert_eq(port.get_property_int(property), 42)
}

///|
test "LEdge supports int properties with defaults and presence checks" {
  let edge = new_l_edge()
  let property : @graph.IProperty[Int] = @graph.new_property(
    "moon_elk.test.edge.int", -11,
  )

  assert_eq(edge.get_property_int(property), -11)
  assert_eq(edge.has_property_int(property), false)

  edge.set_property_int(property, 9)
  assert_eq(edge.has_property_int(property), true)
  assert_eq(edge.get_property_int(property), 9)
}
