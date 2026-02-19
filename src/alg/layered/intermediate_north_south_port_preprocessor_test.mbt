///|
fn north_south_port_preprocessor_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn north_south_port_preprocessor_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn north_south_port_preprocessor_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn north_south_port_preprocessor_test_require_dummy(
  node : LNode?,
  message : String,
) -> LNode {
  match node {
    Some(value) => value
    None => abort(message)
  }
}

///|
fn north_south_port_preprocessor_test_node_type(name : String) -> NodeType {
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
fn north_south_port_preprocessor_test_port_side(
  name : String,
) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn north_south_port_preprocessor_test_contains_node(
  nodes : Array[LNode],
  node : LNode,
) -> Bool {
  for candidate in nodes {
    if candidate.get_handle() == node.get_handle() {
      return true
    }
  }
  false
}

///|
test "north south port preprocessor reports expected task name" {
  let processor = new_north_south_port_preprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Odd port side processing")
}

///|
test "north south port preprocessor isolates north and south ports for fixed-side nodes" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_consider_model_order_strategy, "NONE",
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let source = new_l_node(graph=Some(graph))
  source.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  source.set_layer(Some(layer))
  let source_port = new_l_port()
  source_port.set_side(north_south_port_preprocessor_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let node = new_l_node(graph=Some(graph))
  node.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  node.set_layer(Some(layer))
  node.set_property_string(@core.port_constraints, "FIXED_SIDE")

  let north_port = new_l_port()
  north_port.set_side(north_south_port_preprocessor_test_port_side("NORTH"))
  north_port.set_node(Some(node))

  let south_port = new_l_port()
  south_port.set_side(north_south_port_preprocessor_test_port_side("SOUTH"))
  south_port.set_node(Some(node))

  let target = new_l_node(graph=Some(graph))
  target.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  target.set_layer(Some(layer))
  let target_port = new_l_port()
  target_port.set_side(north_south_port_preprocessor_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let in_edge = new_l_edge()
  in_edge.set_source(Some(source_port))
  in_edge.set_target(Some(north_port))

  let out_edge = new_l_edge()
  out_edge.set_source(Some(south_port))
  out_edge.set_target(Some(target_port))

  let processor = new_north_south_port_preprocessor_layout_processor()
  processor.process(graph, None)

  assert_eq(north_port.get_connected_edges().length(), 0)
  assert_eq(south_port.get_connected_edges().length(), 0)

  let mut north_dummy : LNode? = None
  let mut south_dummy : LNode? = None
  for candidate in layer.get_nodes() {
    match candidate.get_type() {
      NodeType::NorthSouthPort =>
        if !candidate.get_incoming_edges().is_empty() &&
          candidate.get_outgoing_edges().is_empty() {
          north_dummy = Some(candidate)
        } else if !candidate.get_outgoing_edges().is_empty() &&
          candidate.get_incoming_edges().is_empty() {
          south_dummy = Some(candidate)
        }
      _ => ()
    }
  }

  let north_dummy_node = north_south_port_preprocessor_test_require_dummy(
    north_dummy, "missing north dummy",
  )
  let south_dummy_node = north_south_port_preprocessor_test_require_dummy(
    south_dummy, "missing south dummy",
  )

  assert_eq(
    north_south_port_preprocessor_test_require_target(in_edge).get_handle(),
    north_dummy_node.get_ports()[0].get_handle(),
  )
  assert_eq(
    north_south_port_preprocessor_test_require_source(out_edge).get_handle(),
    south_dummy_node.get_ports()[0].get_handle(),
  )

  assert_eq(
    north_dummy_node.get_property_string(@core.port_constraints),
    "FIXED_POS",
  )
  assert_eq(
    south_dummy_node.get_property_string(@core.port_constraints),
    "FIXED_POS",
  )

  assert_true(
    north_dummy_node.has_property_l_node(
      internal_properties_in_layer_layout_unit,
    ),
  )
  assert_true(
    south_dummy_node.has_property_l_node(
      internal_properties_in_layer_layout_unit,
    ),
  )

  let north_unit = north_dummy_node.get_property_l_node(
    internal_properties_in_layer_layout_unit,
  )
  let south_unit = south_dummy_node.get_property_l_node(
    internal_properties_in_layer_layout_unit,
  )
  assert_eq(
    north_south_port_preprocessor_test_require_dummy(
      north_unit, "missing north layout unit",
    ).get_handle(),
    node.get_handle(),
  )
  assert_eq(
    north_south_port_preprocessor_test_require_dummy(
      south_unit, "missing south layout unit",
    ).get_handle(),
    node.get_handle(),
  )

  assert_true(north_port.has_property_l_node(internal_properties_port_dummy))
  assert_true(south_port.has_property_l_node(internal_properties_port_dummy))
  assert_eq(
    north_south_port_preprocessor_test_require_dummy(
      north_port.get_property_l_node(internal_properties_port_dummy),
      "north port missing dummy",
    ).get_handle(),
    north_dummy_node.get_handle(),
  )
  assert_eq(
    north_south_port_preprocessor_test_require_dummy(
      south_port.get_property_l_node(internal_properties_port_dummy),
      "south port missing dummy",
    ).get_handle(),
    south_dummy_node.get_handle(),
  )

  let north_successors = north_dummy_node.get_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
  )
  assert_eq(north_successors.length(), 1)
  assert_eq(north_successors[0].get_handle(), node.get_handle())

  let node_successors = node.get_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
  )
  assert_eq(node_successors.length(), 1)
  assert_eq(node_successors[0].get_handle(), south_dummy_node.get_handle())

  let associates = node.get_property_l_node_array(
    internal_properties_barycenter_associates,
  )
  assert_eq(associates.length(), 2)
  assert_true(
    north_south_port_preprocessor_test_contains_node(
      associates, north_dummy_node,
    ),
  )
  assert_true(
    north_south_port_preprocessor_test_contains_node(
      associates, south_dummy_node,
    ),
  )
}

///|
test "north south port preprocessor skips successor constraints when port may switch sides" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_consider_model_order_strategy, "NONE",
  )

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let source = new_l_node(graph=Some(graph))
  source.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  source.set_layer(Some(layer))
  let source_port = new_l_port()
  source_port.set_side(north_south_port_preprocessor_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let node = new_l_node(graph=Some(graph))
  node.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  node.set_layer(Some(layer))
  node.set_property_string(@core.port_constraints, "FIXED_SIDE")

  let north_port = new_l_port()
  north_port.set_side(north_south_port_preprocessor_test_port_side("NORTH"))
  north_port.set_property_bool(
    layered_options_allow_non_flow_ports_to_switch_sides, true,
  )
  north_port.set_node(Some(node))

  let south_port = new_l_port()
  south_port.set_side(north_south_port_preprocessor_test_port_side("SOUTH"))
  south_port.set_property_bool(
    layered_options_allow_non_flow_ports_to_switch_sides, true,
  )
  south_port.set_node(Some(node))

  let target = new_l_node(graph=Some(graph))
  target.set_type(north_south_port_preprocessor_test_node_type("NORMAL"))
  target.set_layer(Some(layer))
  let target_port = new_l_port()
  target_port.set_side(north_south_port_preprocessor_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let in_edge = new_l_edge()
  in_edge.set_source(Some(source_port))
  in_edge.set_target(Some(north_port))

  let out_edge = new_l_edge()
  out_edge.set_source(Some(south_port))
  out_edge.set_target(Some(target_port))

  let processor = new_north_south_port_preprocessor_layout_processor()
  processor.process(graph, None)

  let mut north_dummy : LNode? = None
  let mut south_dummy : LNode? = None
  for candidate in layer.get_nodes() {
    match candidate.get_type() {
      NodeType::NorthSouthPort =>
        if !candidate.get_incoming_edges().is_empty() &&
          candidate.get_outgoing_edges().is_empty() {
          north_dummy = Some(candidate)
        } else if !candidate.get_outgoing_edges().is_empty() &&
          candidate.get_incoming_edges().is_empty() {
          south_dummy = Some(candidate)
        }
      _ => ()
    }
  }
  let north_dummy_node = north_south_port_preprocessor_test_require_dummy(
    north_dummy, "missing north dummy",
  )
  let south_dummy_node = north_south_port_preprocessor_test_require_dummy(
    south_dummy, "missing south dummy",
  )
  ignore(south_dummy_node)

  assert_eq(
    north_dummy_node
    .get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    )
    .length(),
    0,
  )
  assert_eq(
    node
    .get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    )
    .length(),
    0,
  )
}

///|
test "north south port preprocessor strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    north_south_port_preprocessor_test_strategy("NORTH_SOUTH_PORT_PREPROCESSOR"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Odd port side processing")
}
