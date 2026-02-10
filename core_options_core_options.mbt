///|
pub let spacing_component_component : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.componentComponent", 20.0,
)

///|
pub let spacing_edge_edge : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.edgeEdge", 10.0,
)

///|
pub let spacing_edge_label : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.edgeLabel", 2.0,
)

///|
pub let spacing_edge_node : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.edgeNode", 10.0,
)

///|
pub let spacing_label_label : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.labelLabel", 0.0,
)

///|
pub let spacing_label_node : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.labelNode", 5.0,
)

///|
pub let spacing_label_port_horizontal : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.labelPortHorizontal", 1.0,
)

///|
pub let spacing_label_port_vertical : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.labelPortVertical", 1.0,
)

///|
pub let spacing_node_node : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.nodeNode", 20.0,
)

///|
pub let spacing_node_self_loop : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.nodeSelfLoop", 10.0,
)

///|
pub let spacing_port_port : IProperty[Double] = new_property(
  "org.eclipse.elk.spacing.portPort", 10.0,
)

///|
pub let aspect_ratio : IProperty[Double] = new_property(
  "org.eclipse.elk.aspectRatio", 0.0,
)

///|
pub let content_alignment : IProperty[Array[String]] = new_property(
  "org.eclipse.elk.contentAlignment",
  ["V_TOP", "H_LEFT"],
)

///|
pub let alignment : IProperty[String] = new_property(
  "org.eclipse.elk.alignment", "AUTOMATIC",
)

///|
pub let port_labels_next_to_port_if_possible : IProperty[Bool] = new_property(
  "org.eclipse.elk.portLabelsNextToPortIfPossible", false,
)

///|
pub let port_labels_placement : IProperty[Array[String]] = new_property(
  "org.eclipse.elk.portLabels.placement",
  [],
)

///|
pub let node_labels_placement : IProperty[Array[String]] = new_property(
  "org.eclipse.elk.nodeLabels.placement",
  [],
)

///|
pub let port_constraints : IProperty[String] = new_property(
  "org.eclipse.elk.portConstraints", "UNDEFINED",
)

///|
pub let port_side : IProperty[String] = new_property(
  "org.eclipse.elk.port.side", "UNDEFINED",
)

///|
pub let padding : IProperty[String] = new_property(
  "org.eclipse.elk.padding", "[left=0, top=0, right=0, bottom=0]",
)

///|
pub let priority : IProperty[Double] = new_property(
  "org.eclipse.elk.priority", 0.0,
)

///|
pub let node_size_options : IProperty[Array[String]] = new_property(
  "org.eclipse.elk.nodeSize.options",
  [],
)

///|
pub let node_size_constraints : IProperty[Array[String]] = new_property(
  "org.eclipse.elk.nodeSize.constraints",
  [],
)

///|
pub let node_size_minimum : IProperty[String] = new_property(
  "org.eclipse.elk.nodeSize.minimum", "(0.0, 0.0)",
)

///|
pub let node_size_fixed_graph_size : IProperty[Bool] = new_property(
  "org.eclipse.elk.nodeSize.fixedGraphSize", false,
)

///|
pub let child_area_width : IProperty[Double] = new_property(
  "org.eclipse.elk.childAreaWidth", 0.0,
)

///|
pub let child_area_height : IProperty[Double] = new_property(
  "org.eclipse.elk.childAreaHeight", 0.0,
)

///|
pub let algorithm : IProperty[String] = new_property(
  "org.eclipse.elk.algorithm", "",
)

///|
pub let direction : IProperty[String] = new_property(
  "org.eclipse.elk.direction", "",
)

///|
pub let resolved_algorithm : IProperty[String] = new_property(
  "org.eclipse.elk.resolvedAlgorithm", "",
)

///|
pub let no_layout : IProperty[Bool] = new_property(
  "org.eclipse.elk.noLayout", false,
)

///|
pub let omit_node_micro_layout : IProperty[Bool] = new_property(
  "org.eclipse.elk.omitNodeMicroLayout", false,
)

///|
pub let expand_nodes : IProperty[Bool] = new_property(
  "org.eclipse.elk.expandNodes", false,
)

///|
pub let inside_self_loops_activate : IProperty[Bool] = new_property(
  "org.eclipse.elk.insideSelfLoops.activate", false,
)
