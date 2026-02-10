///|
test "LibavoidServerException stores message and cause" {
  let default_ex = new_libavoid_server_exception()
  inspect(default_ex.get_message(), content="")
  inspect(default_ex.get_cause(), content="None")

  let with_message = new_libavoid_server_exception_with_message("failed")
  inspect(with_message.get_message(), content="failed")
  inspect(with_message.to_string(), content="failed")

  let with_cause = new_libavoid_server_exception_with_cause("failed", "io")
  inspect(with_cause.get_cause(), content="Some(\"io\")")
  inspect(with_cause.to_string(), content="failed: io")
}

///|
test "LibavoidServer lifecycle supports initialize input cleanup and cancel" {
  let server = new_libavoid_server()
  inspect(server.is_running(), content="false")
  inspect(server.get_process_timeout(), content="60000")
  server.set_process_timeout(1234)
  inspect(server.get_process_timeout(), content="1234")

  server.initialize()
  inspect(server.is_running(), content="true")
  let input = server.input()
  input.write(65)
  input.write(66)
  input.flush()
  inspect(server.get_input_bytes(), content="[65, 66]")
  inspect(server.read_output_data(), content="Some({})")

  server.cleanup(libavoid_server_cleanup_normal())
  inspect(server.is_running(), content="true")
  server.cleanup(libavoid_server_cleanup_error())
  inspect(server.is_running(), content="false")

  server.initialize()
  server.cancel_process()
  inspect(server.is_canceled(), content="true")
  inspect(server.is_running(), content="false")
}

///|
test "LibavoidServerPool fetch release dispose and plugin stop interaction" {
  libavoid_server_pool_reset_for_test()
  libavoid_plugin_reset_for_test()

  let pool = libavoid_server_pool_instance()
  inspect(pool.size(), content="0")

  let server0 = pool.fetch()
  inspect(pool.size(), content="0")
  server0.initialize()
  pool.release(server0)
  inspect(pool.size(), content="1")

  let server1 = pool.fetch()
  inspect(pool.size(), content="0")
  pool.release(server1)
  inspect(pool.size(), content="1")

  let plugin = new_libavoid_plugin()
  plugin.start()
  inspect(
    match libavoid_plugin_get_default() {
      Some(value) => value.get_bundle().get_symbolic_name()
      None => ""
    },
    content="org.adaptagrams.cola.libavoid",
  )
  plugin.stop()
  inspect(libavoid_plugin_get_default() is None, content="true")
  inspect(pool.size(), content="0")
}
