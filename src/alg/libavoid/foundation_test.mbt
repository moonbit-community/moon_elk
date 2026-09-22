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
  inspect(default_ex.get_message(), content="")
  debug_inspect(default_ex.get_cause(), content="None")

  let with_message = new_libavoid_server_exception_with_message("failed")
  inspect(with_message.get_message(), content="failed")
  inspect(with_message.to_string(), content="failed")

  let with_cause = new_libavoid_server_exception_with_cause("failed", "io")
  debug_inspect(with_cause.get_cause(), content="Some(\"io\")")
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

///|
test "LibavoidServer executes configured transport with protocol input" {
  libavoid_server_reset_runtime_for_test()
  let captured_input_ref : Ref[Array[Int]] = Ref([])
  let captured_timeout_ref : Ref[Int] = Ref(0)
  libavoid_server_set_default_transport(
    Some(
      new_libavoid_server_transport((input, timeout) => {
        captured_input_ref.val = input
        captured_timeout_ref.val = timeout
        Some({ "PEDGEP 1": "1 2 3 4" })
      }),
    ),
  )

  let server = new_libavoid_server()
  server.initialize()
  let input = libavoid_server_input_or_abort(server)
  input.write(65)
  input.write(66)
  input.flush()

  let output = libavoid_server_read_output_data_or_abort(server)
  debug_inspect(captured_input_ref.val, content="[65, 66]")
  inspect(captured_timeout_ref.val, content="60000")
  match output {
    Some(data) => inspect(data["PEDGEP 1"], content="1 2 3 4")
    None => abort("expected transport output")
  }
  libavoid_server_reset_runtime_for_test()
}

///|
test "Libavoid server output parser reads LAYOUT blocks" {
  let output = "DEBUG ignored\nLAYOUT\nPEDGEP 1=1 2 3 4\nEDGE 2=5 6 7 8\nDONE\n"
  let parsed = libavoid_parse_server_output(output)
  inspect(parsed["PEDGEP 1"], content="1 2 3 4")
  inspect(parsed["EDGE 2"], content="5 6 7 8")
}

///|
test "panic Libavoid server output parser reports ERROR blocks" {
  ignore(libavoid_parse_server_output("ERROR\nfirst line\nsecond line\nDONE\n"))
}

///|
test "Libavoid text runner transport parses server output" {
  libavoid_server_reset_runtime_for_test()
  let captured_input_ref : Ref[Array[Int]] = Ref([])
  let captured_timeout_ref : Ref[Int] = Ref(0)
  libavoid_server_set_default_transport(
    Some(
      new_libavoid_server_transport_from_text_runner((input, timeout) => {
        captured_input_ref.val = input
        captured_timeout_ref.val = timeout
        Some("LAYOUT\nPEDGEP 1=4 5 6 7\nDONE\n")
      }),
    ),
  )

  let server = new_libavoid_server()
  server.initialize()
  let input = libavoid_server_input_or_abort(server)
  input.write(71)
  input.write(82)
  input.flush()
  let output = libavoid_server_read_output_data_or_abort(server)

  debug_inspect(captured_input_ref.val, content="[71, 82]")
  inspect(captured_timeout_ref.val, content="60000")
  match output {
    Some(data) => inspect(data["PEDGEP 1"], content="4 5 6 7")
    None => abort("expected parsed transport output")
  }
  libavoid_server_reset_runtime_for_test()
}
