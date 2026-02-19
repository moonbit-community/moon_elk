///|
pub let rectpacking_algorithm_id = "org.eclipse.elk.rectpacking"

///|
pub let rectpacking_aspect_ratio : @graph.IProperty[Double] = @core.aspect_ratio

///|
pub let rectpacking_padding : @graph.IProperty[String] = @core.padding

///|
pub let rectpacking_spacing_node_node : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub let rectpacking_node_size_fixed_graph_size : @graph.IProperty[Bool] = @core.node_size_fixed_graph_size

///|
pub let rectpacking_omit_node_micro_layout : @graph.IProperty[Bool] = @core.omit_node_micro_layout

///|
pub let rectpacking_interactive : @graph.IProperty[Bool] = @core.interactive

///|
pub let rectpacking_width_approximation_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.strategy", "GREEDY",
)

///|
pub let rectpacking_width_approximation_target_width : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.targetWidth", -1.0,
)

///|
pub let rectpacking_width_approximation_optimization_goal : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.optimizationGoal", "MAX_SCALE_DRIVEN",
)

///|
pub let rectpacking_width_approximation_last_place_shift : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.rectpacking.widthApproximation.lastPlaceShift", true,
)

///|
pub let rectpacking_packing_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.rectpacking.packing.strategy", "COMPACTION",
)

///|
pub let rectpacking_packing_compaction_row_height_reevaluation : @graph.IProperty[
  Bool,
] = @graph.new_property(
  "org.eclipse.elk.rectpacking.packing.compaction.rowHeightReevaluation", false,
)

///|
pub let rectpacking_packing_compaction_iterations : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.rectpacking.packing.compaction.iterations", 1.0,
)

///|
pub let rectpacking_white_space_elimination_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.rectpacking.whiteSpaceElimination.strategy", "NONE",
)

///|
pub let rectpacking_trybox : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.rectpacking.trybox", false,
)

///|
pub let rectpacking_current_position : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.rectpacking.currentPosition", -1.0,
)

///|
pub let rectpacking_desired_position : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.rectpacking.desiredPosition", -1.0,
)

///|
pub let rectpacking_in_new_row : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.rectpacking.inNewRow", false,
)

///|
pub let rectpacking_order_by_size : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.rectpacking.orderBySize", false,
)
