///|
pub let internal_properties_origin_l_node : IProperty[LNode?] = new_property(
  "origin",
  None,
)

///|
pub let internal_properties_reversed : IProperty[Bool] = new_property(
  "reversed", false,
)

///|
pub let internal_properties_cyclic : IProperty[Bool] = new_property(
  "cyclic", false,
)

///|
pub let internal_properties_origin_l_port : IProperty[LPort?] = new_property(
  "origin",
  None,
)

///|
pub let internal_properties_origin_l_edge : IProperty[LEdge?] = new_property(
  "origin",
  None,
)

///|
pub let internal_properties_end_label_edge : IProperty[LEdge?] = new_property(
  "endLabelEdge",
  None,
)

///|
pub let internal_properties_in_layer_layout_unit : IProperty[LNode?] = new_property(
  "inLayerLayoutUnit",
  None,
)

///|
pub let internal_properties_in_layer_constraint : IProperty[String] = new_property(
  "inLayerConstraint", "NONE",
)

///|
pub let internal_properties_in_layer_successor_constraints : IProperty[
  Array[LNode],
] = new_property("inLayerSuccessorConstraint", [])

///|
pub let internal_properties_in_layer_successor_constraints_between_non_dummies : IProperty[
  Bool,
] = new_property("inLayerSuccessorConstraintBetweenNonDummies", false)

///|
pub let internal_properties_port_dummy : IProperty[LNode?] = new_property(
  "portDummy",
  None,
)

///|
pub let internal_properties_long_edge_source : IProperty[LPort?] = new_property(
  "longEdgeSource",
  None,
)

///|
pub let internal_properties_long_edge_target : IProperty[LPort?] = new_property(
  "longEdgeTarget",
  None,
)

///|
pub let internal_properties_long_edge_has_label_dummies : IProperty[Bool] = new_property(
  "longEdgeHasLabelDummies", false,
)

///|
pub let internal_properties_long_edge_target_node : IProperty[LNode?] = new_property(
  "longEdgeTargetNode",
  None,
)

///|
pub let internal_properties_target_node_model_order : IProperty[Map[Int, Int]] = new_property(
  "targetNode.modelOrder",
  {},
)

///|
pub let internal_properties_hidden_nodes : IProperty[Array[LNode]] = new_property(
  "hiddenNodes",
  [],
)

///|
pub let internal_properties_original_opposite_port : IProperty[LPort?] = new_property(
  "originalOppositePort",
  None,
)

///|
pub let internal_properties_partition_dummy : IProperty[Bool] = new_property(
  "partitionDummy", false,
)

///|
pub let internal_properties_ext_port_connections : IProperty[Array[PortSide]] = new_property(
  "externalPortConnections", sides_none,
)

///|
pub let internal_properties_ext_port_side : IProperty[PortSide] = new_property(
  "externalPortSide",
  PortSide::SideUndefined,
)

///|
pub let internal_properties_tarjan_lowlink : IProperty[Int] = new_property(
  "tarjan.lowlink", @int.max_value,
)

///|
pub let internal_properties_tarjan_id : IProperty[Int] = new_property(
  "tarjan.id", -1,
)

///|
pub let internal_properties_tarjan_on_stack : IProperty[Bool] = new_property(
  "tarjan.onstack", false,
)

///|
pub let internal_properties_is_part_of_cycle : IProperty[Bool] = new_property(
  "partOfCycle", false,
)

///|
pub let internal_properties_barycenter_associates : IProperty[Array[LNode]] = new_property(
  "barycenterAssociates",
  [],
)

///|
pub let internal_properties_top_comments : IProperty[Array[LNode]] = new_property(
  "TopSideComments",
  [],
)

///|
pub let internal_properties_bottom_comments : IProperty[Array[LNode]] = new_property(
  "BottomSideComments",
  [],
)

///|
pub let internal_properties_comment_conn_port : IProperty[LPort?] = new_property(
  "CommentConnectionPort",
  None,
)

///|
pub let internal_properties_weight : IProperty[Double] = new_property(
  "medianHeuristic.weight", 0.0,
)

///|
pub let internal_properties_model_order : IProperty[Int] = new_property(
  "modelOrder", -1,
)

///|
pub let internal_properties_max_model_order_nodes : IProperty[Int] = new_property(
  "modelOrder.maximum", 0,
)

///|
pub let internal_properties_cb_num_model_order_groups : IProperty[Int] = new_property(
  "modelOrderGroups.cb.number", 0,
)

///|
pub let internal_properties_inside_connections : IProperty[Bool] = new_property(
  "insideConnections", false,
)

///|
pub let internal_properties_first_try_with_initial_order : IProperty[Bool] = new_property(
  "crossingMinimization.firstTryWithInitialOrder", false,
)

///|
pub let internal_properties_second_try_with_initial_order : IProperty[Bool] = new_property(
  "crossingMinimization.secondTryWithInitialOrder", false,
)

///|
pub let internal_properties_original_dummy_node_position : IProperty[Double] = new_property(
  "originalDummyNodePosition", 0.0,
)

///|
pub let internal_properties_random_next_boolean : IProperty[Bool] = new_property(
  "random.nextBoolean", true,
)

///|
pub let internal_properties_spline_ns_port_y_coord : IProperty[Double] = new_property(
  "splineNsPortYCoord", 0.0,
)

///|
pub let internal_properties_graph_properties : IProperty[Array[GraphProperties]] = new_property(
  "graphProperties",
  [],
)

///|
pub let internal_properties_spline_route_start : IProperty[Array[SplineSegment]] = new_property(
  "splines.route.start",
  [],
)

///|
pub let internal_properties_spline_edge_chain : IProperty[Array[LEdge]] = new_property(
  "splines.edgeChain",
  [],
)
