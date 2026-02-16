///|
fn graph_configurator_is_hierarchical_layout(lgraph : LGraph) -> Bool {
  lgraph.get_property_string(layered_options_hierarchy_handling) ==
  "INCLUDE_CHILDREN"
}

///|
let graph_configurator_min_edge_spacing = 2.0

///|
fn graph_configurator_direction_from_aspect_ratio(
  aspect_ratio_value : Double,
) -> String {
  if aspect_ratio_value >= 1.0 {
    "RIGHT"
  } else {
    "DOWN"
  }
}

///|
fn graph_configurator_direction_is_undefined(direction_value : String) -> Bool {
  direction_value == "UNDEFINED" || direction_value.is_empty()
}

///|
fn graph_configurator_seeded_random_next_boolean(seed_value : Int64) -> Bool {
  let seed = @buffer.new()
  seed.write_int64_le(seed_value)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  let random = @random.Rand::chacha8(seed=seed.to_bytes())
  random.int(limit=2) == 0
}

///|
pub fn graph_configurator_activate_greedy_switch_for(lgraph : LGraph) -> Bool {
  if graph_configurator_is_hierarchical_layout(lgraph) {
    let is_root_graph = match lgraph.get_parent_node() {
      None => true
      _ => false
    }
    return is_root_graph &&
      lgraph.get_property_string(
        layered_options_crossing_minimization_greedy_switch_hierarchical_type,
      ) !=
      "OFF"
  }

  let greedy_switch_type = lgraph.get_property_string(
    layered_options_crossing_minimization_greedy_switch_type,
  )
  let crossing_min_strategy = lgraph.get_property_string(
    layered_options_crossing_minimization_strategy,
  )
  let interactive_cross_min = lgraph.get_property_bool(
      layered_options_crossing_minimization_semi_interactive,
    ) ||
    crossing_min_strategy ==
    crossing_minimization_strategy_to_string(CmsInteractive)
  let activation_threshold = lgraph.get_property_int(
    layered_options_crossing_minimization_greedy_switch_activation_threshold,
  )
  let graph_size = lgraph.get_layerless_nodes().length()

  !interactive_cross_min &&
  greedy_switch_type != "OFF" &&
  (activation_threshold == 0 || activation_threshold > graph_size)
}

///|
pub fn graph_configurator_enforce_min_edge_spacing(lgraph : LGraph) -> Unit {
  let edge_spacing = lgraph.get_property_double(spacing_edge_edge)
  if edge_spacing < graph_configurator_min_edge_spacing {
    lgraph.set_property_double(
      spacing_edge_edge, graph_configurator_min_edge_spacing,
    )
  }
}

///|
pub fn graph_configurator_enforce_direction(lgraph : LGraph) -> Unit {
  let direction_value = lgraph.get_property_string(direction)
  if graph_configurator_direction_is_undefined(direction_value) {
    lgraph.set_property_string(
      direction,
      graph_configurator_direction_from_aspect_ratio(
        lgraph.get_property_double(aspect_ratio),
      ),
    )
  }
}

///|
pub fn graph_configurator_default_favor_straight_edges(lgraph : LGraph) -> Unit {
  if !lgraph.has_property_bool(
      layered_options_node_placement_favor_straight_edges,
    ) {
    lgraph.set_property_bool(
      layered_options_node_placement_favor_straight_edges,
      lgraph.get_property_string(edge_routing) == "ORTHOGONAL",
    )
  }
}

///|
pub fn graph_configurator_initialize_random_next_boolean(
  lgraph : LGraph,
) -> Unit {
  let seed_value = lgraph.get_property_int(random_seed)
  let next_boolean = if seed_value == 0 {
    @random.Rand::new().int(limit=2) == 0
  } else {
    graph_configurator_seeded_random_next_boolean(seed_value.to_int64())
  }
  lgraph.set_property_bool(
    internal_properties_random_next_boolean, next_boolean,
  )
}

///|
pub fn graph_configurator_configure_graph_properties(lgraph : LGraph) -> Unit {
  graph_configurator_enforce_min_edge_spacing(lgraph)
  graph_configurator_enforce_direction(lgraph)
  graph_configurator_initialize_random_next_boolean(lgraph)
  graph_configurator_default_favor_straight_edges(lgraph)
  graph_configurator_copy_port_constraints(lgraph)
}

///|
fn graph_configurator_copy_port_constraints_for_node(node : LNode) -> Unit {
  let original_port_constraints = node.get_property_string(port_constraints)
  node.set_property_string(
    internal_properties_original_port_constraints, original_port_constraints,
  )

  match node.get_nested_graph() {
    Some(nested_graph) => graph_configurator_copy_port_constraints(nested_graph)
    None => ()
  }
}

///|
pub fn graph_configurator_copy_port_constraints(lgraph : LGraph) -> Unit {
  for node in lgraph.get_layerless_nodes() {
    graph_configurator_copy_port_constraints_for_node(node)
  }
  for layer in lgraph.get_layers() {
    for node in layer.get_nodes() {
      graph_configurator_copy_port_constraints_for_node(node)
    }
  }
}
