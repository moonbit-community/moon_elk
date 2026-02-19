///|
pub let spore_compaction_algorithm_id = "org.eclipse.elk.sporeCompaction"

///|
pub let spore_overlap_removal_algorithm_id = "org.eclipse.elk.sporeOverlap"

///|
pub let spore_underlying_layout_algorithm : IProperty[String] = new_property(
  "org.eclipse.elk.underlyingLayoutAlgorithm", "",
)

///|
pub let spore_structure_extraction_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.spore.structureExtractionStrategy", "DELAUNAY_TRIANGULATION",
)

///|
pub let spore_processing_order_tree_construction : IProperty[String] = new_property(
  "org.eclipse.elk.spore.treeConstruction", "MINIMUM_SPANNING_TREE",
)

///|
pub let spore_processing_order_spanning_tree_cost_function : IProperty[String] = new_property(
  "org.eclipse.elk.spore.spanningTreeCostFunction", "CIRCLE_UNDERLAP",
)

///|
pub let spore_processing_order_preferred_root : IProperty[String] = new_property(
  "org.eclipse.elk.spore.preferredRoot", "",
)

///|
pub let spore_processing_order_root_selection : IProperty[String] = new_property(
  "org.eclipse.elk.spore.rootSelection", "CENTER_NODE",
)

///|
pub let spore_compaction_compaction_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.spore.compactionStrategy", "DEPTH_FIRST",
)

///|
pub let spore_compaction_orthogonal : IProperty[Bool] = new_property(
  "org.eclipse.elk.spore.orthogonal", false,
)

///|
pub let spore_debug_mode : IProperty[Bool] = new_property(
  "org.eclipse.elk.debugMode", false,
)

///|
pub let spore_padding : IProperty[String] = padding

///|
pub let spore_spacing_node_node : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.nodeNode", 8.0,
)

///|
pub let spore_overlap_removal_max_iterations : IProperty[Double] = new_property(
  "org.eclipse.elk.spore.maxIterations", 64.0,
)

///|
pub let spore_overlap_removal_run_scanline : IProperty[Bool] = new_property(
  "org.eclipse.elk.spore.runScanline", true,
)
