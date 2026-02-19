///|
fn constraints_postprocessor_node_type_equals(
  left : NodeType,
  right : NodeType,
) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn constraints_postprocessor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Constraints Postprocessor", 1.0))

  let mut layer_index = 0
  for layer in graph.get_layers() {
    let mut pos_index = 0
    let mut node_layer = false
    for current_node in layer.get_nodes() {
      if constraints_postprocessor_node_type_equals(
          current_node.get_type(),
          NodeType::Normal,
        ) {
        node_layer = true
        current_node.set_property_int(
          layered_options_layering_layer_id, layer_index,
        )
        current_node.set_property_int(
          layered_options_crossing_minimization_position_id, pos_index,
        )
        pos_index = pos_index + 1
      }
    }
    if node_layer {
      layer_index = layer_index + 1
    }
  }

  monitor.done()
}

///|
pub fn new_constraints_postprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(constraints_postprocessor_process)
}
