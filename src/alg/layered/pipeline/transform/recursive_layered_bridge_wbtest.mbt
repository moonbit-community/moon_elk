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

  let session = new_layered_transform_session()
  let context = match recursive_layered_create_context(session, graph, None) {
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
      @options.layered_options_node_placement_favor_straight_edges,
    ),
  )
  assert_eq(
    session.layout_state.first_random_boolean(),
    Some(recursive_graph_layout_engine_test_seeded_next_boolean(5)),
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
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, @core.spacing_edge_label, 7.0)

  let child = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(child, 10.0, 10.0)
  @graph.node_set_individual_spacing_option_string_by_id(
    child,
    @core.spacing_edge_label.get_id(),
    "42.5",
  )

  let session = new_layered_transform_session()
  let context = match recursive_layered_create_context(session, graph, None) {
    Some(value) => value
    None => fail("expected layered context")
  }
  let lnode = match context.elk_to_lnode.get(child) {
    Some(value) => value
    None => fail("missing node mapping")
  }

  assert_true(lnode.has_property_double(@core.spacing_edge_label))
  assert_eq(
    @runtime.get_individual_or_inherited(lnode, @core.spacing_edge_label),
    42.5,
  )
}

///|
test "recursive layered context accepts elk.randomSeed alias" {
  let graph = @graph.create_graph()
  @graph.node_set_layout_option_string_by_id(graph, "elk.randomSeed", "42")

  let session = new_layered_transform_session()
  let context = match recursive_layered_create_context(session, graph, None) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_eq(context.layered_graph.get_property_int(@core.random_seed), 42)
}

///|
test "recursive layered context marks east-west fixed ports as north-south ports for DOWN direction" {
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

  let session = new_layered_transform_session()
  let context = match recursive_layered_create_context(session, graph, None) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_true(
    recursive_layered_has_graph_property(context.layered_graph, NorthSouthPorts),
  )
}

///|
test "applying a transformed graph releases pipeline-owned indexes" {
  let graph = @graph.create_graph()
  let session = new_layered_transform_session()
  let layered_graph = match
    recursive_layered_import_graph_for_transform(session, graph) {
    Some(value) => value
    None => fail("expected imported layered graph")
  }

  assert_false(session.contexts.is_empty())
  assert_true(recursive_layered_apply_transformed_graph(session, layered_graph))
  assert_true(session.contexts.is_empty())
  assert_true(session.elk_to_lnode.is_empty())
  assert_true(session.elk_to_lport.is_empty())
  assert_true(session.ledge_to_elk_edge.is_empty())
  assert_true(session.node_assignments.is_empty())
  assert_true(session.edge_assignments.is_empty())
  dispose_layered_graph(layered_graph)
}
