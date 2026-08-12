///|
let nodespacing_port_index_property : @graph.IProperty[Int] = @graph.new_property(
  "org.eclipse.elk.port.index", -1,
)

///|
let nodespacing_topdown_layout_property : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.topdownLayout", false,
)

///|
let nodespacing_node_labels_padding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
let nodespacing_port_labels_placement_property : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.portLabels.placement",
  ["OUTSIDE"],
)

///|
let nodespacing_ports_surrounding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spacing.portsSurrounding", "[top=0,left=0,bottom=0,right=0]",
)

///|
let nodespacing_alignment_default_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.default", "DISTRIBUTED",
)

///|
let nodespacing_alignment_north_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.north", "",
)

///|
let nodespacing_alignment_south_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.south", "",
)

///|
let nodespacing_alignment_east_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.east", "",
)

///|
let nodespacing_alignment_west_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.west", "",
)

///|
let nodespacing_port_border_offset_property : @graph.IProperty[Double] = @graph.new_property(
  "org.eclipse.elk.port.borderOffset", 0.0,
)

///|
let nodespacing_port_ratio_or_position_property : @graph.IProperty[Double] = @graph.new_property(
  "portRatioOrPosition", 0.0,
)

///|
fn nodespacing_capture_elk_label(
  label : @core.ElkLabelAdapter,
) -> NodeSpacingLabel {
  {
    size: label.get_size().clone(),
    position: label.get_position().clone(),
    edge_placement: label.get_property_string(@core.edge_labels_placement),
    has_node_placement: label.has_property_string_array(
      @core.node_labels_placement,
    ),
    node_placement: label.get_property_string_array(@core.node_labels_placement),
  }
}

///|
fn nodespacing_capture_elk_labels(
  labels : Array[@core.ElkLabelAdapter],
) -> Array[NodeSpacingLabel] {
  [
    for label in labels => nodespacing_capture_elk_label(label)
  ]
}

///|
fn nodespacing_capture_elk_edge(edge : @core.ElkEdgeAdapter) -> NodeSpacingEdge {
  { labels: nodespacing_capture_elk_labels(edge.get_labels()) }
}

///|
fn nodespacing_capture_elk_edges(
  edges : Array[@core.ElkEdgeAdapter],
) -> Array[NodeSpacingEdge] {
  [
    for edge in edges => nodespacing_capture_elk_edge(edge)
  ]
}

///|
fn nodespacing_capture_elk_port(
  port : @core.ElkPortAdapter,
  source_index : Int,
) -> NodeSpacingPort {
  {
    source_index,
    size: port.get_size().clone(),
    position: port.get_position().clone(),
    side: port.get_side(),
    labels: nodespacing_capture_elk_labels(port.get_labels()),
    incoming_edges: nodespacing_capture_elk_edges(port.get_incoming_edges()),
    outgoing_edges: nodespacing_capture_elk_edges(port.get_outgoing_edges()),
    has_compound_connections: port.has_compound_connections(),
    has_border_offset: port.has_property_double(
      nodespacing_port_border_offset_property,
    ),
    border_offset: port.get_property_double(
      nodespacing_port_border_offset_property,
    ),
    has_ratio_or_position: port.has_property_double(
      nodespacing_port_ratio_or_position_property,
    ),
    ratio_or_position: port.get_property_double(
      nodespacing_port_ratio_or_position_property,
    ),
    sort_index: if port.has_property_int(nodespacing_port_index_property) {
      Some(port.get_property_int(nodespacing_port_index_property))
    } else {
      None
    },
    volatile_id: port.get_volatile_id(),
  }
}

///|
fn nodespacing_capture_elk_node(
  graph : @core.ElkGraphAdapter,
  node : @core.ElkNodeAdapter,
  source_index : Int,
) -> NodeSpacingNode raise {
  let ports = node.get_ports()
  {
    source_index,
    size: node.get_size().clone(),
    position: node.get_position().clone(),
    labels: nodespacing_capture_elk_labels(node.get_labels()),
    ports: [
      for index, port in ports => nodespacing_capture_elk_port(port, index)
    ],
    incoming_edges: nodespacing_capture_elk_edges(node.get_incoming_edges()),
    outgoing_edges: nodespacing_capture_elk_edges(node.get_outgoing_edges()),
    sort_ports: node_context_parse_port_constraints(
      node.get_property_string(@core.port_constraints),
    ).is_order_fixed(),
    compound_node: node.is_compound_node(),
    graph_fixed_size: graph.get_property_bool(@core.node_size_fixed_graph_size),
    topdown_layout: node.get_property_bool(nodespacing_topdown_layout_property),
    inside_self_loops_activate: node.get_property_bool(
      @core.inside_self_loops_activate,
    ),
    size_constraints: node.get_property_string_array(
      @core.node_size_constraints,
    ),
    size_options: node.get_property_string_array(@core.node_size_options),
    port_constraints: node.get_property_string(@core.port_constraints),
    port_labels_placement: node.get_property_string_array(
      nodespacing_port_labels_placement_property,
    ),
    port_labels_treat_as_group: node.get_property_bool(
      @core.port_labels_treat_as_group,
    ),
    node_labels_placement: node.get_property_string_array(
      @core.node_labels_placement,
    ),
    node_labels_padding: node.get_property_string(
      nodespacing_node_labels_padding_property,
    ),
    spacing_label_node: @core.individual_spacings_get_individual_or_inherited(
      node.get_node(),
      @core.spacing_label_node,
    ),
    spacing_label_label: @core.individual_spacings_get_individual_or_inherited(
      node.get_node(),
      @core.spacing_label_label,
    ),
    spacing_port_port: @core.individual_spacings_get_individual_or_inherited(
      node.get_node(),
      @core.spacing_port_port,
    ),
    spacing_label_port_horizontal: @core.individual_spacings_get_individual_or_inherited(
      node.get_node(),
      @core.spacing_label_port_horizontal,
    ),
    spacing_label_port_vertical: @core.individual_spacings_get_individual_or_inherited(
      node.get_node(),
      @core.spacing_label_port_vertical,
    ),
    spacing_ports_surrounding: node.get_property_string(
      nodespacing_ports_surrounding_property,
    ),
    alignment_default: node.get_property_string(
      nodespacing_alignment_default_property,
    ),
    alignment_north: if node.has_property_string(
        nodespacing_alignment_north_property,
      ) {
      Some(node.get_property_string(nodespacing_alignment_north_property))
    } else {
      None
    },
    alignment_south: if node.has_property_string(
        nodespacing_alignment_south_property,
      ) {
      Some(node.get_property_string(nodespacing_alignment_south_property))
    } else {
      None
    },
    alignment_east: if node.has_property_string(
        nodespacing_alignment_east_property,
      ) {
      Some(node.get_property_string(nodespacing_alignment_east_property))
    } else {
      None
    },
    alignment_west: if node.has_property_string(
        nodespacing_alignment_west_property,
      ) {
      Some(node.get_property_string(nodespacing_alignment_west_property))
    } else {
      None
    },
    minimum_size: node.get_property_string(@core.node_size_minimum),
    padding: node.get_padding(),
    margin: @core.new_elk_margin_copy(node.get_margin()),
  }
}

///|
fn capture_elk_node_spacing_input(
  adapter : @core.ElkGraphAdapter,
) -> NodeSpacingInput raise {
  let nodes = adapter.get_nodes()
  {
    direction: adapter.get_property_string(@core.direction),
    spacing_label_node: adapter.get_property_double(@core.spacing_label_node),
    nodes: [
      for index, node in nodes => {
        nodespacing_capture_elk_node(adapter, node, index)
      }
    ],
  }
}

///|
fn capture_elk_single_node_spacing_input(
  adapter : @core.ElkGraphAdapter,
  node : @core.ElkNodeAdapter,
  source_index : Int,
) -> NodeSpacingInput raise {
  {
    direction: adapter.get_property_string(@core.direction),
    spacing_label_node: adapter.get_property_double(@core.spacing_label_node),
    nodes: [nodespacing_capture_elk_node(adapter, node, source_index)],
  }
}

///|
fn capture_elk_node_spacing_node(
  node : @graph.ElkNode,
) -> NodeSpacingNode raise {
  let graph = match @graph.node_parent(node) {
    Some(parent) => parent
    None => node
  }
  nodespacing_capture_elk_node(
    @core.adapt(graph),
    @core.adapt_single_node(node),
    0,
  )
}

///|
fn nodespacing_apply_elk_label_positions(
  labels : Array[@core.ElkLabelAdapter],
  positions : Array[@core.KVector],
) -> Unit {
  for index, position in positions {
    labels[index].set_position(position)
  }
}

///|
fn apply_elk_node_spacing_output(
  adapter : @core.ElkGraphAdapter,
  output : NodeSpacingOutput,
) -> Unit {
  let nodes = adapter.get_nodes()
  for node_output in output.nodes {
    let node = nodes[node_output.source_index]
    node.set_size(node_output.size)
    node.set_padding(node_output.padding)
    node.set_margin(node_output.margin)
    nodespacing_apply_elk_label_positions(
      node.get_labels(),
      node_output.label_positions,
    )
    let ports = node.get_ports()
    for port_output in node_output.ports {
      let port = ports[port_output.source_index]
      port.set_position(port_output.position)
      port.set_volatile_id(port_output.volatile_id)
      nodespacing_apply_elk_label_positions(
        port.get_labels(),
        port_output.label_positions,
      )
    }
    let graph_ports = @graph.node_ports(node.get_node())
    let original_ports = graph_ports.copy()
    for index, source_index in node_output.port_order {
      graph_ports[index] = original_ports[source_index]
    }
  }
  // Cached bindings are stale after port reordering and belong to this codec
  // invocation, so release them at the apply boundary.
  adapter.child_nodes = None
}
