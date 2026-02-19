///|
pub let spore_compaction_algorithm_id = "org.eclipse.elk.sporeCompaction"

///|
pub let spore_overlap_removal_algorithm_id = "org.eclipse.elk.sporeOverlap"

///|
pub let spore_underlying_layout_algorithm : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.underlyingLayoutAlgorithm", "",
)

///|
pub let spore_structure_extraction_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.structureExtractionStrategy", "DELAUNAY_TRIANGULATION",
)

///|
pub let spore_processing_order_tree_construction : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.treeConstruction", "MINIMUM_SPANNING_TREE",
)

///|
pub let spore_processing_order_spanning_tree_cost_function : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.spanningTreeCostFunction", "CIRCLE_UNDERLAP",
)

///|
pub let spore_processing_order_preferred_root : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.preferredRoot", "",
)

///|
pub let spore_processing_order_root_selection : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.rootSelection", "CENTER_NODE",
)

///|
pub let spore_compaction_compaction_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spore.compactionStrategy", "DEPTH_FIRST",
)

///|
pub let spore_compaction_orthogonal : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.spore.orthogonal", false,
)

///|
pub let spore_debug_mode : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.debugMode", false,
)

///|
pub let spore_padding : @graph.IProperty[String] = @core.padding

///|
pub let spore_spacing_node_node : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.nodeNode", 8.0,
)

///|
pub let spore_overlap_removal_max_iterations : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spore.maxIterations", 64.0,
)

///|
pub let spore_overlap_removal_run_scanline : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.spore.runScanline", true,
)
