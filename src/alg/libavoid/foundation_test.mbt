///|
fn libavoid_server_input_or_abort(
  server : LibavoidServer,
) -> @layouter.GraphvizOutputStream {
  try server.input() catch {
    err => abort(libavoid_server_state_exception_message(err))
  } noraise {
    stream => stream
  }
}

///|
fn libavoid_server_read_output_data_or_abort(
  server : LibavoidServer,
) -> Map[String, String]? {
  try server.read_output_data() catch {
    err => abort(libavoid_server_state_exception_message(err))
  } noraise {
    output => output
  }
}

///|
test "LibavoidServerException stores message and cause" {
  let default_ex = new_libavoid_server_exception()
  debug_inspect(default_ex.get_message(), content="")
  debug_inspect(default_ex.get_cause(), content="None")

  let with_message = new_libavoid_server_exception_with_message("failed")
  debug_inspect(with_message.get_message(), content="failed")
  debug_inspect(with_message.to_string(), content="failed")

  let with_cause = new_libavoid_server_exception_with_cause("failed", "io")
  debug_inspect(with_cause.get_cause(), content="Some(\"io\")")
  debug_inspect(with_cause.to_string(), content="failed: io")
}

///|
test "LibavoidServer lifecycle supports initialize input cleanup and cancel" {
  let server = new_libavoid_server()
  debug_inspect(server.is_running(), content="false")
  debug_inspect(server.get_process_timeout(), content="60000")
  server.set_process_timeout(1234)
  debug_inspect(server.get_process_timeout(), content="1234")

  server.initialize()
  debug_inspect(server.is_running(), content="true")
  let input = libavoid_server_input_or_abort(server)
  input.write(65)
  input.write(66)
  input.flush()
  debug_inspect(server.get_input_bytes(), content="[65, 66]")
  debug_inspect(
    libavoid_server_read_output_data_or_abort(server),
    content="Some({})",
  )

  server.cleanup(libavoid_server_cleanup_normal())
  debug_inspect(server.is_running(), content="true")
  server.cleanup(libavoid_server_cleanup_error())
  debug_inspect(server.is_running(), content="false")

  server.initialize()
  server.cancel_process()
  debug_inspect(server.is_canceled(), content="true")
  debug_inspect(server.is_running(), content="false")
}

///|
test "LibavoidServerPool fetch release dispose and plugin stop interaction" {
  libavoid_server_pool_reset_for_test()
  libavoid_plugin_reset_for_test()

  let pool = libavoid_server_pool_instance()
  debug_inspect(pool.size(), content="0")

  let server0 = pool.fetch()
  debug_inspect(pool.size(), content="0")
  server0.initialize()
  pool.release(server0)
  debug_inspect(pool.size(), content="1")

  let server1 = pool.fetch()
  debug_inspect(pool.size(), content="0")
  pool.release(server1)
  debug_inspect(pool.size(), content="1")

  let plugin = new_libavoid_plugin()
  plugin.start()
  debug_inspect(
    match libavoid_plugin_get_default() {
      Some(value) => value.get_bundle().get_symbolic_name()
      None => ""
    },
    content="org.adaptagrams.cola.libavoid",
  )
  plugin.stop()
  debug_inspect(libavoid_plugin_get_default() is None, content="true")
  debug_inspect(pool.size(), content="0")
}
