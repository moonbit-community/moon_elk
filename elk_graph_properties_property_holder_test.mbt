///|
test "map property holder set/get/has/copy" {
  let property = new_property("elk.test.int", 7)
  let source = new_map_property_holder()
  ignore(source.set_property(property, Some(12)))

  inspect(source.has_property(property), content="true")
  inspect(source.get_property(property) == 12, content="true")

  let target = new_map_property_holder()
  ignore(target.copy_properties(Some(source)))
  inspect(target.get_property(property) == 12, content="true")
}

///|
test "property holder comparator uses property value ordering" {
  let property = new_property("elk.test.order", 0)
  let left = new_map_property_holder()
  ignore(left.set_property(property, Some(1)))
  let right = new_map_property_holder()
  ignore(right.set_property(property, Some(3)))

  let comparator = property_holder_comparator_with(property)
  inspect(comparator.compare(left, right) < 0, content="true")
  inspect(comparator.compare(right, left) > 0, content="true")
}

///|
test "property value proxy resolves via callback" {
  let proxy = new_property_value_proxy((property : IProperty[Int]) => {
    Some(property.get_default() + 1)
  })
  let property = new_property("elk.test.proxy", 4)
  inspect(proxy.resolve_value(property) == Some(5), content="true")
}

///|
test "property-to-value map entry impl key/value accessors" {
  let property = new_property("elk.test.entry", 1)
  let entry_key : IProperty[Int]? = Some(property)
  let entry_value : Int? = Some(10)
  let entry = new_elk_property_to_value_map_entry_impl(
    key=entry_key,
    value=entry_value,
  )

  inspect(entry.get_typed_key() is Some(_), content="true")
  inspect(entry.get_typed_value() == Some(10), content="true")
  entry.set_typed_value(Some(15))
  inspect(entry.get_typed_value() == Some(15), content="true")
  entry.set_typed_key(None)
  inspect(entry.get_typed_key() is None, content="true")
}
