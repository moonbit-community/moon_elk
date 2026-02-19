///|
pub let libavoid_option_edge_routing : IProperty[String] = new_property(
  "org.eclipse.elk.edgeRouting", "ORTHOGONAL",
)

///|
pub let libavoid_option_direction : IProperty[String] = new_property(
  "org.eclipse.elk.direction", "UNDEFINED",
)

///|
pub let libavoid_option_omit_node_micro_layout : IProperty[Bool] = new_property(
  "org.eclipse.elk.omitNodeMicroLayout", false,
)

///|
pub let libavoid_option_debug_mode : IProperty[Bool] = new_property(
  "org.eclipse.elk.debugMode", false,
)

///|
pub let libavoid_option_segment_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.segmentPenalty", 10.0,
)

///|
pub let libavoid_option_angle_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.anglePenalty", 0.0,
)

///|
pub let libavoid_option_crossing_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.crossingPenalty", 0.0,
)

///|
pub let libavoid_option_cluster_crossing_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.clusterCrossingPenalty", 0.0,
)

///|
pub let libavoid_option_fixed_shared_path_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.fixedSharedPathPenalty", 0.0,
)

///|
pub let libavoid_option_port_direction_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.portDirectionPenalty", 0.0,
)

///|
pub let libavoid_option_shape_buffer_distance : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.shapeBufferDistance", 4.0,
)

///|
pub let libavoid_option_ideal_nudging_distance : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.idealNudgingDistance", 4.0,
)

///|
pub let libavoid_option_reverse_direction_penalty : IProperty[Double] = new_property(
  "org.eclipse.elk.alg.libavoid.reverseDirectionPenalty", 0.0,
)

///|
pub let libavoid_option_nudge_orthogonal_segments_connected_to_shapes : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.nudgeOrthogonalSegmentsConnectedToShapes", false,
)

///|
pub let libavoid_option_improve_hyperedge_routes_moving_junctions : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.improveHyperedgeRoutesMovingJunctions", true,
)

///|
pub let libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.penaliseOrthogonalSharedPathsAtConnEnds", false,
)

///|
pub let libavoid_option_nudge_orthogonal_touching_colinear_segments : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.nudgeOrthogonalTouchingColinearSegments", false,
)

///|
pub let libavoid_option_perform_unifying_nudging_preprocessing_step : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.performUnifyingNudgingPreprocessingStep", true,
)

///|
pub let libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.improveHyperedgeRoutesMovingAddingAndDeletingJunctions",
  false,
)

///|
pub let libavoid_option_nudge_shared_paths_with_common_end_point : IProperty[
  Bool,
] = new_property(
  "org.eclipse.elk.alg.libavoid.nudgeSharedPathsWithCommonEndPoint", true,
)

///|
pub let libavoid_option_enable_hyperedges_from_common_source : IProperty[Bool] = new_property(
  "org.eclipse.elk.alg.libavoid.enableHyperedgesFromCommonSource", false,
)

///|
pub let libavoid_option_is_cluster : IProperty[Bool] = new_property(
  "org.eclipse.elk.alg.libavoid.isCluster", false,
)

///|
pub let libavoid_option_process_timeout : IProperty[Int] = new_property(
  "org.eclipse.elk.alg.libavoid.processTimeout", 10000,
)

///|
pub let libavoid_option_junction_points_id : String = "org.eclipse.elk.junctionPoints"
