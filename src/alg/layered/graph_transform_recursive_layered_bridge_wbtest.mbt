///|
fn recursive_graph_layout_engine_test_seeded_next_boolean(
  seed_value : Int64,
) -> Bool {
  let multiplier = 25214903917L
  let addend = 11L
  let mask = 281474976710655L
  let mut seed = (seed_value ^ multiplier) & mask
  seed = (seed * multiplier + addend) & mask
  ((seed >> 47) & 1L) == 1L
}

///|
test "recursive layered context applies graph configurator properties" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, @core.spacing_edge_edge, 1.0)
  @graph.node_set_string_property(graph, @core.direction, "UNDEFINED")
  @graph.node_set_double_property(graph, @core.aspect_ratio, 0.5)
  @graph.node_set_string_property(graph, @core.edge_routing, "ORTHOGONAL")
  @graph.node_set_layout_option_string_by_id(
    graph,
    @core.random_seed.get_id(),
    "5",
  )

  let fixed_node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(fixed_node, 10.0, 10.0)
  @graph.node_set_string_property(
    fixed_node, @core.port_constraints, "FIXED_ORDER",
  )

  let undefined_node = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(undefined_node, 10.0, 10.0)
  @graph.node_set_string_property(
    undefined_node, @core.port_constraints, "UNDEFINED",
  )

  let context = match recursive_layered_create_context(graph) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_eq(
    context.layered_graph.get_property_double(@core.spacing_edge_edge),
    2.0,
  )
  assert_eq(context.layered_graph.get_property_string(@core.direction), "DOWN")
  assert_true(
    context.layered_graph.get_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ),
  )
  assert_eq(
    context.layered_graph.get_property_bool(
      internal_properties_random_next_boolean,
    ),
    recursive_graph_layout_engine_test_seeded_next_boolean(5),
  )

  let fixed_lnode = match context.elk_to_lnode.get(fixed_node) {
    Some(value) => value
    None => fail("missing fixed-node mapping")
  }
  assert_eq(
    fixed_lnode.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "FIXED_ORDER",
  )
  assert_eq(
    fixed_lnode.get_property_string(@core.port_constraints),
    "FIXED_ORDER",
  )

  let undefined_lnode = match context.elk_to_lnode.get(undefined_node) {
    Some(value) => value
    None => fail("missing undefined-node mapping")
  }
  assert_eq(
    undefined_lnode.get_property_string(
      internal_properties_original_port_constraints,
    ),
    "UNDEFINED",
  )
  assert_eq(undefined_lnode.get_property_string(@core.port_constraints), "FREE")
}

///|
test "recursive layered context copies individual spacing overrides to LNode" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, @core.spacing_edge_label, 7.0)

  let child = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(child, 10.0, 10.0)
  @graph.node_set_individual_spacing_option_string_by_id(
    child,
    @core.spacing_edge_label.get_id(),
    "42.5",
  )

  let context = match recursive_layered_create_context(graph) {
    Some(value) => value
    None => fail("expected layered context")
  }
  let lnode = match context.elk_to_lnode.get(child) {
    Some(value) => value
    None => fail("missing node mapping")
  }

  assert_true(lnode.has_property_double(@core.spacing_edge_label))
  assert_eq(get_individual_or_inherited(lnode, @core.spacing_edge_label), 42.5)
}

///|
test "recursive layered context accepts elk.randomSeed alias" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_layout_option_string_by_id(graph, "elk.randomSeed", "42")

  let context = match recursive_layered_create_context(graph) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_eq(context.layered_graph.get_property_int(@core.random_seed), 42)
}

///|
test "recursive layered context marks east-west fixed ports as north-south ports for DOWN direction" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_string_property(graph, @core.direction, "DOWN")

  let child = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(child, 120.0, 80.0)
  @graph.node_set_layout_option_string_by_id(
    child,
    @core.port_constraints.get_id(),
    "FIXED_POS",
  )

  let east = @graph.create_port(Some(child))
  @graph.port_set_layout_option_string_by_id(
    east,
    @core.port_side.get_id(),
    "EAST",
  )
  @graph.port_set_location(east, 0.0, 20.0)

  let west = @graph.create_port(Some(child))
  @graph.port_set_layout_option_string_by_id(
    west,
    @core.port_side.get_id(),
    "WEST",
  )
  @graph.port_set_location(west, 0.0, 60.0)

  let context = match recursive_layered_create_context(graph) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_true(
    recursive_layered_has_graph_property(
      context.layered_graph,
      GraphProperties::NorthSouthPorts,
    ),
  )
}
