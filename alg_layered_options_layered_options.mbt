///|
pub let layered_options_layering_layer_constraint : IProperty[String] = new_property(
  "org.eclipse.elk.layered.layering.layerConstraint", "NONE",
)

///|
pub let layered_options_layering_layer_id : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.layering.layerId", 0,
)

///|
pub let layered_options_partitioning_activate : IProperty[Bool] = new_property(
  "org.eclipse.elk.partitioning.activate", false,
)

///|
pub let layered_options_partitioning_partition : IProperty[Int] = new_property(
  "org.eclipse.elk.partitioning.partition", 0,
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
pub let layered_options_crossing_minimization_position_id : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.crossingMinimization.positionId", 0,
)

///|
pub let layered_options_position : IProperty[KVector] = new_property(
  "org.eclipse.elk.position",
  new_kvector(),
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
pub let layered_options_spacing_comment_comment : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.commentComment", 10.0,
)

///|
pub let layered_options_spacing_comment_node : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.commentNode", 10.0,
)

///|
pub let layered_options_spacing_ports_surrounding : IProperty[ElkMargin] = new_property(
  "org.eclipse.elk.spacing.portsSurrounding",
  new_elk_margin(),
)

///|
pub let layered_options_comment_box : IProperty[Bool] = new_property(
  "org.eclipse.elk.commentBox", false,
)

///|
pub let layered_options_hypernode : IProperty[Bool] = new_property(
  "org.eclipse.elk.hypernode", false,
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
pub let layered_options_edge_routing_polyline_sloped_edge_zone_width : IProperty[
  Double,
] = new_property(
  "org.eclipse.elk.layered.edgeRouting.polyline.slopedEdgeZoneWidth", 2.0,
)

///|
pub let layered_options_edge_routing_self_loop_distribution : IProperty[String] = new_property(
  "org.eclipse.elk.layered.edgeRouting.selfLoopDistribution", "NORTH",
)

///|
pub let layered_options_edge_routing_self_loop_ordering : IProperty[String] = new_property(
  "org.eclipse.elk.layered.edgeRouting.selfLoopOrdering", "STACKED",
)

///|
pub let layered_options_feedback_edges : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.feedbackEdges", false,
)

///|
pub let layered_options_port_sorting_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.portSortingStrategy", "INPUT_ORDER",
)

///|
pub let layered_options_port_index : IProperty[Int] = new_property(
  "org.eclipse.elk.port.index", -1,
)

///|
pub let layered_options_unnecessary_bendpoints : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.unnecessaryBendpoints", false,
)

///|
pub let layered_options_junction_points : IProperty[KVectorChain] = new_property(
  "org.eclipse.elk.junctionPoints",
  new_kvector_chain(),
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
pub let layered_options_wrapping_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.wrapping.strategy", "OFF",
)

///|
pub let layered_options_wrapping_additional_edge_spacing : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.wrapping.additionalEdgeSpacing", 10.0,
)

///|
pub let layered_options_wrapping_correction_factor : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.wrapping.correctionFactor", 1.0,
)

///|
pub let layered_options_wrapping_cutting_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.wrapping.cutting.strategy", "MSD",
)

///|
pub let layered_options_wrapping_cutting_cuts : IProperty[String] = new_property(
  "org.eclipse.elk.layered.wrapping.cutting.cuts", "",
)

///|
pub let layered_options_wrapping_cutting_msd_freedom : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.wrapping.cutting.msd.freedom", 1,
)

///|
pub let layered_options_wrapping_validify_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.layered.wrapping.validify.strategy", "GREEDY",
)

///|
pub let layered_options_wrapping_validify_forbidden_indices : IProperty[String] = new_property(
  "org.eclipse.elk.layered.wrapping.validify.forbiddenIndices", "",
)

///|
pub let layered_options_wrapping_multi_edge_improve_cuts : IProperty[Bool] = new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.improveCuts", true,
)

///|
pub let layered_options_wrapping_multi_edge_distance_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.distancePenalty", 2.0,
)

///|
pub let layered_options_wrapping_multi_edge_improve_wrapped_edges : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.improveWrappedEdges", true,
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
