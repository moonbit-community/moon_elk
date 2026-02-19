///|
pub let internal_properties_origin_l_node : @graph.IProperty[LNode?] = @graph.new_property(
  "origin",
  None,
)

///|
pub let internal_properties_reversed : @graph.IProperty[Bool] = @graph.new_property(
  "reversed", false,
)

///|
pub let internal_properties_cyclic : @graph.IProperty[Bool] = @graph.new_property(
  "cyclic", false,
)

///|
pub let internal_properties_origin_l_port : @graph.IProperty[LPort?] = @graph.new_property(
  "origin",
  None,
)

///|
pub let internal_properties_origin_l_edge : @graph.IProperty[LEdge?] = @graph.new_property(
  "origin",
  None,
)

///|
pub let internal_properties_end_label_edge : @graph.IProperty[LEdge?] = @graph.new_property(
  "endLabelEdge",
  None,
)

///|
pub let internal_properties_end_labels : @graph.IProperty[Array[EndLabelCell]] = @graph.new_property(
  "endLabels",
  [],
)

///|
pub let internal_properties_max_edge_thickness : @graph.IProperty[Double] = @graph.new_property(
  "maxEdgeThickness", 0.0,
)

///|
pub let internal_properties_represented_labels : @graph.IProperty[Array[LLabel]] = @graph.new_property(
  "representedLabels",
  [],
)

///|
pub let internal_properties_label_side : @graph.IProperty[@core.LabelSide] = @graph.new_property(
  "labelSide",
  @core.LabelSide::Unknown,
)

///|
pub let internal_properties_in_layer_layout_unit : @graph.IProperty[LNode?] = @graph.new_property(
  "inLayerLayoutUnit",
  None,
)

///|
pub let internal_properties_in_layer_constraint : @graph.IProperty[String] = @graph.new_property(
  "inLayerConstraint", "NONE",
)

///|
pub let internal_properties_in_layer_successor_constraints : @graph.IProperty[
  Array[LNode],
] = @graph.new_property("inLayerSuccessorConstraint", [])

///|
pub let internal_properties_in_layer_successor_constraints_between_non_dummies : @graph.IProperty[
  Bool,
] = @graph.new_property("inLayerSuccessorConstraintBetweenNonDummies", false)

///|
pub let internal_properties_port_dummy : @graph.IProperty[LNode?] = @graph.new_property(
  "portDummy",
  None,
)

///|
pub let internal_properties_crossing_hint : @graph.IProperty[Int] = @graph.new_property(
  "crossingHint", 0,
)

///|
pub let internal_properties_original_port_constraints : @graph.IProperty[String] = @graph.new_property(
  "originalPortConstraints", "UNDEFINED",
)

///|
pub let internal_properties_input_collect : @graph.IProperty[Bool] = @graph.new_property(
  "inputCollect", false,
)

///|
pub let internal_properties_output_collect : @graph.IProperty[Bool] = @graph.new_property(
  "outputCollect", false,
)

///|
pub let internal_properties_self_loop_holder : @graph.IProperty[SelfLoopHolder?] = @graph.new_property(
  "selfLoopHolder",
  None,
)

///|
pub let internal_properties_long_edge_source : @graph.IProperty[LPort?] = @graph.new_property(
  "longEdgeSource",
  None,
)

///|
pub let internal_properties_long_edge_target : @graph.IProperty[LPort?] = @graph.new_property(
  "longEdgeTarget",
  None,
)

///|
pub let internal_properties_long_edge_has_label_dummies : @graph.IProperty[Bool] = @graph.new_property(
  "longEdgeHasLabelDummies", false,
)

///|
pub let internal_properties_long_edge_before_label_dummy : @graph.IProperty[
  Bool,
] = @graph.new_property("longEdgeBeforeLabelDummy", false)

///|
pub let internal_properties_edge_constraint : @graph.IProperty[String] = @graph.new_property(
  "edgeConstraint", "NONE",
)

///|
pub let internal_properties_long_edge_target_node : @graph.IProperty[LNode?] = @graph.new_property(
  "longEdgeTargetNode",
  None,
)

///|
pub let internal_properties_target_node_model_order : @graph.IProperty[
  Map[Int, Int],
] = @graph.new_property("targetNode.modelOrder", {})

///|
pub let internal_properties_hidden_nodes : @graph.IProperty[Array[LNode]] = @graph.new_property(
  "hiddenNodes",
  [],
)

///|
pub let internal_properties_original_opposite_port : @graph.IProperty[LPort?] = @graph.new_property(
  "originalOppositePort",
  None,
)

///|
pub let internal_properties_partition_dummy : @graph.IProperty[Bool] = @graph.new_property(
  "partitionDummy", false,
)

///|
pub let internal_properties_ext_port_connections : @graph.IProperty[
  Array[@core.PortSide],
] = @graph.new_property("externalPortConnections", @core.sides_none)

///|
pub let internal_properties_ext_port_side : @graph.IProperty[@core.PortSide] = @graph.new_property(
  "externalPortSide",
  @core.PortSide::SideUndefined,
)

///|
pub let internal_properties_ext_port_size : @graph.IProperty[@core.KVector] = @graph.new_property(
  "externalPortSize",
  @core.new_kvector(),
)

///|
pub let internal_properties_port_ratio_or_position : @graph.IProperty[Double] = @graph.new_property(
  "portRatioOrPosition", 0.0,
)

///|
pub let internal_properties_ext_port_replaced_dummy : @graph.IProperty[LNode?] = @graph.new_property(
  "externalPortReplacedDummy",
  None,
)

///|
pub let internal_properties_ext_port_replaced_dummies : @graph.IProperty[
  Array[LNode],
] = @graph.new_property("externalPortReplacedDummies", [])

///|
pub let internal_properties_tarjan_lowlink : @graph.IProperty[Int] = @graph.new_property(
  "tarjan.lowlink", @int.max_value,
)

///|
pub let internal_properties_tarjan_id : @graph.IProperty[Int] = @graph.new_property(
  "tarjan.id", -1,
)

///|
pub let internal_properties_tarjan_on_stack : @graph.IProperty[Bool] = @graph.new_property(
  "tarjan.onstack", false,
)

///|
pub let internal_properties_is_part_of_cycle : @graph.IProperty[Bool] = @graph.new_property(
  "partOfCycle", false,
)

///|
pub let internal_properties_barycenter_associates : @graph.IProperty[
  Array[LNode],
] = @graph.new_property("barycenterAssociates", [])

///|
pub let internal_properties_top_comments : @graph.IProperty[Array[LNode]] = @graph.new_property(
  "TopSideComments",
  [],
)

///|
pub let internal_properties_bottom_comments : @graph.IProperty[Array[LNode]] = @graph.new_property(
  "BottomSideComments",
  [],
)

///|
pub let internal_properties_comment_conn_port : @graph.IProperty[LPort?] = @graph.new_property(
  "CommentConnectionPort",
  None,
)

///|
pub let internal_properties_weight : @graph.IProperty[Double] = @graph.new_property(
  "medianHeuristic.weight", 0.0,
)

///|
pub let internal_properties_model_order : @graph.IProperty[Int] = @graph.new_property(
  "modelOrder", -1,
)

///|
pub let internal_properties_max_model_order_nodes : @graph.IProperty[Int] = @graph.new_property(
  "modelOrder.maximum", 0,
)

///|
pub let internal_properties_cb_num_model_order_groups : @graph.IProperty[Int] = @graph.new_property(
  "modelOrderGroups.cb.number", 0,
)

///|
pub let internal_properties_compound_node : @graph.IProperty[Bool] = @graph.new_property(
  "compoundNode", false,
)

///|
pub let internal_properties_inside_connections : @graph.IProperty[Bool] = @graph.new_property(
  "insideConnections", false,
)

///|
pub let internal_properties_first_try_with_initial_order : @graph.IProperty[
  Bool,
] = @graph.new_property("crossingMinimization.firstTryWithInitialOrder", false)

///|
pub let internal_properties_second_try_with_initial_order : @graph.IProperty[
  Bool,
] = @graph.new_property("crossingMinimization.secondTryWithInitialOrder", false)

///|
pub let internal_properties_original_dummy_node_position : @graph.IProperty[
  Double,
] = @graph.new_property("originalDummyNodePosition", 0.0)

///|
pub let internal_properties_random_next_boolean : @graph.IProperty[Bool] = @graph.new_property(
  "random.nextBoolean", true,
)

///|
pub let internal_properties_processors : @graph.IProperty[
  Array[@core.ILayoutProcessor[LayeredPhases, LGraph]],
] = @graph.new_property("processors", [])

///|
pub let internal_properties_spacings : @graph.IProperty[Spacings?] = @graph.new_property(
  "spacings",
  None,
)

///|
pub let internal_properties_spline_ns_port_y_coord : @graph.IProperty[Double] = @graph.new_property(
  "splineNsPortYCoord", 0.0,
)

///|
pub let internal_properties_graph_properties : @graph.IProperty[
  Array[GraphProperties],
] = @graph.new_property("graphProperties", [])

///|
pub let internal_properties_spline_route_start : @graph.IProperty[
  Array[SplineSegment],
] = @graph.new_property("splines.route.start", [])

///|
pub let internal_properties_spline_edge_chain : @graph.IProperty[Array[LEdge]] = @graph.new_property(
  "splines.edgeChain",
  [],
)

///|
pub let internal_properties_spline_surviving_edge : @graph.IProperty[LEdge?] = @graph.new_property(
  "splines.survivingEdge",
  None,
)

///|
pub let internal_properties_breaking_point_info : @graph.IProperty[BPInfo?] = @graph.new_property(
  "breakingPointInfo",
  None,
)
