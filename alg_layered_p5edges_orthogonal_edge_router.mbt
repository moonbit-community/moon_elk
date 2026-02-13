///|
fn orthogonal_edge_router_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
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
  properties : Array[GraphProperties],
  property : GraphProperties,
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
  left : PortSide,
  right : PortSide,
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
fn orthogonal_edge_router_is_external_west_or_east_port(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::ExternalPort => ()
    _ => return false
  }

  let ext_port_side = node.get_property_port_side(
    internal_properties_ext_port_side,
  )
  orthogonal_edge_router_port_side_equals(ext_port_side, PortSide::West) ||
  orthogonal_edge_router_port_side_equals(ext_port_side, PortSide::East)
}

///|
fn orthogonal_edge_router_all_external_west_or_east_ports(
  nodes : Array[LNode]?,
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
  layer : Layer,
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
    let alignment_value = node.get_property_string(alignment)
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
let orthogonal_edge_router_hyperedge_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor).add_before(
  LayeredPhases::P4NodePlacement,
  layered_intermediate_processor_factory(
    IntermediateProcessorStrategy::HyperedgeDummyMerger,
  ),
)

///|
let orthogonal_edge_router_inverted_port_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor).add_before(
  LayeredPhases::P3NodeOrdering,
  layered_intermediate_processor_factory(
    IntermediateProcessorStrategy::InvertedPortProcessor,
  ),
)

///|
let orthogonal_edge_router_north_south_port_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::NorthSouthPortPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::NorthSouthPortPostprocessor,
    ),
  )

///|
let orthogonal_edge_router_hierarchical_port_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::HierarchicalPortConstraintProcessor,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::HierarchicalPortDummySizeProcessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::HierarchicalPortOrthogonalEdgeRouter,
    ),
  )

///|
let orthogonal_edge_router_self_loop_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPostprocessor,
    ),
  )
  .before(LayeredPhases::P4NodePlacement)
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPortRestorer,
    ),
  )
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopRouter,
    ),
  )

///|
let orthogonal_edge_router_hypernode_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor).add_after(
  LayeredPhases::P5EdgeRouting,
  layered_intermediate_processor_factory(
    IntermediateProcessorStrategy::HypernodeProcessor,
  ),
)

///|
let orthogonal_edge_router_center_edge_label_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P2Layering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummyInserter,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummySwitcher,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelSideSelector,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummyRemover,
    ),
  )

///|
let orthogonal_edge_router_end_edge_label_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelSideSelector,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EndLabelPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EndLabelPostprocessor,
    ),
  )

///|
fn orthogonal_edge_router_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  let graph_properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )

  let configuration = layout_processor_configuration_create(
    layered_phase_descriptor,
  )

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      Hyperedges,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_hyperedge_processing_additions,
      ),
    )
    ignore(
      configuration.add_all(
        orthogonal_edge_router_inverted_port_processing_additions,
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      NonFreePorts,
    ) ||
    graph.get_property_bool(layered_options_feedback_edges) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_inverted_port_processing_additions,
      ),
    )

    if orthogonal_edge_router_graph_properties_contain(
        graph_properties,
        NorthSouthPorts,
      ) {
      ignore(
        configuration.add_all(
          orthogonal_edge_router_north_south_port_processing_additions,
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
        orthogonal_edge_router_hierarchical_port_processing_additions,
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      SelfLoops,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_self_loop_processing_additions,
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      Hypernodes,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_hypernode_processing_additions,
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      CenterLabels,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_center_edge_label_processing_additions,
      ),
    )
  }

  if orthogonal_edge_router_graph_properties_contain(
      graph_properties,
      EndLabels,
    ) {
    ignore(
      configuration.add_all(
        orthogonal_edge_router_end_edge_label_processing_additions,
      ),
    )
  }

  Some(configuration)
}

///|
fn orthogonal_edge_router_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  let actual_monitor = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Orthogonal edge routing", 1.0))

  let node_node_spacing = layered_graph.get_property_double(
    layered_options_spacing_node_node_between_layers,
  )
  let edge_edge_spacing = layered_graph.get_property_double(
    layered_options_spacing_edge_edge_between_layers,
  )
  let edge_node_spacing = layered_graph.get_property_double(
    layered_options_spacing_edge_node_between_layers,
  )

  let routing_generator = new_orthogonal_routing_generator(
    WestToEast,
    edge_edge_spacing,
    Some("phase5"),
  )

  let mut xpos = 0.0
  let layers = layered_graph.get_layers()
  let mut next_layer_index = 0

  let mut left_layer : Layer? = None
  let mut left_layer_nodes : Array[LNode]? = None
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
pub fn new_orthogonal_edge_router_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    orthogonal_edge_router_process, orthogonal_edge_router_configuration,
  )
}
