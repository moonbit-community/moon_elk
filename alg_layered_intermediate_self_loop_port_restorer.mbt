///|
fn self_loop_port_restorer_port_constraints_from_string(
  name : String,
) -> PortConstraints {
  match name {
    "FREE" => PortConstraints::Free
    "FIXED_SIDE" => PortConstraints::FixedSide
    "FIXED_ORDER" => PortConstraints::FixedOrder
    "FIXED_RATIO" => PortConstraints::FixedRatio
    "FIXED_POS" => PortConstraints::FixedPos
    _ => PortConstraints::Undefined
  }
}

///|
fn self_loop_port_restorer_compute_self_loop_types(
  sl_holder : SelfLoopHolder,
) -> Unit {
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    sl_loop.compute_ports_per_side()
  }
}

///|
fn self_loop_port_restorer_port_constraints_is_free_or_undefined(
  constraints : PortConstraints,
) -> Bool {
  match constraints {
    PortConstraints::Undefined => true
    PortConstraints::Free => true
    _ => false
  }
}

///|
fn self_loop_port_restorer_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn self_loop_port_restorer_process_node(
  sl_holder : SelfLoopHolder,
  monitor : IElkProgressMonitor?,
) -> Unit {
  let port_side_assigner = new_port_side_assigner()
  let port_restorer = new_port_restorer()

  if sl_holder.are_ports_hidden() {
    let constraints = self_loop_port_restorer_port_constraints_from_string(
      sl_holder
      .get_l_node()
      .get_property_string(internal_properties_original_port_constraints),
    )

    if constraints.is_side_fixed() {
      self_loop_port_restorer_compute_self_loop_types(sl_holder)
      port_restorer.restore_ports(sl_holder, monitor)
      return
    }

    if self_loop_port_restorer_port_constraints_is_free_or_undefined(
        constraints,
      ) {
      port_side_assigner.assign_port_sides(sl_holder)
      self_loop_port_restorer_compute_self_loop_types(sl_holder)
      port_restorer.restore_ports(sl_holder, monitor)
    }
  } else {
    self_loop_port_restorer_compute_self_loop_types(sl_holder)
  }
}

///|
fn self_loop_port_restorer_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Self-Loop ordering", 1.0))

  for layer in graph.get_layers() {
    for l_node in layer.get_nodes() {
      if !self_loop_port_restorer_node_type_is_normal(l_node.get_type()) {
        continue
      }
      if !l_node.has_property_self_loop_holder(
          internal_properties_self_loop_holder,
        ) {
        continue
      }

      match
        l_node.get_property_self_loop_holder(
          internal_properties_self_loop_holder,
        ) {
        Some(sl_holder) =>
          self_loop_port_restorer_process_node(sl_holder, Some(monitor))
        None => ()
      }
    }
  }

  monitor.done()
}

///|
pub fn new_self_loop_port_restorer_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(self_loop_port_restorer_process)
}
