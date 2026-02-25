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
fn graph_configurator_seeded_random_next_boolean(seed_value : Int) -> Bool {
  let multiplier = 25214903917L
  let addend = 11L
  let mask = 281474976710655L
  let mut seed = (Int64::from_int(seed_value) ^ multiplier) & mask
  seed = (seed * multiplier + addend) & mask
  ((seed >> 47) & 1L) == 1L
}

///|
fn graph_configurator_initialize_random(
  lgraph : LGraph,
) -> GreedySwitchMockRandom {
  let seed_value = lgraph.get_property_int(@core.random_seed)
  if seed_value == 0 {
    new_greedy_switch_mock_random_seeded(
      @random.Rand::new().int(limit=@int.max_value),
    )
  } else {
    new_greedy_switch_mock_random_seeded(seed_value)
  }
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
  let edge_spacing = lgraph.get_property_double(@core.spacing_edge_edge)
  if edge_spacing < graph_configurator_min_edge_spacing {
    lgraph.set_property_double(
      @core.spacing_edge_edge, graph_configurator_min_edge_spacing,
    )
  }
}

///|
pub fn graph_configurator_enforce_direction(lgraph : LGraph) -> Unit {
  let direction_value = lgraph.get_property_string(@core.direction)
  if graph_configurator_direction_is_undefined(direction_value) {
    lgraph.set_property_string(
      @core.direction,
      graph_configurator_direction_from_aspect_ratio(
        lgraph.get_property_double(layered_options_aspect_ratio),
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
      lgraph.get_property_string(@core.edge_routing) == "ORTHOGONAL",
    )
  }
}

///|
pub fn graph_configurator_initialize_random_next_boolean(
  lgraph : LGraph,
) -> Unit {
  let random = graph_configurator_initialize_random(lgraph)
  lgraph.set_property_mock_random(internal_properties_random, Some(random))

  let seed_value = lgraph.get_property_int(@core.random_seed)
  let next_boolean = if seed_value == 0 {
    @random.Rand::new().int(limit=2) == 0
  } else {
    graph_configurator_seeded_random_next_boolean(seed_value)
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
  lgraph.set_property_spacings(
    internal_properties_spacings,
    Some(new_layered_spacings(lgraph)),
  )
}

///|
pub fn graph_configurator_prepare_graph_for_layout(lgraph : LGraph) -> Unit {
  graph_configurator_configure_graph_properties(lgraph)
  lgraph.set_property_layout_processor_array(
    internal_properties_processors,
    elk_layered_collect_algorithm_for_graph(lgraph),
  )
}

///|
fn graph_configurator_copy_port_constraints_for_node(node : LNode) -> Unit {
  let original_port_constraints = node.get_property_string(
    @core.port_constraints,
  )
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
