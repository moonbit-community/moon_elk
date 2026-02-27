///|
fn interactive_node_placer_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn interactive_node_placer_graph_has_external_ports(graph : LGraph) -> Bool {
  for
    property in graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    match property {
      GraphProperties::ExternalPorts => return true
      _ => ()
    }
  }
  false
}

///|
fn interactive_node_placer_place_nodes(
  layer : Layer,
  spacings : Spacings,
) -> Unit raise LayeredSpacingsException {
  let mut min_valid_y = @double.neg_infinity
  let mut prev_node_type = NodeType::Normal

  for node in layer.get_nodes() {
    let node_type = node.get_type()

    if !interactive_node_placer_node_type_is_normal(node_type) {
      if node.has_property_double(
          internal_properties_original_dummy_node_position,
        ) {
        node.get_position().y = node.get_property_double(
          internal_properties_original_dummy_node_position,
        )
      } else {
        if min_valid_y < 0.0 {
          min_valid_y = 0.0
        }
        node.get_position().y = min_valid_y +
          spacings.get_vertical_spacing_for_node_type(node_type, prev_node_type)
      }
    }

    let spacing = spacings.get_vertical_spacing_for_node_type(
      node_type, prev_node_type,
    )
    if node.get_position().y < min_valid_y + spacing + node.get_margin().top {
      node.get_position().y = min_valid_y + spacing + node.get_margin().top
    }

    min_valid_y = node.get_position().y +
      node.get_size().y +
      node.get_margin().bottom
    prev_node_type = node_type
  }
}

///|
fn interactive_node_placer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Interactive node placement", 1.0))

  let spacings = new_layered_spacings(layered_graph)
  try {
    for layer in layered_graph.get_layers() {
      interactive_node_placer_place_nodes(layer, spacings)
    }
  } catch {
    LayeredSpacingsException(message) =>
      @core.layout_runtime_report_unsupported_configuration(message)
  }

  monitor.done()
}

///|
pub fn new_interactive_node_placer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(interactive_node_placer_process, graph => {
    if interactive_node_placer_graph_has_external_ports(graph) {
      return Some(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::HierarchicalPortPositionProcessor,
          ),
        ),
      )
    }
    None
  })
}
