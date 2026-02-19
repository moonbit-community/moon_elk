///|
pub let mrtree_algorithm_id = "org.eclipse.elk.mrtree"

///|
pub let mrtree_separate_connected_components : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.separateConnectedComponents", true,
)

///|
pub let mrtree_compaction : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.mrtree.compaction", false,
)

///|
pub let mrtree_edge_routing_mode : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.mrtree.edgeRoutingMode", "AVOID_OVERLAP",
)

///|
pub let mrtree_weighting : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.mrtree.weighting", "MODEL_ORDER",
)

///|
pub let mrtree_search_order : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.mrtree.searchOrder", "DFS",
)

///|
pub let mrtree_edge_end_texture_length : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.mrtree.edgeEndTextureLength", 7.0,
)

///|
pub let mrtree_tree_level : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.mrtree.treeLevel", 0,
)

///|
pub let mrtree_position_constraint : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.mrtree.positionConstraint", -1.0,
)

///|
pub let mrtree_padding : @graph.IProperty[String] = @core.padding

///|
pub let mrtree_spacing_node_node : @graph.IProperty[Double] = @core.spacing_node_node

///|
pub let mrtree_aspect_ratio : @graph.IProperty[Double] = @core.aspect_ratio

///|
pub let mrtree_priority : @graph.IProperty[Double] = @core.priority

///|
pub let mrtree_omit_node_micro_layout : @graph.IProperty[Bool] = @core.omit_node_micro_layout
