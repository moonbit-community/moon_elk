///|
pub let graphviz_option_adapt_port_positions : IProperty[Bool] = new_property(
  "org.eclipse.elk.graphviz.adaptPortPositions", true,
)

///|
pub let graphviz_option_concentrate : IProperty[Bool] = new_property(
  "org.eclipse.elk.graphviz.concentrate", false,
)

///|
pub let graphviz_option_epsilon : IProperty[Double] = new_property(
  "org.eclipse.elk.graphviz.epsilon", 0.0,
)

///|
pub let graphviz_option_iterations_factor : IProperty[Double] = new_property(
  "org.eclipse.elk.graphviz.iterationsFactor", 1.0,
)

///|
pub let graphviz_option_label_angle : IProperty[Double] = new_property(
  "org.eclipse.elk.graphviz.labelAngle", -25.0,
)

///|
pub let graphviz_option_label_distance : IProperty[Double] = new_property(
  "org.eclipse.elk.graphviz.labelDistance", 1.0,
)

///|
pub let graphviz_option_layer_spacing_factor : IProperty[Double] = new_property(
  "org.eclipse.elk.graphviz.layerSpacingFactor", 1.0,
)

///|
pub let graphviz_option_maxiter : IProperty[Int] = new_property(
  "org.eclipse.elk.graphviz.maxiter", 0,
)

///|
pub let graphviz_option_neato_model : IProperty[String] = new_property(
  "org.eclipse.elk.graphviz.neatoModel", "SHORTPATH",
)

///|
pub let graphviz_option_overlap_mode : IProperty[String] = new_property(
  "org.eclipse.elk.graphviz.overlapMode", "PRISM",
)

///|
pub let graphviz_core_option_hierarchy_handling : IProperty[String] = new_property(
  "org.eclipse.elk.hierarchyHandling", "INHERIT",
)

///|
pub let graphviz_core_option_interactive : IProperty[Bool] = new_property(
  "org.eclipse.elk.interactive", false,
)

///|
pub let graphviz_core_option_edge_routing : IProperty[String] = new_property(
  "org.eclipse.elk.edgeRouting", "SPLINES",
)

///|
pub let graphviz_core_option_random_seed : IProperty[Int] = new_property(
  "org.eclipse.elk.randomSeed", 1,
)

///|
pub let graphviz_core_option_separate_connected_components : IProperty[Bool] = new_property(
  "org.eclipse.elk.separateConnectedComponents", false,
)
