///|
test "Unsupported exceptions preserve message and cause" {
  let configuration_exception = new_unsupported_configuration_exception_message_cause(
    "bad options", "unknown key",
  )
  inspect(
    configuration_exception.get_message(),
    content="Some(\"bad options\")",
  )
  inspect(configuration_exception.get_cause(), content="Some(\"unknown key\")")
  let graph_exception = new_unsupported_graph_exception_message("not connected")
  inspect(graph_exception.get_message(), content="Some(\"not connected\")")
  inspect(graph_exception.get_cause(), content="None")
}

///|
test "WrappedException preserves payload" {
  let wrapped = new_wrapped_exception_message_cause(
    "cannot instantiate", "illegal access",
  )
  inspect(wrapped.get_message(), content="Some(\"cannot instantiate\")")
  inspect(wrapped.get_cause(), content="illegal access")
}
