///|
test "json import exception constructors" {
  let empty = new_json_import_exception()
  assert_eq(empty.get_message(), None)
  assert_eq(empty.get_cause(), None)

  let with_message = new_json_import_exception_message("broken json")
  assert_eq(with_message.get_message(), Some("broken json"))
  assert_eq(with_message.get_cause(), None)

  let with_cause = new_json_import_exception_cause("io error")
  assert_eq(with_cause.get_message(), None)
  assert_eq(with_cause.get_cause(), Some("io error"))

  let with_both = new_json_import_exception_message_cause("broken", "io")
  assert_eq(with_both.get_message(), Some("broken"))
  assert_eq(with_both.get_cause(), Some("io"))
}
