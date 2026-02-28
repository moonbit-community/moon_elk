///|
fn plain_java_initialization_test_setup() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
}

///|
test "PlainJavaInitialization registers all expected algorithm ids" {
  plain_java_initialization_test_setup()
  plain_java_initialization_initialize_plain_java_layout()

  let expected_algorithm_ids = [
    "org.eclipse.elk.box", "org.eclipse.elk.disco", "org.eclipse.elk.fixed", "org.eclipse.elk.force",
    "org.eclipse.elk.layered", "org.eclipse.elk.mrtree", "org.eclipse.elk.radial",
    "org.eclipse.elk.random", rectpacking_algorithm_id, spore_compaction_algorithm_id,
    spore_overlap_removal_algorithm_id, "org.eclipse.elk.stress", vertiflex_algorithm_id,
  ]

  for algorithm_id in expected_algorithm_ids {
    assert_true(
      layout_meta_data_service_get_algorithm_data(algorithm_id) is Some(_),
    )
  }
}

///|
test "PlainJavaInitialization is idempotent" {
  plain_java_initialization_test_setup()
  plain_java_initialization_initialize_plain_java_layout()
  let first_count = layout_meta_data_service_algorithm_data_values().length()

  plain_java_initialization_initialize_plain_java_layout()
  let second_count = layout_meta_data_service_algorithm_data_values().length()

  assert_eq(first_count, second_count)
}
