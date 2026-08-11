///|
test "property ids are stable and distinguish external names" {
  let first = property_id_from_string("org.eclipse.elk.direction")
  let repeated = property_id_from_string("org.eclipse.elk.direction")
  let second = property_id_from_string("org.eclipse.elk.algorithm")
  assert_eq(first, repeated)
  assert_true(first != second)
  assert_eq(
    new_property("org.eclipse.elk.direction", "UNDEFINED").get_property_id(),
    first,
  )
}
