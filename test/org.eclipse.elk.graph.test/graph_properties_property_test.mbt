///|
test "Property default primitive values" {
  let int_property = new_property("dummyInt", 43)
  assert_eq(int_property.get_default(), 43)
  let double_property = new_property("dummyDouble", 32.3)
  assert_eq(double_property.get_default(), 32.3)
  let string_property = new_property("dummyString", "foo")
  assert_eq(string_property.get_default(), "foo")
}

///|
test "Property default clone KVector" {
  let default_value = new_kvector_xy(2.0, 3.0)
  let property = new_property_cloneable("dummyKVector", default_value, value => {
    Some(new_kvector_copy(value))
  })
  let cloned = property.get_default()
  ignore(cloned.set_xy(99.0, cloned.y))
  assert_eq(default_value.x, 2.0)
  assert_eq(cloned.y, 3.0)
}

///|
test "Property default clone KVectorChain" {
  let default_value = new_kvector_chain()
  default_value.add_xy(1.0, 2.0)
  default_value.add_xy(3.0, 4.0)
  let property = new_property_cloneable("dummyKVectorChain", default_value, value => {
    Some(new_kvector_chain_copy(value))
  })
  let cloned = property.get_default()
  cloned.add_xy(5.0, 6.0)
  assert_eq(default_value.size(), 2)
  assert_eq(cloned.size(), 3)
}

///|
test "Property default clone array" {
  let default_value = [1, 2, 3]
  let property = new_property_cloneable("dummyArray", default_value, value => {
    Some(value.copy())
  })
  let cloned = property.get_default()
  cloned.push(4)
  assert_eq(default_value.length(), 3)
  assert_eq(cloned.length(), 4)
}

///|
test "panic Property unknown clone strategy" {
  let property = new_property_cloneable_without_clone("dummy", 42)
  ignore(property.get_default())
}
