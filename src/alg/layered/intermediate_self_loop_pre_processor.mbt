///|
fn self_loop_preprocessor_port_constraints_from_string(
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
fn self_loop_preprocessor_graph_property_eq(
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
fn self_loop_preprocessor_has_external_ports(graph : LGraph) -> Bool {
  let graph_properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  for property in graph_properties {
    if self_loop_preprocessor_graph_property_eq(property, ExternalPorts) {
      return true
    }
  }
  false
}

///|
fn self_loop_preprocessor_hide_self_loop(l_edge : LEdge) -> Unit {
  l_edge.set_source(None)
  l_edge.set_target(None)
}

///|
fn self_loop_preprocessor_hide_self_loops(sl_holder : SelfLoopHolder) -> Unit {
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    for sl_edge in sl_loop.get_sl_edges() {
      self_loop_preprocessor_hide_self_loop(sl_edge.get_l_edge())
    }
  }
}

///|
fn self_loop_preprocessor_hide_ports(sl_holder : SelfLoopHolder) -> Unit {
  let l_node = sl_holder.get_l_node()
  let nested_graph = l_node.get_nested_graph()

  let constraints_value = if l_node.has_property_string(@core.port_constraints) {
    l_node.get_property_string(@core.port_constraints)
  } else {
    "UNDEFINED"
  }
  let order_fixed = self_loop_preprocessor_port_constraints_from_string(
    constraints_value,
  ).is_order_fixed()
  let hierarchy_mode = match nested_graph {
    Some(graph) => self_loop_preprocessor_has_external_ports(graph)
    None => false
  }

  if order_fixed || hierarchy_mode {
    return
  }

  for entry in sl_holder.get_sl_port_map().to_array() {
    let (_, sl_port) = entry
    if !sl_port.had_only_self_loops() {
      continue
    }

    let l_port = sl_port.get_l_port()
    l_port.set_node(None)

    sl_port.set_hidden(true)
    sl_holder.set_ports_hidden(true)

    if l_port.get_property_l_node(internal_properties_port_dummy) is Some(_) {
      abort("self loop preprocessor should not encounter PORT_DUMMY here")
    }
  }
}

///|
fn self_loop_pre_processor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Self-Loop pre-processing", 1.0))

  for l_node in graph.get_layerless_nodes() {
    if !self_loop_holder_needs_self_loop_processing(l_node) {
      continue
    }

    let sl_holder = self_loop_holder_install(l_node)
    self_loop_preprocessor_hide_self_loops(sl_holder)
    self_loop_preprocessor_hide_ports(sl_holder)
  }

  monitor.done()
}

///|
pub fn new_self_loop_pre_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(self_loop_pre_processor_process)
}
