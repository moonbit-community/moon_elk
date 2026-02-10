///|
pub let disco_spacing_component_component : IProperty[Double] = spacing_component_component

///|
pub let disco_edge_thickness : IProperty[Double] = new_property(
  "org.eclipse.elk.edge.thickness", 1.0,
)

///|
pub let disco_aspect_ratio : IProperty[Double] = aspect_ratio

///|
pub let disco_padding : IProperty[String] = padding

///|
pub let disco_polyomino_fill : IProperty[Bool] = new_property(
  "org.eclipse.elk.alg.common.compaction.polyomino.fill", false,
)

///|
pub let disco_component_compaction_strategy : IProperty[String] = new_property(
  "org.eclipse.elk.disco.componentCompaction.strategy", "POLYOMINO",
)

///|
pub let disco_component_layout_algorithm : IProperty[String] = new_property(
  "org.eclipse.elk.disco.componentCompaction.componentLayoutAlgorithm", "",
)
