///|
fn hierarchical_node_resizing_test_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn hierarchical_node_resizing_test_graph_properties_contain(
  values : Array[GraphProperties],
  value : GraphProperties,
) -> Bool {
  for property in values {
    if hierarchical_node_resizing_test_graph_property_equals(property, value) {
      return true
    }
  }
  false
}

///|
fn hierarchical_node_resizing_test_graph_property(
  name : String,
) -> GraphProperties {
  for value in graph_properties_values() {
    if graph_properties_to_string(value) == name {
      return value
    }
  }
  abort("unknown graph property")
}

///|
fn hierarchical_node_resizing_test_node_type(name : String) -> NodeType {
  for value in node_type_values() {
    match value {
      NodeType::Normal => if name == "NORMAL" { return value }
      NodeType::LongEdge => if name == "LONG_EDGE" { return value }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return value }
      NodeType::NorthSouthPort => if name == "NORTH_SOUTH_PORT" { return value }
      NodeType::LabelNode => if name == "LABEL_NODE" { return value }
      NodeType::BreakingPoint => if name == "BREAKING_POINT" { return value }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return value }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return value
        }
    }
  }
  abort("unknown node type")
}

///|
fn hierarchical_node_resizing_test_port_side(name : String) -> PortSide {
  for value in port_side_values() {
    if port_side_to_string(value) == name {
      return value
    }
  }
  abort("unknown port side")
}

///|
test "hierarchical node resizing processor flattens layers and applies alignment and minimum size" {
  let graph = new_l_graph()
  graph.set_size_xy(20.0, 10.0)
  graph.set_property_string_array(node_size_constraints, ["MINIMUM_SIZE"])
  graph.set_property_string_array(node_size_options, ["DEFAULT_MINIMUM_SIZE"])
  graph.set_property_string(node_size_minimum, "(50.0, 30.0)")
  graph.set_property_string_array(content_alignment, ["H_CENTER", "V_BOTTOM"])
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [hierarchical_node_resizing_test_graph_property("EXTERNAL_PORTS")],
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(hierarchical_node_resizing_test_node_type("EXTERNAL_PORT"))
  dummy.set_property_port_side(
    internal_properties_ext_port_side,
    hierarchical_node_resizing_test_port_side("EAST"),
  )
  ignore(dummy.get_position().set_xy(5.0, 6.0))
  dummy.set_layer(Some(layer))

  let processor = new_hierarchical_node_resizing_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 0)
  assert_eq(graph.get_layerless_nodes().length(), 1)
  assert_eq(graph.get_layerless_nodes()[0].get_handle(), dummy.get_handle())
  assert_true(
    match dummy.get_layer() {
      None => true
      Some(_) => false
    },
  )

  assert_eq(graph.get_size().x, 50.0)
  assert_eq(graph.get_size().y, 30.0)
  assert_eq(graph.get_offset().x, 15.0)
  assert_eq(graph.get_offset().y, 20.0)
  assert_eq(dummy.get_position().x, 35.0)
}

///|
test "hierarchical node resizing processor transfers nested graph layout to parent node and external ports" {
  let parent_graph = new_l_graph()
  parent_graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [],
  )

  let parent_node = new_l_node(graph=Some(parent_graph))
  ignore(parent_node.get_size().set_xy(10.0, 10.0))

  let graph = new_l_graph()
  graph.set_parent_node(Some(parent_node))
  graph.set_size_xy(100.0, 50.0)
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [hierarchical_node_resizing_test_graph_property("EXTERNAL_PORTS")],
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let dummy = new_l_node(graph=Some(graph))
  dummy.set_type(hierarchical_node_resizing_test_node_type("EXTERNAL_PORT"))
  dummy.set_property_port_side(
    internal_properties_ext_port_side,
    hierarchical_node_resizing_test_port_side("EAST"),
  )
  dummy.set_property_double(layered_options_port_border_offset, 2.0)
  ignore(dummy.get_position().set_xy(20.0, 10.0))
  ignore(dummy.get_size().set_xy(4.0, 4.0))

  let origin_port = new_l_port()
  ignore(origin_port.get_size().set_xy(6.0, 8.0))
  dummy.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )

  dummy.set_layer(Some(layer))

  let processor = new_hierarchical_node_resizing_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(parent_node.get_size().x, 100.0)
  assert_eq(parent_node.get_size().y, 50.0)
  assert_eq(parent_node.get_property_string(port_constraints), "FIXED_POS")

  let parent_properties = parent_graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  assert_true(
    hierarchical_node_resizing_test_graph_properties_contain(
      parent_properties,
      hierarchical_node_resizing_test_graph_property("NON_FREE_PORTS"),
    ),
  )

  assert_eq(port_side_to_string(origin_port.get_side()), "EAST")
  assert_eq(origin_port.get_position().x, 102.0)
  assert_eq(origin_port.get_position().y, 8.0)
  assert_eq(dummy.get_position().x, 102.0)
}
