///|
fn port_side_processor_port_constraints_from_string(
  value : String,
) -> PortConstraints {
  match value {
    "UNDEFINED" => PortConstraints::Undefined
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn port_side_processor_process_node(node : LNode) -> Unit {
  let constraints_value = if node.has_property_string(port_constraints) {
    node.get_property_string(port_constraints)
  } else {
    port_constraints.get_default()
  }
  let constraints = port_side_processor_port_constraints_from_string(
    constraints_value,
  )

  if constraints.is_side_fixed() {
    for port in node.get_ports() {
      match port.get_side() {
        PortSide::SideUndefined => port_side_processor_set_port_side(port)
        _ => ()
      }
    }
  } else {
    for port in node.get_ports() {
      port_side_processor_set_port_side(port)
    }
    node.set_property_string(port_constraints, "FIXED_SIDE")
  }
}

///|
pub fn port_side_processor_set_port_side(port : LPort) -> Unit {
  match port.get_property_l_node(internal_properties_port_dummy) {
    Some(port_dummy) => {
      let resolved_side = port_dummy.get_property_port_side(
        internal_properties_ext_port_side,
      )
      port.set_side(resolved_side)
    }
    None =>
      if port.get_net_flow() < 0 {
        port.set_side(PortSide::East)
      } else {
        port.set_side(PortSide::West)
      }
  }
}

///|
fn port_side_processor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Port side processing", 1.0))

  for node in layered_graph.get_layerless_nodes() {
    port_side_processor_process_node(node)
  }

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      port_side_processor_process_node(node)
    }
  }

  monitor.done()
}

///|
pub fn new_port_side_processor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(port_side_processor_process)
}
