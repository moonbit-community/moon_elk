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
fn libavoid_test_main_graph() -> (
  @graph.ElkNode,
  @graph.ElkPort,
  @graph.ElkPort,
  @graph.ElkEdge,
) {
  let root = create_graph()
  let left = @graph.create_node(Some(root))
  @graph.node_set_location(left, 10.0, 10.0)
  @graph.node_set_dimensions(left, 20.0, 20.0)
  let right = @graph.create_node(Some(root))
  @graph.node_set_location(right, 50.0, 10.0)
  @graph.node_set_dimensions(right, 20.0, 20.0)

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

  @graph.node_set_string_property(
    root, libavoid_option_edge_routing, "ORTHOGONAL",
  )
  @graph.node_set_string_property(root, libavoid_option_direction, "RIGHT")
  @graph.node_set_bool_property(
    root, libavoid_option_enable_hyperedges_from_common_source, true,
  )
  @graph.node_set_bool_property(root, libavoid_option_debug_mode, true)
  @graph.node_set_double_property(root, libavoid_option_segment_penalty, 12.0)

  let communicator = new_libavoid_server_communicator()
  let server = new_libavoid_server()
  server.set_output_data_for_test(Some({ "PEDGEP 1": "11 12 21 22 31 32" }))
  communicator.request_layout(
    root,
    new_elk_progress_monitor(),
    server,
    @core.new_layout_session(),
  )

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

  let section = @graph.edge_sections(edge)[0]
  inspect(@graph.edge_section_start_x(section), content="11")
  inspect(@graph.edge_section_start_y(section), content="12")
  inspect(@graph.edge_section_end_x(section), content="31")
  inspect(@graph.edge_section_end_y(section), content="32")
  inspect(@graph.node_width(root), content="82")
  inspect(@graph.node_height(root), content="44")
}

///|
test "LibavoidServerCommunicator reports error if server has no output" {
  let (root, _, _, _) = libavoid_test_main_graph()
  let communicator = new_libavoid_server_communicator()
  let server = new_libavoid_server()
  server.set_output_data_for_test(None)
  let monitor = new_elk_progress_monitor()
  let session = @core.new_layout_session()
  communicator.request_layout(root, monitor, server, session)
  let message = match session.take_error_message() {
    Some(message) => message
    None => ""
  }
  inspect(monitor.is_running(), content="false")
  inspect(
    message,
    content="org.eclipse.elk.core.UnsupportedConfigurationException: No output from the Libavoid process. Try increasing the timeout value in the preferences (KIELER / Layout / Libavoid).",
  )
}

///|
fn libavoid_test_provider_graph() -> (
  @graph.ElkNode,
  @graph.ElkPort,
  @graph.ElkPort,
  @graph.ElkEdge,
) {
  let root = create_graph()
  @graph.node_set_string_property(root, libavoid_option_direction, "RIGHT")

  let left = @graph.create_node(Some(root))
  @graph.node_set_location(left, 10.0, 10.0)
  @graph.node_set_dimensions(left, 20.0, 20.0)
  let right = @graph.create_node(Some(root))
  @graph.node_set_location(right, 70.0, 10.0)
  @graph.node_set_dimensions(right, 20.0, 20.0)

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
  provider.layout(root, monitor, @core.new_layout_session())

  debug_inspect(
    port_layout_option_string_value(src_port, port_side.get_id()),
    content="Some(\"EAST\")",
  )
  debug_inspect(
    port_layout_option_string_value(tgt_port, port_side.get_id()),
    content="Some(\"WEST\")",
  )
  inspect(@graph.edge_sections(edge).length(), content="1")
  inspect(libavoid_server_pool_instance().size(), content="1")
  inspect(monitor.is_running(), content="false")
}

///|
test "LibavoidLayoutProvider cancel layouting cancels mapped server" {
  let provider = new_libavoid_layout_provider()
  let root = create_graph()
  let server = new_libavoid_server()
  server.initialize()
  provider.register_server_for_test(root, server)
  inspect(provider.cancel_layouting(root), content="true")
  inspect(server.is_canceled(), content="true")
  inspect(provider.cancel_layouting(root), content="false")
}

///|
test "Libavoid cluster children preserve local x and y coordinates" {
  let root = create_graph()
  @graph.node_set_string_property(root, libavoid_option_direction, "RIGHT")

  let cluster = @graph.create_node(Some(root))
  @graph.node_set_location(cluster, 100.0, 200.0)
  @graph.node_set_dimensions(cluster, 50.0, 50.0)
  @graph.node_set_bool_property(cluster, libavoid_option_is_cluster, true)

  let child = @graph.create_node(Some(cluster))
  @graph.node_set_location(child, 5.0, 7.0)
  @graph.node_set_dimensions(child, 10.0, 10.0)

  let communicator = new_libavoid_server_communicator()
  let server = new_libavoid_server()
  server.set_output_data_for_test(Some(Map([])))
  communicator.request_layout(
    root,
    new_elk_progress_monitor(),
    server,
    @core.new_layout_session(),
  )

  inspect(
    libavoid_test_bytes_contains(
      server.get_input_bytes(),
      "NODE 6 105 207 115 217 0 0\n",
    ),
    content="true",
  )
}

///|
test "Libavoid registration installs an opt-in engine algorithm" {
  libavoid_server_pool_reset_for_test()
  let server = new_libavoid_server()
  server.set_output_data_for_test(Some(Map([])))
  libavoid_server_pool_set_factory(() => server)

  let builder = @engine.new_engine_builder()
  ignore(
    builder.add_layout_algorithm(
      "libavoid", libavoid_algorithm_id, register_libavoid_layout_algorithm,
    ),
  )
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string(libavoid_algorithm_id),
    }),
    "children": Json::array([
      Json::object({
        "id": Json::string("node"),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
    ]),
  })

  let output = builder.build().layout(graph~)
  match output {
    Object(fields) => assert_eq(fields["id"], Json::string("root"))
    _ => fail("expected graph object")
  }
  libavoid_server_reset_runtime_for_test()
}

///|
test "Libavoid text runner executes through custom engine" {
  libavoid_server_pool_reset_for_test()
  let server = new_libavoid_server()
  server.set_transport(
    Some(
      new_libavoid_server_transport_from_text_runner((_input, _timeout) => {
        Some("LAYOUT\nEDGE 1=10 20 30 40\nDONE\n")
      }),
    ),
  )
  libavoid_server_pool_set_factory(() => server)

  let builder = @engine.new_engine_builder()
  ignore(
    builder.add_layout_algorithm(
      "libavoid", libavoid_algorithm_id, register_libavoid_layout_algorithm,
    ),
  )
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string(libavoid_algorithm_id),
    }),
    "children": Json::array([
      Json::object({
        "id": Json::string("n1"),
        "x": Json::number(10),
        "y": Json::number(20),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
      Json::object({
        "id": Json::string("n2"),
        "x": Json::number(60),
        "y": Json::number(20),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
    ]),
    "edges": Json::array([
      Json::object({
        "id": Json::string("e1"),
        "sources": Json::array([Json::string("n1")]),
        "targets": Json::array([Json::string("n2")]),
      }),
    ]),
  })

  let output = builder.build().layout(graph~)
  guard output is Object(fields) else { fail("expected graph object") }
  guard fields.get("edges") is Some(Array([Object(edge)])) else {
    fail("expected one edge")
  }
  guard edge.get("sections") is Some(Array([Object(section)])) else {
    fail("expected one edge section")
  }
  guard section.get("startPoint") is Some(Object(start)) else {
    fail("expected start point")
  }
  guard section.get("endPoint") is Some(Object(end)) else {
    fail("expected end point")
  }
  guard start.get("x") is Some(Number(start_x, ..)) else {
    fail("expected start x")
  }
  guard start.get("y") is Some(Number(start_y, ..)) else {
    fail("expected start y")
  }
  guard end.get("x") is Some(Number(end_x, ..)) else { fail("expected end x") }
  guard end.get("y") is Some(Number(end_y, ..)) else { fail("expected end y") }
  assert_eq(start_x.to_int(), 10)
  assert_eq(start_y.to_int(), 20)
  assert_eq(end_x.to_int(), 30)
  assert_eq(end_y.to_int(), 40)
}

///|
test "Libavoid text runner helper registers and executes" {
  libavoid_server_pool_reset_for_test()
  let builder = @engine.new_engine_builder()
  ignore(
    add_libavoid_layout_algorithm_with_text_runner(builder, (_input, _timeout) => {
      Some("LAYOUT\nEDGE 1=1 2 3 4\nDONE\n")
    }),
  )
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string(libavoid_algorithm_id),
    }),
    "children": Json::array([
      Json::object({
        "id": Json::string("n1"),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
      Json::object({
        "id": Json::string("n2"),
        "width": Json::number(20),
        "height": Json::number(10),
      }),
    ]),
    "edges": Json::array([
      Json::object({
        "id": Json::string("e1"),
        "sources": Json::array([Json::string("n1")]),
        "targets": Json::array([Json::string("n2")]),
      }),
    ]),
  })

  let output = builder.build().layout(graph~)
  match output {
    Object(fields) => assert_eq(fields["id"], Json::string("root"))
    _ => fail("expected graph object")
  }
  libavoid_server_reset_runtime_for_test()
}
