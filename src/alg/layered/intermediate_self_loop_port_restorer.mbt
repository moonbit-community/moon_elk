///|
fn self_loop_port_restorer_port_constraints_from_string(
  name : String,
) -> @core.PortConstraints {
  match name {
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn self_loop_port_restorer_compute_self_loop_types(
  sl_holder : SelfLoopHolder,
) -> Unit raise SelfLoopTypeException {
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    sl_loop.compute_ports_per_side()
  }
}

///|
fn self_loop_port_restorer_port_constraints_is_free_or_undefined(
  constraints : @core.PortConstraints,
) -> Bool {
  match constraints {
    @core.PortConstraints::Undefined => true
    @core.PortConstraints::Free => true
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
  monitor : @core.IElkProgressMonitor?,
) -> Unit raise SelfLoopTypeException {
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
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
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
          self_loop_port_restorer_process_node(sl_holder, Some(monitor)) catch {
            SelfLoopTypeException::IllegalArgumentException(message) => {
              @core.layout_runtime_report_unsupported_configuration(message)
              monitor.done()
              return
            }
          }
        None => ()
      }
    }
  }

  monitor.done()
}

///|
pub fn new_self_loop_port_restorer_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(self_loop_port_restorer_process)
}
