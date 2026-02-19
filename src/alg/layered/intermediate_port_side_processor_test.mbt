///|
fn port_side_processor_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn port_side_processor_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "port side processor reports expected task name" {
  let processor = new_port_side_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Port side processing")
}

///|
test "port side processor fixes non-side-fixed constraints and assigns sides" {
  let processor = new_port_side_processor_layout_processor()
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_string(@core.port_constraints, "FREE")

  let source_node = new_l_node(graph=Some(graph))
  source_node.set_layer(Some(layer))
  let target_node = new_l_node(graph=Some(graph))
  target_node.set_layer(Some(layer))

  let node_input = new_l_port()
  node_input.set_node(Some(node))
  let node_output = new_l_port()
  node_output.set_node(Some(node))

  let source_out = new_l_port()
  source_out.set_node(Some(source_node))
  source_out.set_side(port_side_processor_test_port_side("EAST"))

  let target_in = new_l_port()
  target_in.set_node(Some(target_node))
  target_in.set_side(port_side_processor_test_port_side("WEST"))

  ignore(port_side_processor_test_new_edge(source_out, node_input))
  ignore(port_side_processor_test_new_edge(node_output, target_in))

  processor.process(graph, None)

  assert_eq(node.get_property_string(@core.port_constraints), "FIXED_SIDE")
  assert_eq(@core.port_side_to_string(node_input.get_side()), "WEST")
  assert_eq(@core.port_side_to_string(node_output.get_side()), "EAST")

  for port in node.get_ports() {
    assert_true(@core.port_side_to_string(port.get_side()) != "UNDEFINED")
  }
}

///|
test "port side processor keeps fixed-side constraints and only fills undefined ports" {
  let processor = new_port_side_processor_layout_processor()
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_string(@core.port_constraints, "FIXED_SIDE")

  let defined_port = new_l_port()
  defined_port.set_node(Some(node))
  defined_port.set_side(port_side_processor_test_port_side("NORTH"))

  let undefined_port = new_l_port()
  undefined_port.set_node(Some(node))

  let sink_node = new_l_node(graph=Some(graph))
  sink_node.set_layer(Some(layer))
  let sink_in = new_l_port()
  sink_in.set_node(Some(sink_node))
  sink_in.set_side(port_side_processor_test_port_side("WEST"))
  ignore(port_side_processor_test_new_edge(undefined_port, sink_in))

  processor.process(graph, None)

  assert_eq(node.get_property_string(@core.port_constraints), "FIXED_SIDE")
  assert_eq(@core.port_side_to_string(defined_port.get_side()), "NORTH")
  assert_eq(@core.port_side_to_string(undefined_port.get_side()), "EAST")
}

///|
test "port side processor set_port_side prefers port dummy side" {
  let node = new_l_node()
  let port = new_l_port()
  port.set_node(Some(node))

  let dummy = new_l_node()
  dummy.set_property_port_side(
    internal_properties_ext_port_side,
    port_side_processor_test_port_side("SOUTH"),
  )
  port.set_property_l_node(internal_properties_port_dummy, Some(dummy))

  port_side_processor_set_port_side(port)
  assert_eq(@core.port_side_to_string(port.get_side()), "SOUTH")
}
