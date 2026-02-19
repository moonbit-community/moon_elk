///|
fn core_debug_grandom_parser_test_random(seed : Int64) -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(seed)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
test "grandom configuration parser maps core options" {
  let port_size = new_core_debug_grandom_size()
    .set_height(Some(core_debug_grandom_double_quantity_exact(8.0)))
    .set_width(Some(core_debug_grandom_double_quantity_exact(7.0)))

  let flow = new_core_debug_grandom_flow(
    core_debug_grandom_flow_incoming(),
    core_debug_grandom_side_east(),
    amount=Some(core_debug_grandom_double_quantity_exact(11.0)),
  )

  let ports = new_core_debug_grandom_ports()
    .set_labels(true)
    .set_re_use(Some(core_debug_grandom_double_quantity_exact(0.5)))
    .set_size(Some(port_size))
    .set_constraint(Some(core_debug_grandom_constraint_position()))
    .set_flow([flow])

  let node_size = new_core_debug_grandom_size()
    .set_height(Some(core_debug_grandom_double_quantity_exact(30.0)))
    .set_width(Some(core_debug_grandom_double_quantity_exact(40.0)))

  let nodes = new_core_debug_grandom_nodes()
    .set_n_nodes(Some(core_debug_grandom_double_quantity_exact(12.0)))
    .set_ports(Some(ports))
    .set_labels(true)
    .set_size(Some(node_size))
    .set_remove_isolated(true)

  let edges = new_core_debug_grandom_edges()
    .set_total(true)
    .set_n_edges(Some(core_debug_grandom_double_quantity_exact(20.0)))
    .set_labels(true)
    .set_self_loops(true)

  let hierarchy = new_core_debug_grandom_hierarchy()
    .set_levels(Some(core_debug_grandom_double_quantity_exact(3.0)))
    .set_edges(Some(core_debug_grandom_double_quantity_exact(2.0)))
    .set_num_hierarch_nodes(Some(core_debug_grandom_double_quantity_exact(5.0)))
    .set_cross_hierarch_rel(Some(core_debug_grandom_double_quantity_exact(0.1)))

  let configuration = new_core_debug_grandom_configuration()
    .set_form(core_debug_grandom_form_trees())
    .set_tree_limits(Some(9), Some(4))
    .set_nodes(Some(nodes))
    .set_edges(Some(edges))
    .set_fraction(Some(core_debug_grandom_double_quantity_exact(0.25)))
    .set_hierarchy(Some(hierarchy))

  let options = core_debug_grandom_configuration_parser_parse(
    configuration,
    core_debug_grandom_parser_test_random(5),
  )

  assert_true(
    core_debug_grandom_graph_type_equals(
      options.get_graph_type_property(core_debug_grandom_graph_type),
      core_debug_grandom_graph_type_tree(),
    ),
  )
  assert_true(
    core_debug_grandom_edge_determination_equals(
      options.get_edge_determination_property(
        core_debug_grandom_edge_determination,
      ),
      core_debug_grandom_edge_determination_absolute(),
    ),
  )
  assert_eq(options.get_int_property(core_debug_grandom_max_width), 9)
  assert_eq(options.get_int_property(core_debug_grandom_max_degree), 4)
  assert_eq(
    options.get_rand_property(core_debug_grandom_number_of_nodes).default_int(),
    12,
  )
  assert_eq(
    options.get_rand_property(core_debug_grandom_edges_absolute).default_int(),
    20,
  )
  assert_true(options.get_bool_property(core_debug_grandom_create_node_labels))
  assert_true(options.get_bool_property(core_debug_grandom_create_port_labels))
  assert_eq(
    @core.port_constraints_to_string(
      options.get_port_constraints_property(core_debug_grandom_port_constraints),
    ),
    "FIXED_POS",
  )
  assert_eq(options.get_int_property(core_debug_grandom_incoming_east_side), 11)
  assert_true(!options.get_bool_property(core_debug_grandom_isolated_nodes))
  assert_eq(
    options
    .get_optional_rand_property(core_debug_grandom_exact_relative_hier)
    .unwrap_or(core_debug_grandom_rand_val_exact(-1.0))
    .default_val(),
    0.1,
  )
}
