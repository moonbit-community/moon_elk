///|
fn orthogonal_edge_router_graph_property_equals(
  left : @options.GraphProperties,
  right : @options.GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn orthogonal_edge_router_graph_properties_contain(
  properties : Array[@options.GraphProperties],
  property : @options.GraphProperties,
) -> Bool {
  for candidate in properties {
    if orthogonal_edge_router_graph_property_equals(candidate, property) {
      return true
    }
  }
  false
}

///|
fn orthogonal_edge_router_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (SideUndefined, SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn orthogonal_edge_router_is_external_west_or_east_port(
  node : @runtime.LNode,
) -> Bool {
  match node.get_type() {
    ExternalPort => ()
    _ => return false
  }

  let ext_port_side = node.get_property_port_side(
    @runtime.internal_properties_ext_port_side,
  )
  orthogonal_edge_router_port_side_equals(ext_port_side, West) ||
  orthogonal_edge_router_port_side_equals(ext_port_side, East)
}

///|
fn orthogonal_edge_router_all_external_west_or_east_ports(
  nodes : Array[@runtime.LNode]?,
) -> Bool {
  match nodes {
    None => true
    Some(layer_nodes) => {
      for node in layer_nodes {
        if !orthogonal_edge_router_is_external_west_or_east_port(node) {
          return false
        }
      }
      true
    }
  }
}

///|
fn orthogonal_edge_router_place_nodes_horizontally(
  layer : @runtime.Layer,
  xoffset : Double,
) -> Unit {
  let mut max_left_margin = 0.0
  let mut max_right_margin = 0.0
  for node in layer.get_nodes() {
    let margin = node.get_margin()
    if margin.left > max_left_margin {
      max_left_margin = margin.left
    }
    if margin.right > max_right_margin {
      max_right_margin = margin.right
    }
  }

  for node in layer.get_nodes() {
    let alignment_value = node.get_property_string(@core.alignment)
    let ratio = if alignment_value == "LEFT" {
      0.0
    } else if alignment_value == "RIGHT" {
      1.0
    } else if alignment_value == "CENTER" {
      0.5
    } else {
      let mut inports = 0
      let mut outports = 0
      for port in node.get_ports() {
        if !port.get_incoming_edges().is_empty() {
          inports += 1
        }
        if !port.get_outgoing_edges().is_empty() {
          outports += 1
        }
      }

      if inports + outports == 0 {
        0.5
      } else {
        outports.to_double() / (inports + outports).to_double()
      }
    }

    let size = layer.get_size()
    let node_size = node.get_size().x
    let mut xpos = (size.x - node_size) * ratio

    if ratio > 0.5 {
      xpos -= max_right_margin * 2.0 * (ratio - 0.5)
    } else if ratio < 0.5 {
      xpos += max_left_margin * 2.0 * (0.5 - ratio)
    }

    let left_margin = node.get_margin().left
    if xpos < left_margin {
      xpos = left_margin
    }

    let right_margin = node.get_margin().right
    if xpos > size.x - right_margin - node_size {
      xpos = size.x - right_margin - node_size
    }

    node.get_position().x = xoffset + xpos
  }
}

///|
fn orthogonal_edge_router_hyperedge_processing_additions(
  graph : @runtime.LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create().add_before(
    @runtime.P4NodePlacement,
    layered_intermediate_processor_factory(graph, HyperedgeDummyMerger),
  )
}

///|
fn orthogonal_edge_router_inverted_port_processing_additions(
  graph : @runtime.LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create().add_before(
    @runtime.P3NodeOrdering,
    layered_intermediate_processor_factory(graph, InvertedPortProcessor),
  )
}

///|
fn orthogonal_edge_router_north_south_port_processing_additions(
  graph : @runtime.LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    @runtime.P3NodeOrdering,
    layered_intermediate_processor_factory(graph, NorthSouthPortPreprocessor),
  )
  .add_after(
    @runtime.P5EdgeRouting,
    layered_intermediate_processor_factory(graph, NorthSouthPortPostprocessor),
  )
}

///|
fn orthogonal_edge_router_hierarchical_port_processing_additions(
  graph : @runtime.LGraph,
  state : @runtime.LayeredRunState,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    @runtime.P3NodeOrdering,
    layered_intermediate_processor_factory(
      graph,
      HierarchicalPortConstraintProcessor,
    ),
  )
  .add_before(
    @runtime.P4NodePlacement,
    layered_intermediate_processor_factory(
      graph,
      HierarchicalPortDummySizeProcessor,
    ),
  )
  .add_after(
    @runtime.P5EdgeRouting,
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      HierarchicalPortOrthogonalEdgeRouter,
    ),
  )
}

///|
fn orthogonal_edge_router_self_loop_processing_additions(
  graph : @runtime.LGraph,
  state : @runtime.LayeredRunState,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    @runtime.P1CycleBreaking,
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      SelfLoopPreprocessor,
    ),
  )
  .add_after(
    @runtime.P5EdgeRouting,
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      SelfLoopPostprocessor,
    ),
  )
  .before(@runtime.P4NodePlacement)
  .add(
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      SelfLoopPortRestorer,
    ),
  )
  .add(
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      SelfLoopRouter,
    ),
  )
}

///|
fn orthogonal_edge_router_hypernode_processing_additions(
  graph : @runtime.LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create().add_after(
    @runtime.P5EdgeRouting,
    layered_intermediate_processor_factory(graph, HypernodeProcessor),
  )
}

///|
fn orthogonal_edge_router_center_edge_label_processing_additions(
  graph : @runtime.LGraph,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    @runtime.P2Layering,
    layered_intermediate_processor_factory(graph, LabelDummyInserter),
  )
  .add_before(
    @runtime.P4NodePlacement,
    layered_intermediate_processor_factory(graph, LabelDummySwitcher),
  )
  .add_before(
    @runtime.P4NodePlacement,
    layered_intermediate_processor_factory(graph, LabelSideSelector),
  )
  .add_after(
    @runtime.P5EdgeRouting,
    layered_intermediate_processor_factory(graph, LabelDummyRemover),
  )
}

///|
fn orthogonal_edge_router_end_edge_label_processing_additions(
  graph : @runtime.LGraph,
  state : @runtime.LayeredRunState,
) -> @core.LayoutProcessorConfiguration raise {
  @core.layout_processor_configuration_create()
  .add_before(
    @runtime.P4NodePlacement,
    layered_intermediate_processor_factory(graph, LabelSideSelector),
  )
  .add_before(
    @runtime.P4NodePlacement,
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      EndLabelPreprocessor,
    ),
  )
  .add_after(
    @runtime.P5EdgeRouting,
    layered_stateful_intermediate_processor_factory(
      graph,
      state,
      EndLabelPostprocessor,
    ),
  )
}

///|
fn orthogonal_edge_router_configuration(
  graph : @runtime.LGraph,
  state : @runtime.LayeredRunState,
) -> @core.LayoutProcessorConfiguration? raise {
  let graph_properties = graph.get_property_graph_properties_array(
    @runtime.internal_properties_graph_properties,
  )

  let configuration = @core.layout_processor_configuration_create()

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      Hyperedges,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_hyperedge_processing_additions(graph),
      ),
    )
    ignore(
      configuration.add_all(
        orthogonal_edge_router_inverted_port_processing_additions(graph),
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      NonFreePorts,
    ) ||
    graph.get_property_bool(@options.layered_options_feedback_edges) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_inverted_port_processing_additions(graph),
      ),
    )

    if orthogonal_edge_router_graph_properties_contain(
        graph_properties,
        NorthSouthPorts,
      ) {
      ignore(
        configuration.add_all(
          orthogonal_edge_router_north_south_port_processing_additions(graph),
        ),
      )
    }
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      ExternalPorts,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_hierarchical_port_processing_additions(
          graph, state,
        ),
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      SelfLoops,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_self_loop_processing_additions(graph, state),
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      Hypernodes,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_hypernode_processing_additions(graph),
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      CenterLabels,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_center_edge_label_processing_additions(graph),
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      EndLabels,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_end_edge_label_processing_additions(graph, state),
      ),
    )
  }

  Some(configuration)
}

///|
fn orthogonal_edge_router_process(
  layered_graph : @runtime.LGraph,
  monitor : @core.IElkProgressMonitor?,
  state : @runtime.LayeredRunState,
) -> Unit raise {
  let actual_monitor = match monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Orthogonal edge routing", 1.0))

  let node_node_spacing = layered_graph.get_property_double(
    @options.layered_options_spacing_node_node_between_layers,
  )
  let edge_edge_spacing = layered_graph.get_property_double(
    @options.layered_options_spacing_edge_edge_between_layers,
  )
  let edge_node_spacing = layered_graph.get_property_double(
    @options.layered_options_spacing_edge_node_between_layers,
  )

  let routing_generator = new_orthogonal_routing_generator(
    WestToEast,
    edge_edge_spacing,
    Some("phase5"),
    state~,
  )

  let mut xpos = 0.0
  let layers = layered_graph.get_layers()
  let mut next_layer_index = 0

  let mut left_layer : @runtime.Layer? = None
  let mut left_layer_nodes : Array[@runtime.LNode]? = None
  let mut left_layer_index = -1

  while true {
    let right_layer = if next_layer_index < layers.length() {
      let layer = layers[next_layer_index]
      next_layer_index = next_layer_index + 1
      Some(layer)
    } else {
      None
    }
    let right_layer_nodes = match right_layer {
      Some(layer) => Some(layer.get_nodes())
      None => None
    }
    let right_layer_index = next_layer_index - 1

    match left_layer {
      Some(layer) => {
        orthogonal_edge_router_place_nodes_horizontally(layer, xpos)
        xpos += layer.get_size().x
      }
      None => ()
    }

    let start_pos = match left_layer {
      Some(_) => xpos + edge_node_spacing
      None => xpos
    }
    let slots_count = routing_generator.route_edges(
      actual_monitor, layered_graph, left_layer_nodes, left_layer_index, right_layer_nodes,
      start_pos,
    )

    let is_left_layer_external = orthogonal_edge_router_all_external_west_or_east_ports(
      left_layer_nodes,
    )
    let is_right_layer_external = orthogonal_edge_router_all_external_west_or_east_ports(
      right_layer_nodes,
    )

    if slots_count > 0 {
      let mut routing_width = (slots_count - 1).to_double() * edge_edge_spacing

      if left_layer is Some(_) {
        routing_width += edge_node_spacing
      }
      if right_layer is Some(_) {
        routing_width += edge_node_spacing
      }

      if routing_width < node_node_spacing &&
        !is_left_layer_external &&
        !is_right_layer_external {
        routing_width = node_node_spacing
      }
      xpos += routing_width
    } else if !is_left_layer_external && !is_right_layer_external {
      xpos += node_node_spacing
    }

    left_layer = right_layer
    left_layer_nodes = right_layer_nodes
    left_layer_index = right_layer_index

    if right_layer is None {
      break
    }
  }

  layered_graph.get_size().x = xpos
  actual_monitor.done()
}

///|
pub fn new_orthogonal_edge_router_layout_phase(
  state? : @runtime.LayeredRunState = @runtime.new_layered_run_state(),
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  @core.new_layout_phase(
    (graph, monitor) => orthogonal_edge_router_process(graph, monitor, state),
    graph => orthogonal_edge_router_configuration(graph, state),
  )
}
