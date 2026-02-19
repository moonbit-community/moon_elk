///|
fn mrtree_untreeifyer_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Untreeify", 1.0))

  for edge in mrtree_graph_removable_edges(graph) {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    mrtree_node_add_outgoing_edge(source, edge)
    mrtree_node_add_incoming_edge(target, edge)
  }

  monitor.done()
}

///|
pub fn new_mrtree_untreeifyer_layout_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_untreeifyer_process)
}
