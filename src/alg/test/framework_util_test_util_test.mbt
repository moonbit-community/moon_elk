///|
test "TestUtil validates method signatures" {
  let errors : Array[String] = []
  let signature = new_test_method_signature(
    "sample",
    true,
    "ElkNode",
    ["ElkNode"],
    annotations=["GraphProvider"],
  )
  assert_true(test_util_ensure_public(signature, errors))
  assert_true(test_util_ensure_returns_type(signature, errors, "ElkNode"))
  assert_true(test_util_ensure_parameters(signature, errors, ["ElkNode"]))
  assert_false(
    test_util_ensure_not_annotated_with(signature, errors, ["GraphProvider"]),
  )
  assert_eq(errors.length(), 1)
}

///|
test "TestUtil validates constructor shape" {
  let errors : Array[String] = []
  assert_true(
    test_util_ensure_single_public_no_parameter_constructor(
      [new_test_class_constructor_signature(true, 0)],
      errors,
    ),
  )
  let more_errors : Array[String] = []
  assert_false(
    test_util_ensure_single_public_no_parameter_constructor(
      [
        new_test_class_constructor_signature(true, 0),
        new_test_class_constructor_signature(true, 1),
      ],
      more_errors,
    ),
  )
  assert_eq(more_errors.length(), 1)
}
