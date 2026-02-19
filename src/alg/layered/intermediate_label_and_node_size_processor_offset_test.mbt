///|
fn label_and_node_size_offset_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_and_node_size_offset_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn label_and_node_size_offset_test_graph_property(
  name : String,
) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
fn label_and_node_size_offset_test_new_port(
  node : LNode,
  side : @core.PortSide,
  x : Double,
  y : Double,
) -> LPort {
  let port = new_l_port()
  port.set_property_double(@common.nodespacing_port_border_offset_property, 0.0)
  port.set_side(side)
  ignore(port.get_position().set_xy(x, y))
  port.set_node(Some(node))
  port
}

///|
fn label_and_node_size_offset_test_generate_node(
  graph : LGraph,
  constraints : String,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_property_string(@core.port_constraints, constraints)
  ignore(node.get_size().set_xy(100.0, 100.0))
  graph.get_layerless_nodes().push(node)

  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("NORTH"),
      50.0,
      -300.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("SOUTH"),
      50.0,
      300.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("EAST"),
      300.0,
      50.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("WEST"),
      -300.0,
      50.0,
    ),
  )

  node
}

///|
fn label_and_node_size_offset_test_add_external_port_dummy(
  graph : LGraph,
  layer : Layer,
  side : @core.PortSide,
  connected_to_external : Bool,
) -> (LNode, LPort, LLabel, LLabel) {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_type(label_and_node_size_offset_test_node_type("EXTERNAL_PORT"))
  node.set_property_port_side(internal_properties_ext_port_side, side)
  ignore(node.get_size().set_xy(20.0, 30.0))
  node.set_property_double(@core.spacing_label_port_horizontal, 2.0)
  node.set_property_double(@core.spacing_label_port_vertical, 3.0)
  node.set_property_double(@core.spacing_label_label, 1.0)

  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(label_and_node_size_offset_test_port_side("EAST"))
  ignore(port.get_position().set_xy(5.0, 9.0))
  port.set_connected_to_external_nodes(connected_to_external)

  let label0 = new_l_label()
  ignore(label0.get_size().set_xy(6.0, 4.0))
  let label1 = new_l_label()
  ignore(label1.get_size().set_xy(8.0, 2.0))
  port.get_labels().push(label0)
  port.get_labels().push(label1)
  (node, port, label0, label1)
}

///|
test "label and node size processor places ports on node border with zero offset" {
  let graph = new_l_graph()
  ignore(label_and_node_size_offset_test_generate_node(graph, "FREE"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_SIDE"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_ORDER"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_RATIO"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_POS"))

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  for node in graph.get_layerless_nodes() {
    for port in node.get_ports() {
      match port.get_side() {
        @core.PortSide::North =>
          assert_double_eq(port.get_position().y, -port.get_size().y, 0.0)
        @core.PortSide::South =>
          assert_double_eq(port.get_position().y, node.get_size().y, 0.0)
        @core.PortSide::East =>
          assert_double_eq(port.get_position().x, node.get_size().x, 0.0)
        @core.PortSide::West =>
          assert_double_eq(port.get_position().x, -port.get_size().x, 0.0)
        _ => abort("unexpected port side")
      }
    }
  }
}

///|
test "label and node size processor places external east dummy labels next to port when requested" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [label_and_node_size_offset_test_graph_property("EXTERNAL_PORTS")],
  )
  graph.set_property_string_array(@core.port_labels_placement, [
    "OUTSIDE", "NEXT_TO_PORT_IF_POSSIBLE",
  ])
  graph.set_property_bool(@core.port_labels_treat_as_group, true)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let (_, _, label0, label1) = label_and_node_size_offset_test_add_external_port_dummy(
    graph,
    layer,
    label_and_node_size_offset_test_port_side("EAST"),
    false,
  )

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  assert_double_eq(label0.get_position().x, 0.0, 0.0)
  assert_double_eq(label0.get_position().y, 2.5, 0.0)
  assert_double_eq(label1.get_position().x, 0.0, 0.0)
  assert_double_eq(label1.get_position().y, 7.5, 0.0)
}

///|
test "label and node size processor places external east dummy labels by first label center when treatAsGroup is false" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [label_and_node_size_offset_test_graph_property("EXTERNAL_PORTS")],
  )
  graph.set_property_string_array(@core.port_labels_placement, [
    "OUTSIDE", "NEXT_TO_PORT_IF_POSSIBLE",
  ])
  graph.set_property_bool(@core.port_labels_treat_as_group, false)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let (_, _, label0, label1) = label_and_node_size_offset_test_add_external_port_dummy(
    graph,
    layer,
    label_and_node_size_offset_test_port_side("EAST"),
    false,
  )

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  assert_double_eq(label0.get_position().x, 0.0, 0.0)
  assert_double_eq(label0.get_position().y, 4.0, 0.0)
  assert_double_eq(label1.get_position().x, 0.0, 0.0)
  assert_double_eq(label1.get_position().y, 9.0, 0.0)
}

///|
test "label and node size processor places external east dummy labels below port when port is connected" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [label_and_node_size_offset_test_graph_property("EXTERNAL_PORTS")],
  )
  graph.set_property_string_array(@core.port_labels_placement, [
    "OUTSIDE", "NEXT_TO_PORT_IF_POSSIBLE",
  ])
  graph.set_property_bool(@core.port_labels_treat_as_group, true)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let (_, _, label0, label1) = label_and_node_size_offset_test_add_external_port_dummy(
    graph,
    layer,
    label_and_node_size_offset_test_port_side("EAST"),
    true,
  )

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  assert_double_eq(label0.get_position().x, 0.0, 0.0)
  assert_double_eq(label0.get_position().y, 12.0, 0.0)
  assert_double_eq(label1.get_position().x, 0.0, 0.0)
  assert_double_eq(label1.get_position().y, 17.0, 0.0)
}

///|
test "label and node size processor places external north dummy labels inside node" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [label_and_node_size_offset_test_graph_property("EXTERNAL_PORTS")],
  )
  graph.set_property_string_array(@core.port_labels_placement, ["INSIDE"])
  graph.set_property_bool(@core.port_labels_treat_as_group, true)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  let (_, _, label0, label1) = label_and_node_size_offset_test_add_external_port_dummy(
    graph,
    layer,
    label_and_node_size_offset_test_port_side("NORTH"),
    false,
  )

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  assert_double_eq(label0.get_position().x, 1.0, 0.0)
  assert_double_eq(label0.get_position().y, 3.0, 0.0)
  assert_double_eq(label1.get_position().x, 1.0, 0.0)
  assert_double_eq(label1.get_position().y, 8.0, 0.0)
}
