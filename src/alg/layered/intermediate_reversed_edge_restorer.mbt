///|
fn reversed_edge_restorer_reverse_edge(
  edge : LEdge,
  layered_graph : LGraph,
) -> Unit {
  edge.reverse(layered_graph, false)
}

///|
fn reversed_edge_restorer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Restoring reversed edges", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      for port in node.get_ports() {
        let outgoing_edges = port.get_outgoing_edges().copy()
        for edge in outgoing_edges {
          if edge.get_property_bool(internal_properties_reversed) {
            reversed_edge_restorer_reverse_edge(edge, layered_graph)
          }
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_reversed_edge_restorer_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(reversed_edge_restorer_process)
}
