///|
fn hierarchical_port_position_parse_port_constraints(
  value : String,
) -> PortConstraints {
  for constraints in port_constraints_values() {
    if port_constraints_to_string(constraints) == value {
      return constraints
    }
  }
  PortConstraints::Undefined
}

///|
fn hierarchical_port_position_port_constraints_equals(
  left : PortConstraints,
  right : PortConstraints,
) -> Bool {
  match (left, right) {
    (PortConstraints::Undefined, PortConstraints::Undefined) => true
    (PortConstraints::Free, PortConstraints::Free) => true
    (PortConstraints::FixedSide, PortConstraints::FixedSide) => true
    (PortConstraints::FixedOrder, PortConstraints::FixedOrder) => true
    (PortConstraints::FixedRatio, PortConstraints::FixedRatio) => true
    (PortConstraints::FixedPos, PortConstraints::FixedPos) => true
    _ => false
  }
}

///|
fn hierarchical_port_position_node_type_is_external_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn hierarchical_port_position_side_is_east_or_west(side : PortSide) -> Bool {
  match side {
    PortSide::East => true
    PortSide::West => true
    _ => false
  }
}

///|
fn hierarchical_port_position_fix_coordinates(
  layer : Layer,
  layered_graph : LGraph,
) -> Unit {
  let port_constraints = hierarchical_port_position_parse_port_constraints(
    layered_graph.get_property_string(port_constraints),
  )
  if !(port_constraints.is_ratio_fixed() || port_constraints.is_pos_fixed()) {
    return
  }

  let graph_height = layered_graph.get_size().y

  for node in layer.get_nodes() {
    if !hierarchical_port_position_node_type_is_external_port(node.get_type()) {
      continue
    }

    let side = node.get_property_port_side(internal_properties_ext_port_side)
    if !hierarchical_port_position_side_is_east_or_west(side) {
      continue
    }

    let mut final_y = node.get_property_double(
      internal_properties_port_ratio_or_position,
    )
    if hierarchical_port_position_port_constraints_equals(
        port_constraints,
        PortConstraints::FixedRatio,
      ) {
      final_y = final_y * graph_height
    }

    let anchor = node.get_property_kvector(layered_options_port_anchor)
    node.get_position().y = final_y - anchor.y
  }
}

///|
fn hierarchical_port_position_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Hierarchical port position processing", 1.0))

  let layers = layered_graph.get_layers()
  if !layers.is_empty() {
    hierarchical_port_position_fix_coordinates(layers[0], layered_graph)
  }
  if layers.length() > 1 {
    hierarchical_port_position_fix_coordinates(
      layers[layers.length() - 1],
      layered_graph,
    )
  }

  monitor.done()
}

///|
pub fn new_hierarchical_port_position_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(hierarchical_port_position_process)
}
