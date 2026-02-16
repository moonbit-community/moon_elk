///|
fn recursive_graph_layout_engine_test_seeded_next_boolean(
  seed_value : Int64,
) -> Bool {
  let seed = @buffer.new()
  seed.write_int64_le(seed_value)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  let random = @random.Rand::chacha8(seed=seed.to_bytes())
  random.int(limit=2) == 0
}

///|
test "recursive layered context applies graph configurator properties" {
  reset_graph_model_for_test()
  let graph = create_graph()
  node_set_double_property(graph, spacing_edge_edge, 1.0)
  node_set_string_property(graph, direction, "UNDEFINED")
  node_set_double_property(graph, aspect_ratio, 0.5)
  node_set_string_property(graph, edge_routing, "ORTHOGONAL")
  node_set_layout_option_string_by_id(graph, random_seed.get_id(), "5")

  let fixed_node = create_node(Some(graph))
  node_set_dimensions(fixed_node, 10.0, 10.0)
  node_set_string_property(fixed_node, port_constraints, "FIXED_ORDER")

  let undefined_node = create_node(Some(graph))
  node_set_dimensions(undefined_node, 10.0, 10.0)
  node_set_string_property(undefined_node, port_constraints, "UNDEFINED")

  let context = match recursive_layered_create_context(graph) {
    Some(value) => value
    None => fail("expected layered context")
  }

  assert_eq(context.layered_graph.get_property_double(spacing_edge_edge), 2.0)
  assert_eq(context.layered_graph.get_property_string(direction), "DOWN")
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
  assert_eq(fixed_lnode.get_property_string(port_constraints), "FIXED_ORDER")

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
  assert_eq(undefined_lnode.get_property_string(port_constraints), "FREE")
}
