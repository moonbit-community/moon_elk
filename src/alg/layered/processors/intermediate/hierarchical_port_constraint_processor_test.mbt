///|
fn hierarchical_port_constraint_test_strategy(
  name : String,
) -> @runtime.IntermediateProcessorStrategy {
  for strategy in @runtime.intermediate_processor_strategy_values() {
    if @runtime.intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn hierarchical_port_constraint_test_node_type(
  name : String,
) -> @runtime.NodeType {
  for node_type in @runtime.node_type_values() {
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
fn hierarchical_port_constraint_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn hierarchical_port_constraint_test_require_source(
  edge : @runtime.LEdge,
) -> @runtime.LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn hierarchical_port_constraint_test_require_target(
  edge : @runtime.LEdge,
) -> @runtime.LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
test "hierarchical port constraint processor reports expected task name" {
  let processor = new_hierarchical_port_constraint_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(@runtime.new_l_graph(), Some(monitor))
  inspect(
    monitor.get_task_name(),
    content="Hierarchical port constraint processing",
  )
}

///|
test "hierarchical port constraint processor adds west east successor constraints by ratio" {
  let graph = @runtime.new_l_graph()
  graph.set_property_string(@core.port_constraints, "FIXED_ORDER")

  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let dummy_high = @runtime.new_l_node(graph=Some(graph))
  dummy_high.set_type(
    hierarchical_port_constraint_test_node_type("EXTERNAL_PORT"),
  )
  dummy_high.set_property_port_side(
    @runtime.internal_properties_ext_port_side,
    hierarchical_port_constraint_test_port_side("WEST"),
  )
  dummy_high.set_property_double(
    @runtime.internal_properties_port_ratio_or_position, 0.8,
  )
  dummy_high.set_layer(Some(layer))

  let dummy_low = @runtime.new_l_node(graph=Some(graph))
  dummy_low.set_type(
    hierarchical_port_constraint_test_node_type("EXTERNAL_PORT"),
  )
  dummy_low.set_property_port_side(
    @runtime.internal_properties_ext_port_side,
    hierarchical_port_constraint_test_port_side("WEST"),
  )
  dummy_low.set_property_double(
    @runtime.internal_properties_port_ratio_or_position, 0.2,
  )
  dummy_low.set_layer(Some(layer))

  let normal = @runtime.new_l_node(graph=Some(graph))
  normal.set_type(hierarchical_port_constraint_test_node_type("NORMAL"))
  normal.set_layer(Some(layer))

  let processor = new_hierarchical_port_constraint_processor_layout_processor()
  processor.process(graph, None)

  let successors = dummy_low.get_property_l_node_array(
    @runtime.internal_properties_in_layer_successor_constraints,
  )
  assert_eq(successors.length(), 2)
  assert_eq(successors[0].get_handle(), dummy_high.get_handle())
  assert_eq(successors[1].get_handle(), dummy_high.get_handle())
}

///|
test "hierarchical port constraint processor replaces north south dummies" {
  let graph = @runtime.new_l_graph()
  graph.set_property_string(@core.port_constraints, "FIXED_SIDE")

  let layer = @runtime.new_layer(graph)
  graph.get_layers().push(layer)

  let normal = @runtime.new_l_node(graph=Some(graph))
  normal.set_type(hierarchical_port_constraint_test_node_type("NORMAL"))
  normal.set_layer(Some(layer))

  let normal_in = @runtime.new_l_port()
  normal_in.set_side(hierarchical_port_constraint_test_port_side("WEST"))
  normal_in.set_node(Some(normal))
  let normal_out = @runtime.new_l_port()
  normal_out.set_side(hierarchical_port_constraint_test_port_side("EAST"))
  normal_out.set_node(Some(normal))

  let north_dummy = @runtime.new_l_node(graph=Some(graph))
  north_dummy.set_type(
    hierarchical_port_constraint_test_node_type("EXTERNAL_PORT"),
  )
  north_dummy.set_property_port_side(
    @runtime.internal_properties_ext_port_side,
    hierarchical_port_constraint_test_port_side("NORTH"),
  )
  north_dummy.set_layer(Some(layer))

  let north_port = @runtime.new_l_port()
  north_port.set_side(hierarchical_port_constraint_test_port_side("EAST"))
  north_port.set_node(Some(north_dummy))

  let south_dummy = @runtime.new_l_node(graph=Some(graph))
  south_dummy.set_type(
    hierarchical_port_constraint_test_node_type("EXTERNAL_PORT"),
  )
  south_dummy.set_property_port_side(
    @runtime.internal_properties_ext_port_side,
    hierarchical_port_constraint_test_port_side("SOUTH"),
  )
  south_dummy.set_layer(Some(layer))

  let south_port = @runtime.new_l_port()
  south_port.set_side(hierarchical_port_constraint_test_port_side("WEST"))
  south_port.set_node(Some(south_dummy))

  let in_edge = @runtime.new_l_edge()
  in_edge.set_source(Some(north_port))
  in_edge.set_target(Some(normal_in))

  let out_edge = @runtime.new_l_edge()
  out_edge.set_source(Some(normal_out))
  out_edge.set_target(Some(south_port))

  let processor = new_hierarchical_port_constraint_processor_layout_processor()
  processor.process(graph, None)

  assert_eq(graph.get_layers().length(), 3)
  let first_layer = graph.get_layers()[0]
  let middle_layer = graph.get_layers()[1]
  let last_layer = graph.get_layers()[2]
  assert_eq(first_layer.get_nodes().length(), 1)
  assert_eq(last_layer.get_nodes().length(), 1)

  let prev_dummy = first_layer.get_nodes()[0]
  let next_dummy = last_layer.get_nodes()[0]
  assert_true(
    prev_dummy.has_property_l_node(
      @runtime.internal_properties_ext_port_replaced_dummy,
    ),
  )
  assert_true(
    next_dummy.has_property_l_node(
      @runtime.internal_properties_ext_port_replaced_dummy,
    ),
  )

  assert_eq(
    hierarchical_port_constraint_test_require_source(in_edge).get_handle(),
    prev_dummy.get_ports()[1].get_handle(),
  )
  assert_eq(
    hierarchical_port_constraint_test_require_target(out_edge).get_handle(),
    next_dummy.get_ports()[0].get_handle(),
  )

  for node in middle_layer.get_nodes() {
    assert_true(node.get_handle() != north_dummy.get_handle())
    assert_true(node.get_handle() != south_dummy.get_handle())
  }

  let replaced = graph.get_property_l_node_array(
    @runtime.internal_properties_ext_port_replaced_dummies,
  )
  assert_eq(replaced.length(), 2)
}

///|
test "hierarchical port constraint processor strategy creates concrete processor" {
  let factory = layered_intermediate_processor_factory(
    @runtime.new_l_graph(),
    hierarchical_port_constraint_test_strategy(
      "HIERARCHICAL_PORT_CONSTRAINT_PROCESSOR",
    ),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.run(Some(monitor))
  inspect(
    monitor.get_task_name(),
    content="Hierarchical port constraint processing",
  )
}
