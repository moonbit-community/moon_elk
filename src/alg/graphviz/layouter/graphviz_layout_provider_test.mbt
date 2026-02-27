///|
fn graphviz_layout_provider_test_model() -> @dot.DotGraphvizModel {
  let model = @dot.dot_create_graphviz_model()
  model.get_graphs().push(@dot.dot_create_graph())
  model
}

///|
fn graphviz_layout_provider_test_process(
  stdout_bytes : Array[Int],
  destroyed_ref : Ref[Int],
) -> GraphvizProcess {
  new_graphviz_process(
    new_graphviz_byte_array_output_stream().as_output_stream(),
    new_graphviz_byte_array_input_stream(stdout_bytes).as_input_stream(),
    new_graphviz_byte_array_input_stream([]).as_input_stream(),
    destroy_fn=() => destroyed_ref.val = destroyed_ref.val + 1,
    close_fn=() => (),
    exit_value_fn=() => Some(0),
  )
}

///|
test "GraphvizLayoutProvider reports invalid initialization parameter" {
  @core.layout_runtime_clear_error()
  let provider = new_graphviz_layout_provider()
  provider.initialize(Some("not-a-command"))
  inspect(
    @core.layout_runtime_take_error_message(),
    content="Some(\"org.eclipse.elk.core.UnsupportedConfigurationException: Invalid Graphviz command.\")",
  )
}

///|
test "GraphvizLayoutProvider reports missing initialize before layout" {
  @core.layout_runtime_clear_error()
  @graph.reset_graph_model_for_test()
  let provider = new_graphviz_layout_provider()
  let root = @graph.create_graph()
  ignore(@graph.create_node(Some(root)))
  provider.layout(root, @core.new_elk_progress_monitor())
  inspect(
    @core.layout_runtime_take_error_message(),
    content="Some(\"org.eclipse.elk.core.UnsupportedConfigurationException: The Graphviz layout provider is not initialized.\")",
  )
}

///|
test "GraphvizLayoutProvider returns early for empty parent" {
  graphviz_layout_provider_reset_runtime_for_test()
  graphviz_tool_reset_runtime_for_test()
  graphviz_tool_set_default_locations_for_test(["/usr/bin/"])
  graphviz_tool_set_executable_probe_for_test(path => path == "/usr/bin/dot")

  let process_count : Ref[Int] = Ref::new(0)
  graphviz_tool_set_process_factory_for_test(_args => {
    process_count.val = process_count.val + 1
    Some(
      graphviz_layout_provider_test_process(
        graphviz_layout_provider_test_default_graph_bytes_for_test(),
        Ref::new(0),
      ),
    )
  })

  let provider = new_graphviz_layout_provider()
  provider.initialize(Some("dot"))
  let root = @graph.create_graph()
  let monitor = @core.new_elk_progress_monitor()
  provider.layout(root, monitor)

  inspect(process_count.val, content="0")
  inspect(monitor.is_running(), content="false")
}

///|
test "GraphvizLayoutProvider runs pipeline and records debug streams" {
  @graph.reset_graph_model_for_test()
  graphviz_layout_provider_reset_runtime_for_test()
  graphviz_tool_reset_runtime_for_test()
  graphviz_tool_set_default_locations_for_test(["/usr/bin/"])
  graphviz_tool_set_executable_probe_for_test(path => path == "/usr/bin/dot")

  let destroyed_ref : Ref[Int] = Ref::new(0)
  let parse_input_ref : Ref[Array[Int]] = Ref::new([])
  let serialized_ref : Ref[Array[Int]] = Ref::new([])
  let parser_model = graphviz_layout_provider_test_model()

  graphviz_tool_set_process_factory_for_test(_args => {
    Some(
      graphviz_layout_provider_test_process(
        graphviz_layout_provider_test_default_graph_bytes_for_test(),
        destroyed_ref,
      ),
    )
  })
  graphviz_layout_provider_set_serializer_for_test(model => {
    ignore(model)
    serialized_ref.val = [100, 111, 116]
    serialized_ref.val
  })
  graphviz_layout_provider_set_parser_for_test(bytes => {
    parse_input_ref.val = bytes
    new_graphviz_layout_parse_result(parser_model)
  })

  let provider = new_graphviz_layout_provider()
  provider.initialize(Some("dot"))
  let root = @graph.create_graph()
  ignore(@graph.create_node(Some(root)))
  @graph.node_set_bool_property(root, graphviz_layout_provider_debug_mode, true)
  provider.layout(root, @core.new_elk_progress_monitor())

  inspect(serialized_ref.val, content="[100, 111, 116]")
  inspect(
    graphviz_layout_provider_get_debug_bytes_for_test("debug001-in.dot"),
    content="Some([100, 111, 116, 10])",
  )
  inspect(parse_input_ref.val.length() > 0, content="true")
  inspect(
    graphviz_layout_provider_get_debug_bytes_for_test("debug001-out.dot")
    is Some(_),
    content="true",
  )
  inspect(destroyed_ref.val, content="1")
}

///|
test "GraphvizLayoutProvider honors reuse-process preference and dispose stops tool" {
  @graph.reset_graph_model_for_test()
  graphviz_layout_provider_reset_runtime_for_test()
  graphviz_tool_reset_runtime_for_test()
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_preference_store_access_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()

  graphviz_tool_set_default_locations_for_test(["/usr/bin/"])
  graphviz_tool_set_executable_probe_for_test(path => path == "/usr/bin/dot")
  let destroyed_ref : Ref[Int] = Ref::new(0)
  graphviz_tool_set_process_factory_for_test(_args => {
    Some(
      graphviz_layout_provider_test_process(
        graphviz_layout_provider_test_default_graph_bytes_for_test(),
        destroyed_ref,
      ),
    )
  })
  graphviz_layout_provider_set_parser_for_test(_bytes => {
    new_graphviz_layout_parse_result(graphviz_layout_provider_test_model())
  })
  graphviz_layout_provider_set_serializer_for_test(_model => [103])

  let plugin = new_graphviz_layouter_plugin()
  plugin.start()
  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  store.set_boolean(graphviz_layout_provider_pref_graphviz_reuse_process, true)

  let provider = new_graphviz_layout_provider()
  provider.initialize(Some("dot"))
  let root = @graph.create_graph()
  ignore(@graph.create_node(Some(root)))
  provider.layout(root, @core.new_elk_progress_monitor())
  inspect(destroyed_ref.val, content="0")

  provider.dispose()
  inspect(destroyed_ref.val, content="1")
  plugin.stop()
}
