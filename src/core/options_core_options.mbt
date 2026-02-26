///|
pub let spacing_component_component : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.componentComponent", 20.0,
)

///|
pub let spacing_edge_edge : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.edgeEdge", 10.0,
)

///|
pub let spacing_edge_label : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.edgeLabel", 2.0,
)

///|
pub let spacing_edge_node : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.edgeNode", 10.0,
)

///|
pub let spacing_label_label : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.labelLabel", 0.0,
)

///|
pub let spacing_label_node : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.labelNode", 5.0,
)

///|
pub let spacing_label_port_horizontal : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.labelPortHorizontal", 1.0,
)

///|
pub let spacing_label_port_vertical : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.labelPortVertical", 1.0,
)

///|
pub let spacing_node_node : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.nodeNode", 20.0,
)

///|
pub let spacing_node_self_loop : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.nodeSelfLoop", 10.0,
)

///|
pub let spacing_port_port : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.spacing.portPort", 10.0,
)

///|
pub let aspect_ratio : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.aspectRatio", 0.0,
)

///|
pub let random_seed : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.randomSeed", 1,
)

///|
pub let content_alignment : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.contentAlignment",
  ["V_TOP", "H_LEFT"],
)

///|
pub let alignment : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.alignment", "AUTOMATIC",
)

///|
pub let port_labels_next_to_port_if_possible : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.portLabelsNextToPortIfPossible", false,
)

///|
pub let port_labels_placement : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.portLabels.placement",
  [],
)

///|
pub let port_labels_treat_as_group : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.portLabels.treatAsGroup", true,
)

///|
pub let node_labels_placement : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.placement",
  [],
)

///|
pub let port_constraints : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portConstraints", "UNDEFINED",
)

///|
pub let edge_labels_placement : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.edgeLabels.placement", "CENTER",
)

///|
pub let edge_labels_inline : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.edgeLabels.inline", false,
)

///|
pub let edge_routing : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.edgeRouting", "UNDEFINED",
)

///|
pub let edge_thickness : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.edge.thickness", 1.0,
)

///|
pub let port_side : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.port.side", "UNDEFINED",
)

///|
pub let padding : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.padding", "[left=12, top=12, right=12, bottom=12]",
)

///|
pub let priority : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.priority", 0.0,
)

///|
pub let node_size_options : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.nodeSize.options",
  ["DEFAULT_MINIMUM_SIZE"],
)

///|
pub let node_size_constraints : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.nodeSize.constraints",
  [],
)

///|
pub let node_size_minimum : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeSize.minimum", "(0.0, 0.0)",
)

///|
pub let node_size_fixed_graph_size : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.nodeSize.fixedGraphSize", false,
)

///|
pub let child_area_width : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.childAreaWidth", 0.0,
)

///|
pub let child_area_height : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.childAreaHeight", 0.0,
)

///|
pub let topdown_size_categories : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.topdown.sizeCategories", 3,
)

///|
pub let topdown_size_categories_hierarchical_node_weight : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.topdown.sizeCategoriesHierarchicalNodeWeight", 4,
)

///|
pub let topdown_size_approximator : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.topdown.sizeApproximator", "",
)

///|
pub let topdown_hierarchical_node_width : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.topdown.hierarchicalNodeWidth", 150.0,
)

///|
pub let topdown_hierarchical_node_aspect_ratio : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.topdown.hierarchicalNodeAspectRatio", 1.414,
)

///|
pub let algorithm : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.algorithm", "",
)

///|
pub let interactive : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.interactive", false,
)

///|
pub let box_packing_mode : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.box.packingMode", "SIMPLE",
)

///|
pub let direction : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.direction", "",
)

///|
pub let resolved_algorithm : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.resolvedAlgorithm", "",
)

///|
pub let no_layout : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.noLayout", false,
)

///|
pub let omit_node_micro_layout : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.omitNodeMicroLayout", false,
)

///|
pub let expand_nodes : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.expandNodes", false,
)

///|
pub let inside_self_loops_activate : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.insideSelfLoops.activate", false,
)
