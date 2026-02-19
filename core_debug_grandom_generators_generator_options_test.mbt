///|
fn core_debug_grandom_test_random(seed : Int64) -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(seed)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
test "grandom randval exact and defaults" {
  let random = core_debug_grandom_test_random(1)
  let exact = core_debug_grandom_rand_val_exact(12.0)
  assert_eq(exact.int_val(random), 12)
  assert_eq(exact.default_int(), 12)
  assert_eq(exact.default_val(), 12.0)
}

///|
test "grandom randval min max range" {
  let random = core_debug_grandom_test_random(2)
  let min_max = core_debug_grandom_rand_val_min_max(2.0, 5.0)
  for _ in 0..<64 {
    let value = min_max.val(random)
    assert_true(value >= 2.0)
    assert_true(value <= 5.0)
  }
}

///|
test "grandom generator options set and get" {
  let options = new_core_debug_grandom_generator_options()
  options.set_bool_property(core_debug_grandom_enable_ports, true)
  options.set_int_property(core_debug_grandom_max_width, 77)
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_tree(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_relative(),
  )
  options.set_port_constraints_property(
    core_debug_grandom_port_constraints,
    port_constraints_values()[5],
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(33.0),
  )

  assert_true(options.get_bool_property(core_debug_grandom_enable_ports))
  assert_eq(options.get_int_property(core_debug_grandom_max_width), 77)
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
      core_debug_grandom_edge_determination_relative(),
    ),
  )
  assert_eq(
    port_constraints_to_string(
      options.get_port_constraints_property(core_debug_grandom_port_constraints),
    ),
    "FIXED_POS",
  )
  assert_eq(
    options.get_rand_property(core_debug_grandom_number_of_nodes).default_int(),
    33,
  )
}
