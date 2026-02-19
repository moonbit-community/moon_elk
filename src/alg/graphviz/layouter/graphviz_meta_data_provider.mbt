///|
pub let graphviz_option_adapt_port_positions : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.graphviz.adaptPortPositions", true,
)

///|
pub let graphviz_option_concentrate : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.graphviz.concentrate", false,
)

///|
pub let graphviz_option_epsilon : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.graphviz.epsilon", 0.0,
)

///|
pub let graphviz_option_iterations_factor : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.graphviz.iterationsFactor", 1.0,
)

///|
pub let graphviz_option_label_angle : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.graphviz.labelAngle", -25.0,
)

///|
pub let graphviz_option_label_distance : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.graphviz.labelDistance", 1.0,
)

///|
pub let graphviz_option_layer_spacing_factor : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.graphviz.layerSpacingFactor", 1.0,
)

///|
pub let graphviz_option_maxiter : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.graphviz.maxiter", 0,
)

///|
pub let graphviz_option_neato_model : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.graphviz.neatoModel", "SHORTPATH",
)

///|
pub let graphviz_option_overlap_mode : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.graphviz.overlapMode", "PRISM",
)

///|
pub let graphviz_core_option_hierarchy_handling : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.hierarchyHandling", "INHERIT",
)

///|
pub let graphviz_core_option_interactive : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.interactive", false,
)

///|
pub let graphviz_core_option_edge_routing : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.edgeRouting", "SPLINES",
)

///|
pub let graphviz_core_option_random_seed : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.randomSeed", 1,
)

///|
pub let graphviz_core_option_separate_connected_components : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.separateConnectedComponents", false,
)
