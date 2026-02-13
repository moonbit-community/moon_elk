///|
pub let layered_options_layering_layer_constraint : IProperty[String] = new_property(
  "org.eclipse.elk.layered.layering.layerConstraint", "NONE",
)

///|
pub let layered_options_crossing_minimization_force_node_model_order : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.layered.crossingMinimization.forceNodeModelOrder", false,
)

///|
pub let layered_options_crossing_minimization_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.crossingMinimization.strategy", "LAYER_SWEEP",
)

///|
pub let layered_options_crossing_minimization_greedy_switch_type : IProperty[
  String,
] = new_property(
  "org.eclipse.elk.layered.crossingMinimization.greedySwitch.type", "TWO_SIDED",
)

///|
pub let layered_options_consider_model_order_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.strategy", "NONE",
)

///|
pub let layered_options_consider_model_order_group_model_order_cycle_breaking_id : IProperty[
  Int,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cycleBreakingId", 0,
)

///|
pub let layered_options_consider_model_order_group_model_order_crossing_minimization_id : IProperty[
  Int,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.crossingMinimizationId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_component_group_id : IProperty[
  Int,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.componentGroupId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_group_order_strategy : IProperty[
  String,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbGroupOrderStrategy",
  "ONLY_WITHIN_GROUP",
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_preferred_source_id : IProperty[
  Int,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbPreferredSourceId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_preferred_target_id : IProperty[
  Int,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbPreferredTargetId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cm_group_order_strategy : IProperty[
  String,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cmGroupOrderStrategy",
  "ONLY_WITHIN_GROUP",
)

///|
pub let layered_options_consider_model_order_group_model_order_cm_enforced_group_orders : IProperty[
  String,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cmEnforcedGroupOrders",
  "[1, 2, 6, 7, 10, 11]",
)

///|
pub let layered_options_thoroughness : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.thoroughness", 7,
)

///|
pub let layered_options_spacing_base_value : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.spacing.baseValue",
  spacing_node_node.get_default(),
)

///|
pub let layered_options_spacing_edge_node_between_layers : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.spacing.edgeNodeBetweenLayers", 10.0,
)

///|
pub let layered_options_spacing_edge_edge_between_layers : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.spacing.edgeEdgeBetweenLayers", 10.0,
)

///|
pub let layered_options_spacing_node_node_between_layers : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.spacing.nodeNodeBetweenLayers", 20.0,
)

///|
pub let layered_options_edge_routing_splines_mode : IProperty[SplineRoutingMode] = new_property(
  "org.eclipse.elk.layered.edgeRouting.splines.mode",
  SplineRoutingMode::Sloppy,
)

///|
pub let layered_options_edge_routing_splines_sloppy_layer_spacing_factor : IProperty[
  Double,
] = new_property(
  "org.eclipse.elk.layered.edgeRouting.splines.sloppy.layerSpacingFactor", 0.2,
)

///|
pub let layered_options_hierarchy_handling : IProperty[String] = new_property(
  "org.eclipse.elk.hierarchyHandling", "INHERIT",
)

///|
pub let layered_options_consider_model_order_crossing_counter_node_influence : IProperty[
  Double,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.crossingCounterNodeInfluence", 0.0,
)

///|
pub let layered_options_consider_model_order_crossing_counter_port_influence : IProperty[
  Double,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.crossingCounterPortInfluence", 0.0,
)

///|
pub let layered_options_consider_model_order_port_model_order : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.portModelOrder", false,
)

///|
pub let layered_options_consider_model_order_long_edge_strategy : IProperty[
  String,
] = new_property(
  "org.eclipse.elk.layered.considerModelOrder.longEdgeStrategy", "DUMMY_NODE_OVER",
)

///|
pub fn layered_options_parse_int_list(value : String) -> Array[Int] {
  let normalized = value
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
    .trim()
    .to_string()
  if normalized.is_empty() {
    return []
  }

  let result = []
  for token_view in normalized.split(",") {
    let token = token_view.to_string().trim().to_string()
    if token.is_empty() {
      continue
    }
    let parsed : Result[Int, @strconv.StrConvError] = try? @strconv.parse_int(
      token,
    )
    match parsed {
      Ok(v) => result.push(v)
      Err(_) => ()
    }
  }
  result
}

///|
pub fn layered_options_int_list_contains(
  values : Array[Int],
  value : Int,
) -> Bool {
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}
