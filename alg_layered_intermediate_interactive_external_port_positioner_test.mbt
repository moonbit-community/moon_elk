///|
fn interactive_external_port_positioner_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown intermediate processor strategy")
}

///|
fn interactive_external_port_positioner_test_graph_property(
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
fn interactive_external_port_positioner_test_node_type(
  name : String,
) -> NodeType {
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
fn interactive_external_port_positioner_test_port_side(
  name : String,
) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn interactive_external_port_positioner_test_new_node(
  graph : LGraph,
  node_type : NodeType,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  margin_top : Double,
  margin_right : Double,
  margin_bottom : Double,
  margin_left : Double,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_type(node_type)
  ignore(node.get_position().set_xy(x, y))
  ignore(node.get_size().set_xy(width, height))
  node
  .get_margin()
  .set_values(margin_top, margin_right, margin_bottom, margin_left)
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn interactive_external_port_positioner_test_new_port(
  node : LNode,
  side : PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port
}

///|
fn interactive_external_port_positioner_test_connect(
  source : LPort,
  target : LPort,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "interactive external port positioner strategy applies west/east positions" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [interactive_external_port_positioner_test_graph_property("EXTERNAL_PORTS")],
  )

  let normal_a = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("NORMAL"),
    100.0,
    20.0,
    40.0,
    10.0,
    2.0,
    7.0,
    3.0,
    5.0,
  )
  let normal_b = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("NORMAL"),
    200.0,
    50.0,
    30.0,
    20.0,
    4.0,
    6.0,
    1.0,
    3.0,
  )

  let west_dummy = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("EXTERNAL_PORT"),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  west_dummy.set_property_string(
    layered_options_layering_layer_constraint, "FIRST_SEPARATE",
  )

  let east_dummy = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("EXTERNAL_PORT"),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  east_dummy.set_property_string(
    layered_options_layering_layer_constraint, "LAST_SEPARATE",
  )

  let west_port = interactive_external_port_positioner_test_new_port(
    west_dummy,
    interactive_external_port_positioner_test_port_side("WEST"),
  )
  let east_port = interactive_external_port_positioner_test_new_port(
    east_dummy,
    interactive_external_port_positioner_test_port_side("EAST"),
  )
  let normal_a_port = interactive_external_port_positioner_test_new_port(
    normal_a,
    interactive_external_port_positioner_test_port_side("WEST"),
  )
  let normal_b_port = interactive_external_port_positioner_test_new_port(
    normal_b,
    interactive_external_port_positioner_test_port_side("EAST"),
  )

  ignore(
    interactive_external_port_positioner_test_connect(west_port, normal_a_port),
  )
  ignore(
    interactive_external_port_positioner_test_connect(normal_b_port, east_port),
  )

  let processor = layered_intermediate_processor_factory(
    interactive_external_port_positioner_test_strategy(
      "INTERACTIVE_EXTERNAL_PORT_POSITIONER",
    ),
  ).create()
  processor.process(graph, None)

  inspect(west_dummy.get_position().x, content="85")
  inspect(west_dummy.get_position().y, content="25")
  inspect(east_dummy.get_position().x, content="246")
  inspect(east_dummy.get_position().y, content="60")
}

///|
test "interactive external port positioner places north/south dummies by adjacent x bounds" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [interactive_external_port_positioner_test_graph_property("EXTERNAL_PORTS")],
  )

  let normal_a = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("NORMAL"),
    100.0,
    20.0,
    40.0,
    10.0,
    2.0,
    7.0,
    3.0,
    5.0,
  )
  let normal_b = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("NORMAL"),
    200.0,
    50.0,
    30.0,
    20.0,
    4.0,
    6.0,
    1.0,
    3.0,
  )

  let north_dummy = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("EXTERNAL_PORT"),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  north_dummy.set_property_string(
    internal_properties_in_layer_constraint, "TOP",
  )

  let south_dummy = interactive_external_port_positioner_test_new_node(
    graph,
    interactive_external_port_positioner_test_node_type("EXTERNAL_PORT"),
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  south_dummy.set_property_string(
    internal_properties_in_layer_constraint, "BOTTOM",
  )

  let north_port = interactive_external_port_positioner_test_new_port(
    north_dummy,
    interactive_external_port_positioner_test_port_side("NORTH"),
  )
  let south_port = interactive_external_port_positioner_test_new_port(
    south_dummy,
    interactive_external_port_positioner_test_port_side("SOUTH"),
  )

  let normal_a_in = interactive_external_port_positioner_test_new_port(
    normal_a,
    interactive_external_port_positioner_test_port_side("WEST"),
  )
  let normal_b_in = interactive_external_port_positioner_test_new_port(
    normal_b,
    interactive_external_port_positioner_test_port_side("WEST"),
  )
  let normal_a_out = interactive_external_port_positioner_test_new_port(
    normal_a,
    interactive_external_port_positioner_test_port_side("EAST"),
  )
  let normal_b_out = interactive_external_port_positioner_test_new_port(
    normal_b,
    interactive_external_port_positioner_test_port_side("EAST"),
  )

  ignore(
    interactive_external_port_positioner_test_connect(north_port, normal_a_in),
  )
  ignore(
    interactive_external_port_positioner_test_connect(north_port, normal_b_in),
  )
  ignore(
    interactive_external_port_positioner_test_connect(normal_a_out, south_port),
  )
  ignore(
    interactive_external_port_positioner_test_connect(normal_b_out, south_port),
  )

  let processor = new_interactive_external_port_positioner_layout_processor()
  processor.process(graph, None)

  inspect(north_dummy.get_position().x, content="105")
  inspect(north_dummy.get_position().y, content="8")
  inspect(south_dummy.get_position().x, content="246")
  inspect(south_dummy.get_position().y, content="81")
}
