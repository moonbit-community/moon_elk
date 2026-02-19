///|
pub let disco_spacing_component_component : @graph.IProperty[Double] = @core.spacing_component_component

///|
pub let disco_edge_thickness : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.edge.thickness", 1.0,
)

///|
pub let disco_aspect_ratio : @graph.IProperty[Double] = @core.aspect_ratio

///|
pub let disco_padding : @graph.IProperty[String] = @core.padding

///|
pub let disco_polyomino_fill : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.alg.common.compaction.polyomino.fill", false,
)

///|
pub let disco_component_compaction_strategy : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.disco.componentCompaction.strategy", "POLYOMINO",
)

///|
pub let disco_component_layout_algorithm : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.disco.componentCompaction.componentLayoutAlgorithm", "",
)
