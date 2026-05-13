///|
test "GraphvizException keeps message and optional cause" {
  let without_cause = new_graphviz_exception("failed")
  debug_inspect(
    without_cause.get_message(),
    content=(
      #|"failed"
    ),
  )
  debug_inspect(without_cause.get_cause(), content="None")
  debug_inspect(
    without_cause.to_string(),
    content=(
      #|"failed"
    ),
  )

  let with_cause = new_graphviz_exception_with_cause("failed", "io")
  debug_inspect(with_cause.get_cause(), content="Some(\"io\")")
  debug_inspect(
    with_cause.to_string(),
    content=(
      #|"failed: io"
    ),
  )
}

///|
test "GraphvizLayouterPlugin controls shared instance and runtime detection" {
  graphviz_layouter_plugin_reset_for_test()
  debug_inspect(graphviz_layouter_is_eclipse_running(), content="false")

  let plugin = new_graphviz_layouter_plugin()
  plugin.start()
  debug_inspect(
    match graphviz_layouter_plugin_get_default() {
      Some(value) => value.get_bundle().get_symbolic_name()
      None => "none"
    },
    content=(
      #|"org.eclipse.elk.alg.graphviz.layouter"
    ),
  )
  debug_inspect(graphviz_layouter_is_eclipse_running(), content="true")

  plugin.stop()
  debug_inspect(graphviz_layouter_is_eclipse_running(), content="false")
}

///|
test "GraphvizLayouterPreferenceStore stores defaults and values" {
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()

  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  debug_inspect(
    store.get_symbolic_name(),
    content=(
      #|"org.eclipse.elk.alg.graphviz.layouter"
    ),
  )

  store.set_default_int("timeout", 20000)
  store.set_default_string("dot", "/usr/bin/dot")
  store.set_default_boolean("reuse", true)
  debug_inspect(store.get_int("timeout"), content="20000")
  debug_inspect(
    store.get_string("dot"),
    content=(
      #|"/usr/bin/dot"
    ),
  )
  debug_inspect(store.get_boolean("reuse"), content="true")

  store.set_int("timeout", 1000)
  store.set_string("dot", "/tmp/dot")
  store.set_boolean("reuse", false)
  debug_inspect(store.get_int("timeout"), content="1000")
  debug_inspect(
    store.get_string("dot"),
    content=(
      #|"/tmp/dot"
    ),
  )
  debug_inspect(store.get_boolean("reuse"), content="false")
}

///|
test "GraphvizLayouterPreferenceStoreAccess supports ui available fallback" {
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_preference_store_access_reset_for_test()
  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  store.set_default_int("timeout", 20000)
  store.set_default_string("dot", "/usr/bin/dot")
  store.set_default_boolean("reuse", true)

  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_int("timeout"),
    content="20000",
  )
  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_string("dot"),
    content=(
      #|"/usr/bin/dot"
    ),
  )
  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_boolean(
      "reuse", false,
    ),
    content="true",
  )

  graphviz_layouter_preference_store_access_set_ui_available_for_test(false)
  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_int("timeout"),
    content="0",
  )
  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_string("dot"),
    content=(
      #|""
    ),
  )
  debug_inspect(
    graphviz_layouter_preference_store_access_get_ui_save_boolean("reuse", true),
    content="true",
  )
}

///|
test "ForkedOutputStream writes flushes and closes all streams" {
  let sink0 = new_graphviz_byte_array_output_stream()
  let sink1 = new_graphviz_byte_array_output_stream()
  let stream0 = sink0.as_output_stream()
  let stream1 = sink1.as_output_stream()
  let forked = new_forked_output_stream2(stream0, stream1)

  forked.write(65)
  forked.write(66)
  forked.flush()
  forked.close()

  debug_inspect(sink0.get_bytes(), content="[65, 66]")
  debug_inspect(sink1.get_bytes(), content="[65, 66]")
  debug_inspect(sink0.get_flush_count(), content="1")
  debug_inspect(sink1.get_flush_count(), content="1")
  debug_inspect(sink0.is_closed(), content="true")
  debug_inspect(sink1.is_closed(), content="true")
}

///|
test "ForwardingInputStream forwards read bytes but does not close output stream" {
  let source = new_graphviz_byte_array_input_stream([1, 2, 3, 4, 5])
  let sink = new_graphviz_byte_array_output_stream()
  let forwarding = new_forwarding_input_stream(
    source.as_input_stream(),
    sink.as_output_stream(),
  )

  debug_inspect(forwarding.read(), content="1")
  let read_buffer = [0, 0, 0]
  debug_inspect(forwarding.read_bytes(read_buffer), content="3")
  debug_inspect(read_buffer, content="[2, 3, 4]")
  let offset_buffer = [9, 9, 9, 9]
  debug_inspect(
    forwarding.read_bytes_with_offset(offset_buffer, 1, 2),
    content="1",
  )
  debug_inspect(offset_buffer, content="[9, 5, 9, 9]")
  debug_inspect(forwarding.available(), content="0")
  debug_inspect(forwarding.skip(10), content="0")
  forwarding.close()

  debug_inspect(source.is_closed(), content="true")
  debug_inspect(sink.is_closed(), content="false")
  debug_inspect(sink.get_bytes(), content="[1, 2, 3, 4, 5]")
}

///|
test "ForwardingInputStream forwards mark and reset behavior" {
  let source = new_graphviz_byte_array_input_stream([10, 11, 12])
  let sink = new_graphviz_byte_array_output_stream()
  let forwarding = new_forwarding_input_stream(
    source.as_input_stream(),
    sink.as_output_stream(),
  )

  debug_inspect(forwarding.mark_supported(), content="true")
  debug_inspect(forwarding.read(), content="10")
  forwarding.mark(16)
  debug_inspect(forwarding.read(), content="11")
  forwarding.reset()
  debug_inspect(forwarding.read(), content="11")
  debug_inspect(forwarding.read(), content="12")
  debug_inspect(sink.get_bytes(), content="[10, 11, 11, 12]")
}
