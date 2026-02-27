///|
priv struct HyperedgeDummyMergerMergeState {
  allow_merge : Bool
  same_source : Bool
  same_target : Bool
}

///|
fn hyperedge_dummy_merger_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn hyperedge_dummy_merger_lport_equals(left : LPort, right : LPort) -> Bool {
  lport_internal_handle(left) == lport_internal_handle(right)
}

///|
fn hyperedge_dummy_merger_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  @core.layout_runtime_report_unsupported_configuration("unknown port side")
  @core.PortSide::SideUndefined
}

///|
fn hyperedge_dummy_merger_require_port_on_side(
  node : LNode,
  side_name : String,
) -> LPort {
  let ports = node.get_ports_by_side(
    hyperedge_dummy_merger_port_side(side_name),
  )
  if ports.is_empty() {
    @core.layout_runtime_report_unsupported_configuration(
      "missing required port side",
    )
    return new_l_port()
  }
  ports[0]
}

///|
fn hyperedge_dummy_merger_check_merge_allowed(
  curr_node : LNode,
  last_node : LNode,
) -> HyperedgeDummyMergerMergeState {
  let curr_has_label_dummies = curr_node.get_property_bool(
    internal_properties_long_edge_has_label_dummies,
  )
  let last_has_label_dummies = last_node.get_property_bool(
    internal_properties_long_edge_has_label_dummies,
  )

  let curr_source = curr_node.get_property_l_port(
    internal_properties_long_edge_source,
  )
  let last_source = last_node.get_property_l_port(
    internal_properties_long_edge_source,
  )
  let curr_target = curr_node.get_property_l_port(
    internal_properties_long_edge_target,
  )
  let last_target = last_node.get_property_l_port(
    internal_properties_long_edge_target,
  )

  let same_source = match (curr_source, last_source) {
    (Some(curr), Some(last)) => hyperedge_dummy_merger_lport_equals(curr, last)
    _ => false
  }
  let same_target = match (curr_target, last_target) {
    (Some(curr), Some(last)) => hyperedge_dummy_merger_lport_equals(curr, last)
    _ => false
  }

  if !curr_has_label_dummies && !last_has_label_dummies {
    let curr_ports = curr_node.get_ports()
    let last_ports = last_node.get_ports()
    let allow_merge = if curr_ports.is_empty() || last_ports.is_empty() {
      false
    } else {
      curr_ports[0].get_id() == last_ports[0].get_id()
    }
    return { allow_merge, same_source, same_target }
  }

  let eligible_for_source_merging = (
      !curr_has_label_dummies ||
      curr_node.get_property_bool(
        internal_properties_long_edge_before_label_dummy,
      )
    ) &&
    (
      !last_has_label_dummies ||
      last_node.get_property_bool(
        internal_properties_long_edge_before_label_dummy,
      )
    )

  let eligible_for_target_merging = (
      !curr_has_label_dummies ||
      !curr_node.get_property_bool(
        internal_properties_long_edge_before_label_dummy,
      )
    ) &&
    (
      !last_has_label_dummies ||
      !last_node.get_property_bool(
        internal_properties_long_edge_before_label_dummy,
      )
    )

  {
    allow_merge: (same_source && eligible_for_source_merging) ||
    (same_target && eligible_for_target_merging),
    same_source,
    same_target,
  }
}

///|
fn hyperedge_dummy_merger_merge_nodes(
  merge_source : LNode,
  merge_target : LNode,
  keep_source_port : Bool,
  keep_target_port : Bool,
) -> Unit {
  let merge_target_input_port = hyperedge_dummy_merger_require_port_on_side(
    merge_target, "WEST",
  )
  let merge_target_output_port = hyperedge_dummy_merger_require_port_on_side(
    merge_target, "EAST",
  )

  for port in merge_source.get_ports() {
    while !port.get_incoming_edges().is_empty() {
      port.get_incoming_edges()[0].set_target(Some(merge_target_input_port))
    }
    while !port.get_outgoing_edges().is_empty() {
      port.get_outgoing_edges()[0].set_source(Some(merge_target_output_port))
    }
  }

  if !keep_source_port {
    merge_target.set_property_l_port(internal_properties_long_edge_source, None)
  }
  if !keep_target_port {
    merge_target.set_property_l_port(internal_properties_long_edge_target, None)
  }
}

///|
fn hyperedge_dummy_merger_dfs(port : LPort, index : Int) -> Unit {
  port.set_id(index)

  for connected in port.get_connected_ports() {
    if connected.get_id() == -1 {
      hyperedge_dummy_merger_dfs(connected, index)
    }
  }

  match port.get_node() {
    Some(node) =>
      if hyperedge_dummy_merger_node_type_is_long_edge(node.get_type()) {
        for sibling in node.get_ports() {
          if !hyperedge_dummy_merger_lport_equals(sibling, port) &&
            sibling.get_id() == -1 {
            hyperedge_dummy_merger_dfs(sibling, index)
          }
        }
      }
    None => ()
  }
}

///|
fn hyperedge_dummy_merger_identify_hyperedges(graph : LGraph) -> Unit {
  let ports = []
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      for port in node.get_ports() {
        ports.push(port)
      }
    }
  }

  for port in ports {
    port.set_id(-1)
  }

  let mut index = 0
  for port in ports {
    if port.get_id() == -1 {
      hyperedge_dummy_merger_dfs(port, index)
      index = index + 1
    }
  }
}

///|
fn hyperedge_dummy_merger_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Hyperedge merging", 1.0))

  hyperedge_dummy_merger_identify_hyperedges(layered_graph)

  for layer in layered_graph.get_layers() {
    let nodes = layer.get_nodes()
    if nodes.is_empty() {
      continue
    }

    let mut last_node : LNode? = None
    let mut node_index = 0
    while node_index < nodes.length() {
      let curr_node = nodes[node_index]
      let mut removed = false

      if hyperedge_dummy_merger_node_type_is_long_edge(curr_node.get_type()) {
        match last_node {
          Some(last) =>
            if hyperedge_dummy_merger_node_type_is_long_edge(last.get_type()) {
              let state = hyperedge_dummy_merger_check_merge_allowed(
                curr_node, last,
              )
              if state.allow_merge {
                hyperedge_dummy_merger_merge_nodes(
                  curr_node,
                  last,
                  state.same_source,
                  state.same_target,
                )
                ignore(nodes.remove(node_index))
                removed = true
              }
            }
          None => ()
        }
      }

      if removed {
        continue
      }
      last_node = Some(curr_node)
      node_index = node_index + 1
    }
  }

  monitor.done()
}

///|
pub fn new_hyperedge_dummy_merger_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(hyperedge_dummy_merger_process)
}
