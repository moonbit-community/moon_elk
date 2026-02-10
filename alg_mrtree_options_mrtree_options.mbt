///|
pub let mrtree_algorithm_id = "org.eclipse.elk.mrtree"

///|
pub let mrtree_separate_connected_components : IProperty[Bool] = new_property(
  "org.eclipse.elk.separateConnectedComponents", true,
)

///|
pub let mrtree_compaction : IProperty[Bool] = new_property(
  "org.eclipse.elk.mrtree.compaction", false,
)

///|
pub let mrtree_search_order : IProperty[String] = new_property(
  "org.eclipse.elk.mrtree.searchOrder", "DFS",
)

///|
pub let mrtree_edge_end_texture_length : IProperty[Double] = new_property(
  "org.eclipse.elk.mrtree.edgeEndTextureLength", 7.0,
)

///|
pub let mrtree_tree_level : IProperty[Int] = new_property(
  "org.eclipse.elk.mrtree.treeLevel", 0,
)

///|
pub let mrtree_position_constraint : IProperty[Int] = new_property(
  "org.eclipse.elk.mrtree.positionConstraint", -1,
)

///|
pub let mrtree_padding : IProperty[String] = padding

///|
pub let mrtree_spacing_node_node : IProperty[Double] = spacing_node_node

///|
pub let mrtree_aspect_ratio : IProperty[Double] = aspect_ratio

///|
pub let mrtree_priority : IProperty[Double] = priority

///|
pub let mrtree_omit_node_micro_layout : IProperty[Bool] = omit_node_micro_layout
