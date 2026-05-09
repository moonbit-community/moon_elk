///|
pub let layered_algorithm_id = "org.eclipse.elk.layered"

///|
pub let layered_options_aspect_ratio : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.aspectRatio", 1.6,
)

///|
pub let layered_options_layering_layer_constraint : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.layering.layerConstraint", "NONE",
)

///|
pub let layered_options_layering_layer_choice_constraint : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.layering.layerChoiceConstraint", -1,
)

///|
pub let layered_options_layering_layer_id : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.layering.layerId", 0,
)

///|
pub let layered_options_partitioning_activate : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.partitioning.activate", false,
)

///|
pub let layered_options_partitioning_partition : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.partitioning.partition", 0,
)

///|
pub let layered_options_crossing_minimization_force_node_model_order : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.forceNodeModelOrder", false,
)

///|
pub let layered_options_crossing_minimization_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.strategy", "LAYER_SWEEP",
)

///|
pub let layered_options_crossing_minimization_hierarchical_sweepiness : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.hierarchicalSweepiness", 0.1,
)

///|
pub let layered_options_crossing_minimization_position_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.positionId", 0,
)

///|
pub let layered_options_crossing_minimization_position_choice_constraint : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.positionChoiceConstraint", -1,
)

///|
pub let layered_options_crossing_minimization_in_layer_pred_of : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.inLayerPredOf", "",
)

///|
pub let layered_options_crossing_minimization_in_layer_succ_of : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.inLayerSuccOf", "",
)

///|
pub let layered_options_position : @graph.IProperty[@core.KVector] = @graph.new_property(
  "org.eclipse.elk.position",
  @core.new_kvector(),
)

///|
pub let layered_options_crossing_minimization_greedy_switch_type : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.greedySwitch.type", "TWO_SIDED",
)

///|
pub let layered_options_crossing_minimization_greedy_switch_activation_threshold : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.greedySwitch.activationThreshold",
  40,
)

///|
pub let layered_options_crossing_minimization_greedy_switch_hierarchical_type : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.greedySwitchHierarchical.type", "OFF",
)

///|
pub let layered_options_crossing_minimization_semi_interactive : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.crossingMinimization.semiInteractive", false,
)

///|
pub let layered_options_interactive_reference_point : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.interactiveReferencePoint", "CENTER",
)

///|
pub let layered_options_merge_edges : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.mergeEdges", false,
)

///|
pub let layered_options_merge_hierarchy_edges : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.mergeHierarchyEdges", true,
)

///|
pub let layered_options_node_placement_favor_straight_edges : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.favorStraightEdges", false,
)

///|
pub let layered_options_node_placement_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.strategy", "BRANDES_KOEPF",
)

///|
pub let layered_options_node_placement_bk_fixed_alignment : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.bk.fixedAlignment", "NONE",
)

///|
pub let layered_options_node_placement_bk_edge_straightening : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.bk.edgeStraightening", "IMPROVE_STRAIGHTNESS",
)

///|
pub let layered_options_node_placement_network_simplex_node_flexibility : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility", "NONE",
)

///|
pub let layered_options_node_placement_network_simplex_node_flexibility_default : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePlacement.networkSimplex.nodeFlexibility.default",
  "NONE",
)

///|
pub let layered_options_consider_model_order_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.strategy", "NONE",
)

///|
pub let layered_options_consider_model_order_components : @graph.IProperty[
  ComponentOrderingStrategy,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.components",
  ComponentOrderingStrategy::NoneType,
)

///|
pub let layered_options_cycle_breaking_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.cycleBreaking.strategy", "GREEDY",
)

///|
pub let layered_options_layering_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.layering.strategy", "NETWORK_SIMPLEX",
)

///|
pub let layered_options_layering_coffman_graham_layer_bound : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.layering.coffmanGraham.layerBound",
  @int.MAX_VALUE,
)

///|
pub let layered_options_layering_node_promotion_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePromotion.strategy", "NONE",
)

///|
pub let layered_options_layering_node_promotion_max_iterations : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.nodePromotion.maxIterations", 0,
)

///|
pub let layered_options_high_degree_nodes_treatment : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.alg.layered.highDegreeNodes.treatment", false,
)

///|
pub let layered_options_high_degree_nodes_threshold : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.alg.layered.highDegreeNodes.threshold", 16,
)

///|
pub let layered_options_high_degree_nodes_tree_height : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.alg.layered.highDegreeNodes.treeHeight", 5,
)

///|
pub let layered_options_compaction_post_compaction_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.alg.layered.compaction.postCompaction.strategy", "NONE",
)

///|
pub let layered_options_compaction_post_compaction_constraints : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.alg.layered.compaction.postCompaction.constraints", "QUADRATIC",
)

///|
pub let layered_options_compaction_connected_components : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.compaction.connectedComponents", false,
)

///|
pub let layered_options_priority_direction : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.priority.direction", 0,
)

///|
pub let layered_options_priority_shortness : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.priority.shortness", 0,
)

///|
pub let layered_options_priority_straightness : @graph.IProperty[Int] = @graph.new_property(
  "priority.straightness", 0,
)

///|
pub let layered_options_allow_non_flow_ports_to_switch_sides : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.allowNonFlowPortsToSwitchSides", false,
)

///|
pub let layered_options_layer_unzipping_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.layerUnzipping.strategy", "NONE",
)

///|
pub let layered_options_layer_unzipping_minimize_edge_length : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.layerUnzipping.minimizeEdgeLength", false,
)

///|
pub let layered_options_layer_unzipping_layer_split : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.layerUnzipping.layerSplit", 2,
)

///|
pub let layered_options_layer_unzipping_reset_on_long_edges : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.layerUnzipping.resetOnLongEdges", true,
)

///|
pub let layered_options_consider_model_order_group_model_order_cycle_breaking_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cycleBreakingId", 0,
)

///|
pub let layered_options_consider_model_order_group_model_order_crossing_minimization_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.crossingMinimizationId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_component_group_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.componentGroupId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_group_order_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbGroupOrderStrategy",
  "ONLY_WITHIN_GROUP",
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_preferred_source_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbPreferredSourceId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cb_preferred_target_id : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cbPreferredTargetId",
  0,
)

///|
pub let layered_options_consider_model_order_group_model_order_cm_group_order_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cmGroupOrderStrategy",
  "ONLY_WITHIN_GROUP",
)

///|
pub let layered_options_consider_model_order_group_model_order_cm_enforced_group_orders : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.groupModelOrder.cmEnforcedGroupOrders",
  "[1, 2, 6, 7, 10, 11]",
)

///|
pub let layered_options_thoroughness : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.thoroughness", 7,
)

///|
pub let layered_options_spacing_base_value : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.layered.spacing.baseValue",
  @core.spacing_node_node.get_default(),
)

///|
pub let layered_options_spacing_comment_comment : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.commentComment", 10.0,
)

///|
pub let layered_options_spacing_comment_node : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.commentNode", 10.0,
)

///|
pub let layered_options_spacing_ports_surrounding : @graph.IProperty[
  @core.ElkMargin,
] = @graph.new_property(
  "org.eclipse.elk.spacing.portsSurrounding",
  @core.new_elk_margin(),
)

///|
pub let layered_options_comment_box : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.commentBox", false,
)

///|
pub let layered_options_edge_labels_side_selection : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.edgeLabels.sideSelection", "SMART_DOWN",
)

///|
pub let layered_options_edge_labels_center_label_placement_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeLabels.centerLabelPlacementStrategy", "MEDIAN_LAYER",
)

///|
pub let layered_options_hypernode : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.hypernode", false,
)

///|
pub let layered_options_spacing_edge_node_between_layers : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.spacing.edgeNodeBetweenLayers", 10.0,
)

///|
pub let layered_options_spacing_edge_edge_between_layers : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.spacing.edgeEdgeBetweenLayers", 10.0,
)

///|
pub let layered_options_spacing_node_node_between_layers : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.spacing.nodeNodeBetweenLayers", 20.0,
)

///|
pub let layered_options_edge_routing_splines_mode : @graph.IProperty[
  SplineRoutingMode,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeRouting.splines.mode",
  SplineRoutingMode::Sloppy,
)

///|
pub let layered_options_edge_routing_splines_sloppy_layer_spacing_factor : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeRouting.splines.sloppy.layerSpacingFactor", 0.2,
)

///|
pub let layered_options_edge_routing_polyline_sloped_edge_zone_width : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeRouting.polyline.slopedEdgeZoneWidth", 2.0,
)

///|
pub let layered_options_edge_routing_self_loop_distribution : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeRouting.selfLoopDistribution", "NORTH",
)

///|
pub let layered_options_edge_routing_self_loop_ordering : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.edgeRouting.selfLoopOrdering", "STACKED",
)

///|
pub let layered_options_feedback_edges : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.feedbackEdges", false,
)

///|
pub let layered_options_port_sorting_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.portSortingStrategy", "INPUT_ORDER",
)

///|
pub let layered_options_port_index : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.port.index", -1,
)

///|
pub let layered_options_port_anchor : @graph.IProperty[@core.KVector] = @graph.new_property(
  "org.eclipse.elk.port.anchor",
  @core.new_kvector(),
)

///|
pub let layered_options_port_border_offset : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.port.borderOffset", 0.0,
)

///|
pub let layered_options_unnecessary_bendpoints : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.unnecessaryBendpoints", false,
)

///|
pub let layered_options_generate_position_and_layer_ids : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.layered.generatePositionAndLayerIds", false,
)

///|
pub let layered_options_junction_points : @graph.IProperty[@core.KVectorChain] = @graph.new_property(
  "org.eclipse.elk.junctionPoints",
  @core.new_kvector_chain(),
)

///|
pub let layered_options_hierarchy_handling : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.hierarchyHandling", "INHERIT",
)

///|
pub let layered_options_consider_model_order_crossing_counter_node_influence : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.crossingCounterNodeInfluence", 0.0,
)

///|
pub let layered_options_consider_model_order_crossing_counter_port_influence : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.crossingCounterPortInfluence", 0.0,
)

///|
pub let layered_options_consider_model_order_port_model_order : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.portModelOrder", false,
)

///|
pub let layered_options_consider_model_order_long_edge_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.considerModelOrder.longEdgeStrategy", "DUMMY_NODE_OVER",
)

///|
pub let layered_options_wrapping_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.strategy", "OFF",
)

///|
pub let layered_options_wrapping_additional_edge_spacing : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.additionalEdgeSpacing", 10.0,
)

///|
pub let layered_options_wrapping_correction_factor : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.correctionFactor", 1.0,
)

///|
pub let layered_options_wrapping_cutting_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.cutting.strategy", "MSD",
)

///|
pub let layered_options_wrapping_cutting_cuts : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.cutting.cuts", "",
)

///|
pub let layered_options_wrapping_cutting_msd_freedom : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.cutting.msd.freedom", 1,
)

///|
pub let layered_options_wrapping_validify_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.validify.strategy", "GREEDY",
)

///|
pub let layered_options_wrapping_validify_forbidden_indices : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.validify.forbiddenIndices", "",
)

///|
pub let layered_options_wrapping_multi_edge_improve_cuts : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.improveCuts", true,
)

///|
pub let layered_options_wrapping_multi_edge_distance_penalty : @graph.IProperty[
  Double,
] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.distancePenalty", 2.0,
)

///|
pub let layered_options_wrapping_multi_edge_improve_wrapped_edges : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.layered.wrapping.multiEdge.improveWrappedEdges", true,
)

///|
pub fn layered_options_parse_int_list(value : String) -> Array[Int] {
  let normalized = value
    .replace_all(old="[", new="")
    .replace_all(old="]", new="")
    .trim()
    .to_owned()
  if normalized.is_empty() {
    return []
  }

  let result = []
  for token_view in normalized.split(",") {
    let token = token_view.to_owned().trim().to_owned()
    if token.is_empty() {
      continue
    }
    let parsed : Result[Int, Error] = try? @string.parse_int(token)
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
