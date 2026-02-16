///|
fn graph_configurator_is_hierarchical_layout(lgraph : LGraph) -> Bool {
  lgraph.get_property_string(layered_options_hierarchy_handling) ==
  "INCLUDE_CHILDREN"
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
