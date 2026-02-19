///|
fn core_debug_grandom_random_graph_test_random(seed : Int64) -> @random.Rand {
  let seed_buffer = @buffer.new()
  seed_buffer.write_int64_le(seed)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  seed_buffer.write_int64_le(0)
  @random.Rand::chacha8(seed=seed_buffer.to_bytes())
}

///|
fn core_debug_grandom_random_graph_count_edges(root : ElkNode) -> Int {
  let mut count = 0
  for node in node_all_descendants_including_self(root) {
    count = count + node_contained_edges(node).length()
  }
  count
}

///|
fn core_debug_grandom_random_graph_count_ports(root : ElkNode) -> Int {
  let mut count = 0
  for node in node_all_descendants_including_self(root) {
    count = count + node_ports(node).length()
  }
  count
}

///|
fn core_debug_grandom_random_graph_shape_to_node(
  shape : ElkConnectableShape,
) -> ElkNode? {
  match shape {
    NodeShape(node) => Some(node)
    PortShape(port) => port_parent(port)
  }
}

///|
fn core_debug_grandom_random_graph_has_cycle_from(
  node : ElkNode,
  states : Map[ElkNode, Int],
) -> Bool {
  match states.get(node) {
    Some(1) => return true
    Some(2) => return false
    _ => ()
  }
  states[node] = 1
  for edge in node_outgoing_edges(node) {
    for target in edge_targets(edge) {
      match core_debug_grandom_random_graph_shape_to_node(target) {
        Some(target_node) =>
          if core_debug_grandom_random_graph_has_cycle_from(target_node, states) {
            return true
          }
        None => ()
      }
    }
  }
  states[node] = 2
  false
}

///|
fn core_debug_grandom_random_graph_is_acyclic(root : ElkNode) -> Bool {
  let states : Map[ElkNode, Int] = {}
  for node in node_all_descendants_including_self(root) {
    if node == root {
      continue
    }
    if core_debug_grandom_random_graph_has_cycle_from(node, states) {
      return false
    }
  }
  true
}

///|
test "grandom random graph generator custom absolute graph" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(101)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_custom(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_absolute(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(6.0),
  )
  options.set_rand_property(
    core_debug_grandom_edges_absolute,
    core_debug_grandom_rand_val_exact(8.0),
  )
  options.set_bool_property(core_debug_grandom_self_loops, true)
  options.set_bool_property(core_debug_grandom_multi_edges, true)
  options.set_bool_property(core_debug_grandom_cycles, true)
  options.set_bool_property(core_debug_grandom_enable_ports, false)
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )

  assert_eq(node_children(graph).length(), 6)
  assert_eq(core_debug_grandom_random_graph_count_edges(graph), 8)
}

///|
test "grandom random graph generator tree graph shape" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(202)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_tree(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(10.0),
  )
  options.set_int_property(core_debug_grandom_max_degree, 3)
  options.set_int_property(core_debug_grandom_max_width, 0)
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )

  assert_eq(node_children(graph).length(), 10)
  assert_eq(core_debug_grandom_random_graph_count_edges(graph), 9)
}

///|
test "grandom random graph generator from configuration samples" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(303)),
  )

  let nodes = new_core_debug_grandom_nodes().set_n_nodes(
    Some(core_debug_grandom_double_quantity_exact(5.0)),
  )
  let edges = new_core_debug_grandom_edges()
    .set_total(true)
    .set_n_edges(Some(core_debug_grandom_double_quantity_exact(4.0)))
  let configuration = new_core_debug_grandom_configuration()
    .set_samples(3)
    .set_form(core_debug_grandom_form_custom())
    .set_nodes(Some(nodes))
    .set_edges(Some(edges))

  let generated = core_debug_grandom_random_graph_generator_generate_from_configuration(
    generator, configuration,
  )

  assert_eq(generated.length(), 3)
  for graph in generated {
    assert_eq(node_children(graph).length(), 5)
    assert_eq(core_debug_grandom_random_graph_count_edges(graph), 4)
  }
}

///|
test "grandom random graph generator distributes fixed-pos ports" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(404)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_custom(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_absolute(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(5.0),
  )
  options.set_rand_property(
    core_debug_grandom_edges_absolute,
    core_debug_grandom_rand_val_exact(9.0),
  )
  options.set_bool_property(core_debug_grandom_enable_ports, true)
  options.set_bool_property(core_debug_grandom_set_node_size, true)
  options.set_bool_property(core_debug_grandom_set_port_size, true)
  options.set_rand_property(
    core_debug_grandom_node_width,
    core_debug_grandom_rand_val_exact(40.0),
  )
  options.set_rand_property(
    core_debug_grandom_node_height,
    core_debug_grandom_rand_val_exact(30.0),
  )
  options.set_rand_property(
    core_debug_grandom_port_width,
    core_debug_grandom_rand_val_exact(6.0),
  )
  options.set_rand_property(
    core_debug_grandom_port_height,
    core_debug_grandom_rand_val_exact(4.0),
  )
  options.set_port_constraints_property(
    core_debug_grandom_port_constraints,
    port_constraints_values()[5],
  )
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )

  let mut seen_pos = false
  let mut seen_side = false
  for node in node_all_descendants_including_self(graph) {
    for port in node_ports(node) {
      if port_x(port) != 0.0 || port_y(port) != 0.0 {
        seen_pos = true
      }
      if port_layout_option_string_value(port, port_side.get_id()) is Some(_) {
        seen_side = true
      }
    }
  }
  assert_true(core_debug_grandom_random_graph_count_ports(graph) > 0)
  assert_true(seen_side)
  assert_true(seen_pos)
}

///|
test "grandom random graph generator biconnected uses minimum bounds" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(505)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_biconnected(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_absolute(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(2.0),
  )
  options.set_rand_property(
    core_debug_grandom_edges_absolute,
    core_debug_grandom_rand_val_exact(1.0),
  )
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )
  assert_eq(node_children(graph).length(), 3)
  assert_true(core_debug_grandom_random_graph_count_edges(graph) >= 3)
}

///|
test "grandom random graph generator triconnected uses minimum bounds" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(606)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_triconnected(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_absolute(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(2.0),
  )
  options.set_rand_property(
    core_debug_grandom_edges_absolute,
    core_debug_grandom_rand_val_exact(1.0),
  )
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )
  assert_true(node_children(graph).length() >= 4)
}

///|
test "grandom random graph generator ante graph is acyclic" {
  reset_graph_model_for_test()
  let generator = new_core_debug_grandom_random_graph_generator(
    Some(core_debug_grandom_random_graph_test_random(707)),
  )
  let options = new_core_debug_grandom_generator_options()
  options.set_graph_type_property(
    core_debug_grandom_graph_type,
    core_debug_grandom_graph_type_acyclic_no_transitive_edges(),
  )
  options.set_edge_determination_property(
    core_debug_grandom_edge_determination,
    core_debug_grandom_edge_determination_absolute(),
  )
  options.set_rand_property(
    core_debug_grandom_number_of_nodes,
    core_debug_grandom_rand_val_exact(7.0),
  )
  options.set_rand_property(
    core_debug_grandom_edges_absolute,
    core_debug_grandom_rand_val_exact(12.0),
  )
  options.set_bool_property(core_debug_grandom_planar, true)
  let graph = core_debug_grandom_random_graph_generator_generate(
    generator, options,
  )
  assert_eq(node_children(graph).length(), 7)
  assert_true(core_debug_grandom_random_graph_is_acyclic(graph))
}
