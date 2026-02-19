///|
fn reversed_edge_restorer_reverse_edge(edge : LEdge) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
fn reversed_edge_restorer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Restoring reversed edges", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      for port in node.get_ports() {
        let outgoing_edges = port.get_outgoing_edges().copy()
        for edge in outgoing_edges {
          if edge.get_property_bool(internal_properties_reversed) {
            reversed_edge_restorer_reverse_edge(edge)
          }
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_reversed_edge_restorer_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(reversed_edge_restorer_process)
}
