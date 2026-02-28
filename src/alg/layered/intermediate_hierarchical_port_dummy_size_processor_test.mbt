///|
fn hierarchical_port_dummy_size_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      Normal => if name == "NORMAL" { return node_type }
      LongEdge => if name == "LONG_EDGE" { return node_type }
      ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NorthSouthPort => if name == "NORTH_SOUTH_PORT" { return node_type }
      LabelNode => if name == "LABEL_NODE" { return node_type }
      BreakingPoint => if name == "BREAKING_POINT" { return node_type }
      Placeholder => if name == "PLACEHOLDER" { return node_type }
      NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn hierarchical_port_dummy_size_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn hierarchical_port_dummy_size_test_new_graph_with_layer() -> (LGraph, Layer) {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  (graph, layer)
}

///|
fn hierarchical_port_dummy_size_test_new_external_port_dummy(
  graph : LGraph,
  layer : Layer,
  side : @core.PortSide,
) -> (LNode, LPort) {
  let node = new_l_node(graph=Some(graph))
  node.set_type(hierarchical_port_dummy_size_test_node_type("EXTERNAL_PORT"))
  node.set_layer(Some(layer))
  node.set_property_port_side(internal_properties_ext_port_side, side)

  let east_port = new_l_port()
  east_port.set_node(Some(node))
  east_port.set_side(hierarchical_port_dummy_size_test_port_side("EAST"))
  ignore(east_port.get_position().set_xy(-1.0, 0.0))

  (node, east_port)
}

///|
test "hierarchical port dummy size processor reports expected task name" {
  let processor = new_hierarchical_port_dummy_size_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(
    monitor.get_task_name(),
    content="Hierarchical port dummy size processing",
  )
}

///|
test "hierarchical port dummy size processor assigns north/south widths and east-port x positions" {
  let (graph, layer) = hierarchical_port_dummy_size_test_new_graph_with_layer()
  graph.set_property_double(
    layered_options_spacing_edge_edge_between_layers, 4.0,
  )

  let (north0, north0_east) = hierarchical_port_dummy_size_test_new_external_port_dummy(
    graph,
    layer,
    hierarchical_port_dummy_size_test_port_side("NORTH"),
  )
  let (north1, north1_east) = hierarchical_port_dummy_size_test_new_external_port_dummy(
    graph,
    layer,
    hierarchical_port_dummy_size_test_port_side("NORTH"),
  )
  let (south0, south0_east) = hierarchical_port_dummy_size_test_new_external_port_dummy(
    graph,
    layer,
    hierarchical_port_dummy_size_test_port_side("SOUTH"),
  )
  let (south1, south1_east) = hierarchical_port_dummy_size_test_new_external_port_dummy(
    graph,
    layer,
    hierarchical_port_dummy_size_test_port_side("SOUTH"),
  )
  let (south2, south2_east) = hierarchical_port_dummy_size_test_new_external_port_dummy(
    graph,
    layer,
    hierarchical_port_dummy_size_test_port_side("SOUTH"),
  )

  let processor = new_hierarchical_port_dummy_size_processor_layout_processor()
  processor.process(graph, None)

  // delta = 2 * spacing_edge_edge_between_layers = 8.0
  assert_eq(north0.get_size().x, 0.0)
  assert_eq(north1.get_size().x, 8.0)
  assert_eq(south0.get_size().x, 16.0)
  assert_eq(south1.get_size().x, 8.0)
  assert_eq(south2.get_size().x, 0.0)

  assert_eq(north0_east.get_position().x, 0.0)
  assert_eq(north1_east.get_position().x, 8.0)
  assert_eq(south0_east.get_position().x, 16.0)
  assert_eq(south1_east.get_position().x, 8.0)
  assert_eq(south2_east.get_position().x, 0.0)

  assert_eq(north0.get_property_string(@core.alignment), "CENTER")
  assert_eq(north1.get_property_string(@core.alignment), "CENTER")
  assert_eq(south0.get_property_string(@core.alignment), "CENTER")
  assert_eq(south1.get_property_string(@core.alignment), "CENTER")
  assert_eq(south2.get_property_string(@core.alignment), "CENTER")
}
