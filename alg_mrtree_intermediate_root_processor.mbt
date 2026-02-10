///|
fn mrtree_root_processor_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Find roots", 1.0))
    None => ()
  }

  let roots = []
  for node in mrtree_graph_nodes(graph) {
    mrtree_node_set_root(node, false)
    if mrtree_node_incoming_edges(node).is_empty() {
      mrtree_node_set_root(node, true)
      roots.push(node)
    }
  }

  match roots.length() {
    0 =>
      if mrtree_graph_nodes(graph).is_empty() {
        let root = new_mrtree_node(0, graph, label="DUMMY_ROOT")
        mrtree_node_set_root(root, true)
        mrtree_node_set_dummy(root, true)
      }
    1 => ()
    _ => {
      let super_root = new_mrtree_node(0, graph, label="SUPER_ROOT")
      for root in roots {
        ignore(new_mrtree_edge(super_root, root))
        mrtree_node_set_root(root, false)
      }
      mrtree_node_set_root(super_root, true)
      mrtree_node_set_dummy(super_root, true)
    }
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_root_processor_layout_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_root_processor_process)
}
