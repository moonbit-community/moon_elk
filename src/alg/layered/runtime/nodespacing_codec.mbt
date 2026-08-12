///|
let nodespacing_topdown_layout : @graph.IProperty[Bool] = @graph.new_property(
  "org.eclipse.elk.topdownLayout", false,
)

///|
let nodespacing_node_labels_padding : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
let nodespacing_port_labels_placement : @graph.IProperty[Array[String]] = @graph.new_property(
  "org.eclipse.elk.portLabels.placement",
  ["OUTSIDE"],
)

///|
let nodespacing_ports_surrounding : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.spacing.portsSurrounding", "[top=0,left=0,bottom=0,right=0]",
)

///|
let nodespacing_alignment_default : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.default", "DISTRIBUTED",
)

///|
let nodespacing_alignment_north : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.north", "",
)

///|
let nodespacing_alignment_south : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.south", "",
)

///|
let nodespacing_alignment_east : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.east", "",
)

///|
let nodespacing_alignment_west : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.portAlignment.west", "",
)

///|
fn nodespacing_layered_nodes(adapter : LGraphAdapter) -> Array[LNodeAdapter] {
  // Layerless graphs are used while a layered graph is still being prepared.
  // Preserve the former adapter traversal at this model boundary.
  if adapter.element.get_layers().is_empty() {
    let nodes = []
    for node in adapter.element.get_layerless_nodes() {
      if node.get_type() is Normal && (adapter.node_filter)(node) {
        nodes.push(
          new_l_node_adapter(
            Some(adapter),
            node,
            adapter.transparent_north_south_edges,
            state=adapter.state,
          ),
        )
      }
    }
    adapter.node_adapters = Some(nodes)
    nodes
  } else {
    adapter.get_nodes()
  }
}

///|
fn nodespacing_capture_layered_label(
  label : LLabelAdapter,
) -> @nodespacing.NodeSpacingLabel {
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
fn nodespacing_capture_layered_labels(
  labels : Array[LLabelAdapter],
) -> Array[@nodespacing.NodeSpacingLabel] {
  [
    for label in labels => nodespacing_capture_layered_label(label)
  ]
}

///|
fn nodespacing_capture_layered_edge(
  edge : LEdgeAdapter,
) -> @nodespacing.NodeSpacingEdge {
  { labels: nodespacing_capture_layered_labels(edge.get_labels()) }
}

///|
fn nodespacing_capture_layered_edges(
  edges : Array[LEdgeAdapter],
) -> Array[@nodespacing.NodeSpacingEdge] {
  [
    for edge in edges => nodespacing_capture_layered_edge(edge)
  ]
}

///|
fn nodespacing_capture_layered_port(
  port : LPortAdapter,
  source_index : Int,
) -> @nodespacing.NodeSpacingPort {
  {
    source_index,
    size: port.get_size().clone(),
    position: port.get_position().clone(),
    side: port.get_side(),
    labels: nodespacing_capture_layered_labels(port.get_labels()),
    incoming_edges: nodespacing_capture_layered_edges(port.get_incoming_edges()),
    outgoing_edges: nodespacing_capture_layered_edges(port.get_outgoing_edges()),
    has_compound_connections: port.has_compound_connections(),
    has_border_offset: port.has_property_double(
      @options.layered_options_port_border_offset,
    ),
    border_offset: port.get_property_double(
      @options.layered_options_port_border_offset,
    ),
    has_ratio_or_position: port.has_property_double(
      internal_properties_port_ratio_or_position,
    ),
    ratio_or_position: port.get_property_double(
      internal_properties_port_ratio_or_position,
    ),
    sort_index: if port.has_property_int(@options.layered_options_port_index) {
      Some(port.get_property_int(@options.layered_options_port_index))
    } else {
      None
    },
    volatile_id: port.get_volatile_id(),
  }
}

///|
fn nodespacing_optional_string(
  node : LNodeAdapter,
  property : @graph.IProperty[String],
) -> String? {
  if node.has_property_string(property) {
    Some(node.get_property_string(property))
  } else {
    None
  }
}

///|
fn nodespacing_capture_layered_node(
  graph : LGraphAdapter,
  node : LNodeAdapter,
  source_index : Int,
) -> @nodespacing.NodeSpacingNode {
  let ports = node.get_ports()
  {
    source_index,
    size: node.get_size().clone(),
    position: node.get_position().clone(),
    labels: nodespacing_capture_layered_labels(node.get_labels()),
    ports: [
      for index, port in ports => nodespacing_capture_layered_port(port, index)
    ],
    incoming_edges: nodespacing_capture_layered_edges(node.get_incoming_edges()),
    outgoing_edges: nodespacing_capture_layered_edges(node.get_outgoing_edges()),
    sort_ports: l_graph_adapters_port_constraints_from_string(
      node.get_property_string(@core.port_constraints),
    ).is_order_fixed(),
    compound_node: node.is_compound_node(),
    graph_fixed_size: graph.get_property_bool(@core.node_size_fixed_graph_size),
    topdown_layout: node.get_property_bool(nodespacing_topdown_layout),
    inside_self_loops_activate: node.get_property_bool(
      @core.inside_self_loops_activate,
    ),
    size_constraints: node.get_property_string_array(
      @core.node_size_constraints,
    ),
    size_options: node.get_property_string_array(@core.node_size_options),
    port_constraints: node.get_property_string(@core.port_constraints),
    port_labels_placement: node.get_property_string_array(
      nodespacing_port_labels_placement,
    ),
    port_labels_treat_as_group: node.get_property_bool(
      @core.port_labels_treat_as_group,
    ),
    node_labels_placement: node.get_property_string_array(
      @core.node_labels_placement,
    ),
    node_labels_padding: node.get_property_string(
      nodespacing_node_labels_padding,
    ),
    spacing_label_node: layered_spacings_get_individual_or_default(
      node.get_node(),
      @core.spacing_label_node,
    ),
    spacing_label_label: layered_spacings_get_individual_or_default(
      node.get_node(),
      @core.spacing_label_label,
    ),
    spacing_port_port: layered_spacings_get_individual_or_default(
      node.get_node(),
      @core.spacing_port_port,
    ),
    spacing_label_port_horizontal: layered_spacings_get_individual_or_default(
      node.get_node(),
      @core.spacing_label_port_horizontal,
    ),
    spacing_label_port_vertical: layered_spacings_get_individual_or_default(
      node.get_node(),
      @core.spacing_label_port_vertical,
    ),
    spacing_ports_surrounding: node.get_property_string(
      nodespacing_ports_surrounding,
    ),
    alignment_default: node.get_property_string(nodespacing_alignment_default),
    alignment_north: nodespacing_optional_string(
      node, nodespacing_alignment_north,
    ),
    alignment_south: nodespacing_optional_string(
      node, nodespacing_alignment_south,
    ),
    alignment_east: nodespacing_optional_string(
      node, nodespacing_alignment_east,
    ),
    alignment_west: nodespacing_optional_string(
      node, nodespacing_alignment_west,
    ),
    minimum_size: node.get_property_string(@core.node_size_minimum),
    padding: node.get_padding(),
    margin: node.get_margin(),
  }
}

///|
pub fn capture_l_node_spacing_input(
  adapter : LGraphAdapter,
) -> @nodespacing.NodeSpacingInput {
  let nodes = nodespacing_layered_nodes(adapter)
  {
    direction: adapter.get_property_string(@core.direction),
    spacing_label_node: adapter.get_property_double(@core.spacing_label_node),
    nodes: [
      for index, node in nodes => {
        nodespacing_capture_layered_node(adapter, node, index)
      }
    ],
  }
}

///|
fn nodespacing_apply_layered_label_positions(
  labels : Array[LLabelAdapter],
  positions : Array[@core.KVector],
) -> Unit {
  for index, position in positions {
    labels[index].set_position(position)
  }
}

///|
fn nodespacing_apply_layered_node_output(
  node : LNodeAdapter,
  output : @nodespacing.NodeSpacingNodeOutput,
) -> Unit {
  node.set_size(output.size)
  node.set_padding(output.padding)
  node.set_margin(output.margin)
  nodespacing_apply_layered_label_positions(
    node.get_labels(),
    output.label_positions,
  )
  let ports = node.get_ports()
  for port_output in output.ports {
    let port = ports[port_output.source_index]
    port.set_position(port_output.position)
    port.set_volatile_id(port_output.volatile_id)
    nodespacing_apply_layered_label_positions(
      port.get_labels(),
      port_output.label_positions,
    )
  }
  let source_ports = node.get_node().get_ports().copy()
  let target_ports = node.get_node().get_ports()
  target_ports.clear()
  for source_index in output.port_order {
    target_ports.push(source_ports[source_index])
  }
}

///|
pub fn apply_l_node_spacing_output(
  adapter : LGraphAdapter,
  output : @nodespacing.NodeSpacingOutput,
) -> Unit {
  let nodes = nodespacing_layered_nodes(adapter)
  for node_output in output.nodes {
    nodespacing_apply_layered_node_output(
      nodes[node_output.source_index],
      node_output,
    )
  }
  // Adapter caches retain model objects and represent stale array ordering
  // after apply, so their lifetime ends at this explicit codec boundary.
  adapter.cleanup()
}

///|
pub fn calculate_l_node_margin(graph : LGraph, node : LNode) -> Unit {
  let graph_adapter = adapt_l_graph(graph)
  let node_adapter = new_l_node_adapter(Some(graph_adapter), node, false)
  let input : @nodespacing.NodeSpacingInput = {
    direction: graph_adapter.get_property_string(@core.direction),
    spacing_label_node: graph_adapter.get_property_double(
      @core.spacing_label_node,
    ),
    nodes: [nodespacing_capture_layered_node(graph_adapter, node_adapter, 0)],
  }
  let calculator = @nodespacing.node_dimension_calculation_get_node_margin_calculator_for_input(
    input,
  )
  calculator.process_node(input.nodes[0])
  nodespacing_apply_layered_node_output(node_adapter, input.output().nodes[0])
  graph_adapter.cleanup()
}
