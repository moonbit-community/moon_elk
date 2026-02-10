///|
fn mrtree_untreeifyer_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Detreeifying phase", 1.0))
    None => ()
  }

  for edge in mrtree_graph_removable_edges(graph) {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    mrtree_node_add_outgoing_edge_unique(source, edge)
    mrtree_node_add_incoming_edge_unique(target, edge)
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_untreeifyer_layout_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_untreeifyer_process)
}
