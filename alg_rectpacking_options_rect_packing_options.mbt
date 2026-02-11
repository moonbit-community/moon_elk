///|
pub let rectpacking_algorithm_id = "org.eclipse.elk.rectpacking"

///|
pub let rectpacking_aspect_ratio : IProperty[Double] = aspect_ratio

///|
pub let rectpacking_padding : IProperty[String] = padding

///|
pub let rectpacking_spacing_node_node : IProperty[Double] = spacing_node_node

///|
pub let rectpacking_node_size_fixed_graph_size : IProperty[Bool] = node_size_fixed_graph_size

///|
pub let rectpacking_omit_node_micro_layout : IProperty[Bool] = omit_node_micro_layout

///|
pub let rectpacking_interactive : IProperty[Bool] = interactive

///|
pub let rectpacking_width_approximation_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.strategy", "GREEDY",
)

///|
pub let rectpacking_width_approximation_target_width : IProperty[Double] = new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.targetWidth", -1.0,
)

///|
pub let rectpacking_width_approximation_optimization_goal : IProperty[String] = new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.optimizationGoal", "MAX_SCALE_DRIVEN",
)

///|
pub let rectpacking_width_approximation_last_place_shift : IProperty[Bool] = new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.lastPlaceShift", true,
)

///|
pub let rectpacking_packing_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.rectpacking.packing.strategy", "COMPACTION",
)

///|
pub let rectpacking_packing_compaction_row_height_reevaluation : IProperty[Bool] = new_property(
  "org.eclipse.elk.rectpacking.packing.compaction.rowHeightReevaluation", false,
)

///|
pub let rectpacking_packing_compaction_iterations : IProperty[Double] = new_property(
  "org.eclipse.elk.rectpacking.packing.compaction.iterations", 1.0,
)

///|
pub let rectpacking_white_space_elimination_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.rectpacking.whiteSpaceElimination.strategy", "NONE",
)

///|
pub let rectpacking_trybox : IProperty[Bool] = new_property(
  "org.eclipse.elk.rectpacking.trybox", false,
)

///|
pub let rectpacking_current_position : IProperty[Double] = new_property(
  "org.eclipse.elk.rectpacking.currentPosition", -1.0,
)

///|
pub let rectpacking_desired_position : IProperty[Double] = new_property(
  "org.eclipse.elk.rectpacking.desiredPosition", -1.0,
)

///|
pub let rectpacking_in_new_row : IProperty[Bool] = new_property(
  "org.eclipse.elk.rectpacking.inNewRow", false,
)

///|
pub let rectpacking_order_by_size : IProperty[Bool] = new_property(
  "org.eclipse.elk.rectpacking.orderBySize", false,
)
