///|
test "layout runtimes own independent registries and metadata" {
  let first = new_layout_runtime()
  let second = new_layout_runtime()

  first.register_layout_algorithm("test.algorithm", (
    _runtime,
    _session,
    _graph,
    _monitor,
  ) => ())
  first.register_elk_engine_layout_delegate((
    _runtime,
    _session,
    _graph,
    _options,
  ) => ())
  first.option_metadata().register_option(new_layout_option_data("test.option"))

  assert_true(first.layout_algorithm("test.algorithm") is Some(_))
  assert_true(second.layout_algorithm("test.algorithm") is None)
  assert_true(first.elk_engine_layout_delegate() is Some(_))
  assert_true(second.elk_engine_layout_delegate() is None)
  assert_true(first.option_metadata().option_data_opt("test.option") is Some(_))
  assert_true(second.option_metadata().option_data_opt("test.option") is None)
}

///|
test "layout sessions own independent error state" {
  let first = new_layout_session()
  let second = new_layout_session()

  first.report_unsupported_configuration("first failure")

  assert_true(first.has_error())
  assert_false(second.has_error())
  match first.take_error_message() {
    Some(message) =>
      assert_eq(
        message, "org.eclipse.elk.core.UnsupportedConfigurationException: first failure",
      )
    None => fail("expected the first session to own its error")
  }
  assert_false(first.has_error())
}
