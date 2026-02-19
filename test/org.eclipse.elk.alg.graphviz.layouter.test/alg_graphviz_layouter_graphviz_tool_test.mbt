///|
fn graphviz_tool_test_ascii(text : String) -> Array[Int] {
  let bytes : Array[Int] = []
  for ch in text {
    bytes.push(ch.to_int())
  }
  bytes
}

///|
fn graphviz_tool_test_byte_stream(bytes : Array[Int]) -> GraphvizInputStream {
  new_graphviz_byte_array_input_stream(bytes).as_input_stream()
}

///|
fn graphviz_tool_test_output_stream(
  sink : GraphvizByteArrayOutputStream,
) -> GraphvizOutputStream {
  sink.as_output_stream()
}

///|
fn graphviz_tool_test_fake_process(
  stdout_bytes : Array[Int],
  stderr_bytes : Array[Int],
  destroyed_ref : Ref[Int],
  closed_ref : Ref[Int],
) -> GraphvizProcess {
  let stdin_sink = new_graphviz_byte_array_output_stream()
  let stdout_stream = graphviz_tool_test_byte_stream(stdout_bytes)
  let stderr_stream = graphviz_tool_test_byte_stream(stderr_bytes)
  new_graphviz_process(
    graphviz_tool_test_output_stream(stdin_sink),
    stdout_stream,
    stderr_stream,
    destroy_fn=() => destroyed_ref.val = destroyed_ref.val + 1,
    close_fn=() => closed_ref.val = closed_ref.val + 1,
    exit_value_fn=() => Some(0),
  )
}

///|
test "panic GraphvizTool rejects invalid command" {
  ignore(new_graphviz_tool(command_parse("invalid")))
}

///|
test "GraphvizTool resolves executable from defaults and preferences" {
  graphviz_tool_reset_runtime_for_test()
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_preference_store_access_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()

  let available : Ref[Map[String, Bool]] = Ref::new({})
  graphviz_tool_set_executable_probe_for_test(path => {
    match available.val.get(path) {
      Some(value) => value
      None => false
    }
  })
  graphviz_tool_set_default_locations_for_test(["/opt/bin/"])
  available.val["/opt/bin/dot"] = true
  inspect(
    graphviz_tool_get_dot_executable_with_prompt(false),
    content="Some(\"/opt/bin/dot\")",
  )

  let plugin = new_graphviz_layouter_plugin()
  plugin.start()
  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  store.set_string(graphviz_tool_pref_graphviz_executable, "/pref/dot")
  available.val["/pref/dot"] = true
  inspect(
    graphviz_tool_get_dot_executable_with_prompt(false),
    content="Some(\"/pref/dot\")",
  )

  store.set_string(graphviz_tool_pref_graphviz_executable, "/invalid/dot")
  available.val["/opt/bin/dot"] = false
  graphviz_tool_set_handle_exec_path_for_test(() => {
    store.set_string(graphviz_tool_pref_graphviz_executable, "/prompt/dot")
    true
  })
  available.val["/prompt/dot"] = true
  inspect(
    graphviz_tool_get_dot_executable_with_prompt(true),
    content="Some(\"/prompt/dot\")",
  )
  plugin.stop()
}

///|
test "GraphvizTool initialize assembles command line and graph stream" {
  graphviz_tool_reset_runtime_for_test()
  graphviz_tool_set_default_locations_for_test(["/usr/bin/"])
  graphviz_tool_set_executable_probe_for_test(path => path == "/usr/bin/dot")

  let destroyed_ref : Ref[Int] = Ref::new(0)
  let closed_ref : Ref[Int] = Ref::new(0)
  graphviz_tool_set_process_factory_for_test(_args => {
    Some(
      graphviz_tool_test_fake_process(
        [123, 97, 92, 10, 98, 125],
        [],
        destroyed_ref,
        closed_ref,
      ),
    )
  })

  let tool = new_graphviz_tool(command_parse("dot"))
  tool.initialize(arguments=Some(["-Tdot"]))
  inspect(
    graphviz_tool_get_last_exec_args_for_test(),
    content="[\"/usr/bin/dot\", \"-q\", \"-y\", \"-Kdot\", \"-Tdot\"]",
  )

  let output = tool.output()
  let stream_bytes : Array[Int] = []
  let mut next = output.read()
  while next >= 0 {
    stream_bytes.push(next)
    next = output.read()
  }
  inspect(stream_bytes, content="[123, 97, 98, 125]")
  inspect(output.read(), content="-1")

  tool.cleanup(graphviz_cleanup_stop())
  inspect(destroyed_ref.val, content="1")
  inspect(closed_ref.val, content="1")
}

///|
test "panic GraphvizTool cleanup error raises GraphvizException message" {
  graphviz_tool_reset_runtime_for_test()
  graphviz_tool_set_default_locations_for_test(["/usr/bin/"])
  graphviz_tool_set_executable_probe_for_test(path => path == "/usr/bin/dot")

  let destroyed_ref : Ref[Int] = Ref::new(0)
  let closed_ref : Ref[Int] = Ref::new(0)
  graphviz_tool_set_process_factory_for_test(_args => {
    Some(
      graphviz_tool_test_fake_process(
        [123, 125],
        graphviz_tool_test_ascii("boom"),
        destroyed_ref,
        closed_ref,
      ),
    )
  })
  let tool = new_graphviz_tool(command_parse("dot"))
  tool.initialize()
  ignore(tool.output().read())
  tool.cleanup(graphviz_cleanup_error())
}
