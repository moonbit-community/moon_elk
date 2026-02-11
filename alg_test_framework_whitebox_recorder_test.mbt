///|
test "WhiteboxRecorder records execution and failures" {
  let recorder = new_whitebox_recorder()
  let description = "testNoLayerlessNodes (1)"
  recorder.fire_test_started(description)
  recorder.fire_test_failure(
    new_run_failure(description, "There are layerless nodes left!"),
  )
  recorder.fire_test_finished(description)

  assert_true(recorder.was_executed(description))
  let failures = recorder.get_failures(description)
  assert_eq(failures.length(), 1)
  assert_eq(failures[0].get_message(), "There are layerless nodes left!")
}

///|
test "WhiteboxRecorder records assumption failures as failures" {
  let recorder = new_whitebox_recorder()
  let description = "testProperLayering (1)"
  recorder.fire_test_started(description)
  recorder.fire_test_assumption_failed(
    new_run_failure(description, "Edge points leftwards!"),
  )
  recorder.fire_test_finished(description)

  let failures = recorder.get_failures(description)
  assert_eq(failures.length(), 1)
  assert_eq(failures[0].get_message(), "Edge points leftwards!")
}

///|
test "WhiteboxRecorder reports not executed test as not executed" {
  let recorder = new_whitebox_recorder()
  assert_false(recorder.was_executed("neverExecuted (1)"))
  assert_eq(recorder.get_failures("neverExecuted (1)").length(), 0)
}
