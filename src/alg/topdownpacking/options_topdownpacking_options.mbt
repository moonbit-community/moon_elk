///|
pub let topdownpacking_algorithm_id = "org.eclipse.elk.topdownpacking"

///|
pub let topdownpacking_padding : @graph.IProperty[String] = @core.padding

///|
pub let topdownpacking_spacing_node_node : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub let topdownpacking_hierarchical_node_width : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.topdown.hierarchicalNodeWidth", 150.0,
)

///|
pub let topdownpacking_hierarchical_node_aspect_ratio : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.topdown.hierarchicalNodeAspectRatio", 1.414,
)

///|
pub let topdownpacking_node_arrangement_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.topdownpacking.nodeArrangement.strategy", "LEFT_RIGHT_TOP_DOWN_NODE_PLACER",
)

///|
pub let topdownpacking_whitespace_elimination_strategy : @graph.IProperty[
  String,
] = @graph.new_property(
  "org.eclipse.elk.topdownpacking.whitespaceElimination.strategy", "BOTTOM_ROW_EQUAL_WHITESPACE_ELIMINATOR",
)
