///|
test "json import exception constructors" {
  let empty = new_json_import_exception()
  @core_debug.assert_eq(empty.get_message(), None)
  @core_debug.assert_eq(empty.get_cause(), None)

  let with_message = new_json_import_exception_message("broken json")
  @core_debug.assert_eq(with_message.get_message(), Some("broken json"))
  @core_debug.assert_eq(with_message.get_cause(), None)

  let with_cause = new_json_import_exception_cause("io error")
  @core_debug.assert_eq(with_cause.get_message(), None)
  @core_debug.assert_eq(with_cause.get_cause(), Some("io error"))

  let with_both = new_json_import_exception_message_cause("broken", "io")
  @core_debug.assert_eq(with_both.get_message(), Some("broken"))
  @core_debug.assert_eq(with_both.get_cause(), Some("io"))
}
