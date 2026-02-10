///|
fn libavoid_test_ascii(text : String) -> Array[Int] {
  let bytes : Array[Int] = []
  for ch in text {
    bytes.push(ch.to_int())
  }
  bytes
}

///|
fn libavoid_test_bytes_contains(bytes : Array[Int], token : String) -> Bool {
  let needle = libavoid_test_ascii(token)
  if needle.is_empty() {
    return true
  }
  if bytes.length() < needle.length() {
    return false
  }
  let mut i = 0
  while i + needle.length() <= bytes.length() {
    let mut matched = true
    let mut j = 0
    while j < needle.length() {
      if bytes[i + j] != needle[j] {
        matched = false
        break
      }
      j = j + 1
    }
    if matched {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn libavoid_test_main_graph() -> (ElkNode, ElkPort, ElkPort, ElkEdge) {
  reset_graph_model_for_test()
  let root = create_graph()
  let left = create_node(Some(root))
  node_set_location(left, 10.0, 10.0)
  node_set_dimensions(left, 20.0, 20.0)
  let right = create_node(Some(root))
  node_set_location(right, 50.0, 10.0)
  node_set_dimensions(right, 20.0, 20.0)

  let src_port = create_port(Some(left))
  port_set_location(src_port, 20.0, 8.0)
  port_set_dimensions(src_port, 4.0, 4.0)
  port_set_layout_option_string_by_id(src_port, port_side.get_id(), "EAST")

  let tgt_port = create_port(Some(right))
  port_set_location(tgt_port, 0.0, 8.0)
  port_set_dimensions(tgt_port, 4.0, 4.0)
  port_set_layout_option_string_by_id(tgt_port, port_side.get_id(), "WEST")

  let edge = create_edge(Some(root))
  edge_add_source(edge, make_port_shape(src_port))
  edge_add_target(edge, make_port_shape(tgt_port))
  (root, src_port, tgt_port, edge)
}

///|
test "LibavoidServerCommunicator writes protocol text and applies output layout" {
  let (root, src_port, tgt_port, edge) = libavoid_test_main_graph()
  ignore(src_port)
  ignore(tgt_port)

  node_set_string_property(root, libavoid_option_edge_routing, "ORTHOGONAL")
  node_set_string_property(root, libavoid_option_direction, "RIGHT")
  node_set_bool_property(
    root, libavoid_option_enable_hyperedges_from_common_source, true,
  )
  node_set_bool_property(root, libavoid_option_debug_mode, true)
  node_set_double_property(root, libavoid_option_segment_penalty, 12.0)

  let communicator = new_libavoid_server_communicator()
  let server = new_libavoid_server()
  server.set_output_data_for_test(Some({ "PEDGEP 1": "11 12 21 22 31 32" }))
  communicator.request_layout(root, new_elk_progress_monitor(), server)

  let input_bytes = server.get_input_bytes()
  inspect(
    libavoid_test_bytes_contains(input_bytes, "OPTION edgeRouting ORTHOGONAL\n"),
    content="true",
  )
  inspect(
    libavoid_test_bytes_contains(input_bytes, "OPTION direction RIGHT\n"),
    content="true",
  )
  inspect(
    libavoid_test_bytes_contains(
      input_bytes, "OPTION enableHyperedgesFromCommonSource true\n",
    ),
    content="true",
  )
  inspect(
    libavoid_test_bytes_contains(input_bytes, "PENALTY segmentPenalty 12"),
    content="true",
  )
  inspect(libavoid_test_bytes_contains(input_bytes, "GRAPH\n"), content="true")
  inspect(
    libavoid_test_bytes_contains(input_bytes, "[CHUNK]\n"),
    content="true",
  )

  let section = edge_sections(edge)[0]
  inspect(edge_section_start_x(section), content="11")
  inspect(edge_section_start_y(section), content="12")
  inspect(edge_section_end_x(section), content="31")
  inspect(edge_section_end_y(section), content="32")
  inspect(node_width(root), content="70")
  inspect(node_height(root), content="32")
}

///|
test "panic LibavoidServerCommunicator fails if server has no output" {
  let (root, _, _, _) = libavoid_test_main_graph()
  let communicator = new_libavoid_server_communicator()
  let server = new_libavoid_server()
  server.set_output_data_for_test(None)
  communicator.request_layout(root, new_elk_progress_monitor(), server)
}

///|
fn libavoid_test_provider_graph() -> (ElkNode, ElkPort, ElkPort, ElkEdge) {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_string_property(root, libavoid_option_direction, "RIGHT")

  let left = create_node(Some(root))
  node_set_location(left, 10.0, 10.0)
  node_set_dimensions(left, 20.0, 20.0)
  let right = create_node(Some(root))
  node_set_location(right, 70.0, 10.0)
  node_set_dimensions(right, 20.0, 20.0)

  let src_port = create_port(Some(left))
  port_set_location(src_port, 20.0, 8.0)
  port_set_dimensions(src_port, 4.0, 4.0)
  let tgt_port = create_port(Some(right))
  port_set_location(tgt_port, 0.0, 8.0)
  port_set_dimensions(tgt_port, 4.0, 4.0)

  let edge = create_edge(Some(root))
  edge_add_source(edge, make_port_shape(src_port))
  edge_add_target(edge, make_port_shape(tgt_port))
  (root, src_port, tgt_port, edge)
}

///|
test "LibavoidLayoutProvider prepares ports routes and releases server" {
  libavoid_server_pool_reset_for_test()
  let provided_server = new_libavoid_server()
  provided_server.set_output_data_for_test(Some({ "PEDGEP 1": "15 15 30 15" }))
  libavoid_server_pool_set_factory_for_test(() => provided_server)

  let (root, src_port, tgt_port, edge) = libavoid_test_provider_graph()
  let provider = new_libavoid_layout_provider()
  let monitor = new_elk_progress_monitor()
  provider.layout(root, monitor)

  inspect(
    port_layout_option_string_value(src_port, port_side.get_id()),
    content="Some(\"EAST\")",
  )
  inspect(
    port_layout_option_string_value(tgt_port, port_side.get_id()),
    content="Some(\"WEST\")",
  )
  inspect(edge_sections(edge).length(), content="1")
  inspect(libavoid_server_pool_instance().size(), content="1")
  inspect(monitor.is_running(), content="false")
}

///|
test "LibavoidLayoutProvider cancel layouting cancels mapped server" {
  reset_graph_model_for_test()
  let provider = new_libavoid_layout_provider()
  let root = create_graph()
  let server = new_libavoid_server()
  server.initialize()
  provider.register_server_for_test(root, server)
  inspect(provider.cancel_layouting(root), content="true")
  inspect(server.is_canceled(), content="true")
  inspect(provider.cancel_layouting(root), content="false")
}
