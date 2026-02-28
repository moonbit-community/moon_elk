///|
pub let radial_algorithm_id = "org.eclipse.elk.radial"

///|
pub let radial_option_position_id = "org.eclipse.elk.position"

///|
pub let radial_option_margins_id = "org.eclipse.elk.margins"

///|
pub let radial_center_on_root : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.radial.centerOnRoot", false,
)

///|
pub let radial_order_id : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.orderId", 0.0,
)

///|
pub let radial_radius : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.radius", 0.0,
)

///|
pub let radial_rotate : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.radial.rotate", false,
)

///|
pub let radial_rotation_target_angle : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.rotation.targetAngle", 0.0,
)

///|
pub let radial_rotation_compute_additional_wedge_space : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.radial.rotation.computeAdditionalWedgeSpace", false,
)

///|
pub let radial_rotation_outgoing_edge_angles : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.radial.rotation.outgoingEdgeAngles", false,
)

///|
pub let radial_compaction_step_size : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.radial.compactionStepSize", 1.0,
)

///|
pub let radial_compactor : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.radial.compactor", "NONE",
)

///|
pub let radial_sorter : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.radial.sorter", "NONE",
)

///|
pub let radial_wedge_criteria : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.radial.wedgeCriteria", "NODE_SIZE",
)

///|
pub let radial_optimization_criteria : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.radial.optimizationCriteria", "NONE",
)

///|
pub let radial_omit_node_micro_layout : @graph.IProperty[Bool] = @core.omit_node_micro_layout

///|
pub fn radial_sorting_strategy_from_string(
  value : String,
) -> RadialSortingStrategy {
  if value == "POLAR_COORDINATE" {
    RadialSortingStrategy::POLAR_COORDINATE
  } else if value == "ID" {
    RadialSortingStrategy::ID
  } else {
    RadialSortingStrategy::NONE
  }
}

///|
pub fn radial_annulus_wedge_criteria_from_string(
  value : String,
) -> RadialAnnulusWedgeCriteria {
  if value == "LEAF_NUMBER" {
    RadialAnnulusWedgeCriteria::LEAF_NUMBER
  } else {
    RadialAnnulusWedgeCriteria::NODE_SIZE
  }
}

///|
pub fn radial_translation_strategy_from_string(
  value : String,
) -> RadialTranslationStrategy {
  if value == "EDGE_LENGTH" {
    RadialTranslationStrategy::EDGE_LENGTH
  } else if value == "EDGE_LENGTH_BY_POSITION" {
    RadialTranslationStrategy::EDGE_LENGTH_BY_POSITION
  } else if value == "CROSSING_MINIMIZATION_BY_POSITION" {
    RadialTranslationStrategy::CROSSING_MINIMIZATION_BY_POSITION
  } else {
    RadialTranslationStrategy::NONE
  }
}

///|
pub fn radial_compaction_strategy_from_string(
  value : String,
) -> RadialCompactionStrategy {
  if value == "RADIAL_COMPACTION" {
    RadialCompactionStrategy::RADIAL_COMPACTION
  } else if value == "WEDGE_COMPACTION" {
    RadialCompactionStrategy::WEDGE_COMPACTION
  } else {
    RadialCompactionStrategy::NONE
  }
}

///|
pub fn radial_overlap_removal_strategy_from_string(
  value : String,
) -> RadialOverlapRemovalStrategy {
  ignore(value)
  RadialOverlapRemovalStrategy::EXTENT_RADII
}

///|
pub fn radial_graph_sorting_strategy(
  graph : @graph.ElkNode,
) -> RadialSortingStrategy {
  radial_sorting_strategy_from_string(
    @graph.node_get_string_property(graph, radial_sorter),
  )
}

///|
pub fn radial_graph_wedge_criteria(
  graph : @graph.ElkNode,
) -> RadialAnnulusWedgeCriteria {
  radial_annulus_wedge_criteria_from_string(
    @graph.node_get_string_property(graph, radial_wedge_criteria),
  )
}

///|
pub fn radial_graph_translation_strategy(
  graph : @graph.ElkNode,
) -> RadialTranslationStrategy {
  radial_translation_strategy_from_string(
    @graph.node_get_string_property(graph, radial_optimization_criteria),
  )
}

///|
pub fn radial_graph_compaction_strategy(
  graph : @graph.ElkNode,
) -> RadialCompactionStrategy {
  radial_compaction_strategy_from_string(
    @graph.node_get_string_property(graph, radial_compactor),
  )
}

///|
pub fn radial_graph_compaction_step_size(graph : @graph.ElkNode) -> Int {
  let value = @graph.node_get_double_property(
    graph, radial_compaction_step_size,
  )
  if value < 0.0 {
    0
  } else {
    value.to_int()
  }
}
