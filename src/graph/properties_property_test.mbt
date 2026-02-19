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
test "Property default clone map" {
  let default_value : Map[String, Int] = { "x": 2, "y": 3 }
  let property = new_property_cloneable("dummyMap", default_value, value => {
    Some(
      {
        let copy = {}
        value.each((key, element) => copy[key] = element)
        copy
      },
    )
  })
  let cloned = property.get_default()
  cloned["x"] = 99
  assert_eq(default_value.get("x"), Some(2))
  assert_eq(cloned.get("x"), Some(99))
}

///|
test "Property default clone nested array" {
  let default_value = [[1, 2], [3, 4]]
  let property = new_property_cloneable("dummyNestedArray", default_value, value => {
    Some(value.map(values => values.copy()))
  })
  let cloned = property.get_default()
  cloned[0].push(5)
  assert_eq(default_value[0].length(), 2)
  assert_eq(cloned[0].length(), 3)
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
