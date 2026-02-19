///|
pub let libavoid_option_edge_routing : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.edgeRouting", "ORTHOGONAL",
)

///|
pub let libavoid_option_direction : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.direction", "UNDEFINED",
)

///|
pub let libavoid_option_omit_node_micro_layout : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.omitNodeMicroLayout", false,
)

///|
pub let libavoid_option_debug_mode : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.debugMode", false,
)

///|
pub let libavoid_option_segment_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.segmentPenalty", 10.0,
)

///|
pub let libavoid_option_angle_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.anglePenalty", 0.0,
)

///|
pub let libavoid_option_crossing_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.crossingPenalty", 0.0,
)

///|
pub let libavoid_option_cluster_crossing_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.clusterCrossingPenalty", 0.0,
)

///|
pub let libavoid_option_fixed_shared_path_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.fixedSharedPathPenalty", 0.0,
)

///|
pub let libavoid_option_port_direction_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.portDirectionPenalty", 0.0,
)

///|
pub let libavoid_option_shape_buffer_distance : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.shapeBufferDistance", 4.0,
)

///|
pub let libavoid_option_ideal_nudging_distance : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.idealNudgingDistance", 4.0,
)

///|
pub let libavoid_option_reverse_direction_penalty : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.reverseDirectionPenalty", 0.0,
)

///|
pub let libavoid_option_nudge_orthogonal_segments_connected_to_shapes : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.nudgeOrthogonalSegmentsConnectedToShapes", false,
)

///|
pub let libavoid_option_improve_hyperedge_routes_moving_junctions : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.improveHyperedgeRoutesMovingJunctions", true,
)

///|
pub let libavoid_option_penalise_orthogonal_shared_paths_at_conn_ends : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.penaliseOrthogonalSharedPathsAtConnEnds", false,
)

///|
pub let libavoid_option_nudge_orthogonal_touching_colinear_segments : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.nudgeOrthogonalTouchingColinearSegments", false,
)

///|
pub let libavoid_option_perform_unifying_nudging_preprocessing_step : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.performUnifyingNudgingPreprocessingStep", true,
)

///|
pub let libavoid_option_improve_hyperedge_routes_moving_adding_and_deleting_junctions : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.improveHyperedgeRoutesMovingAddingAndDeletingJunctions",
  false,
)

///|
pub let libavoid_option_nudge_shared_paths_with_common_end_point : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.nudgeSharedPathsWithCommonEndPoint", true,
)

///|
pub let libavoid_option_enable_hyperedges_from_common_source : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.enableHyperedgesFromCommonSource", false,
)

///|
pub let libavoid_option_is_cluster : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.isCluster", false,
)

///|
pub let libavoid_option_process_timeout : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.alg.libavoid.processTimeout", 10000,
)

///|
pub let libavoid_option_junction_points_id : String = "org.eclipse.elk.junctionPoints"
