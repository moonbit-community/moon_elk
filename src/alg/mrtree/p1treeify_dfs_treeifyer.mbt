///|
fn mrtree_dfs_treeifyer_configuration(
  graph : MrtreeGraph,
) -> @core.LayoutProcessorConfiguration[MrtreeTreeLayoutPhases, MrtreeGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(
      mrtree_tree_layout_phase_descriptor,
    ).add_after(
      MrtreeTreeLayoutPhases::P3NodePlacement,
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::DetreeifyingProc,
      ),
    ),
  )
}

///|
fn mrtree_dfs_treeifyer_init(graph : MrtreeGraph) -> Array[Int] {
  let nodes = mrtree_graph_nodes(graph)
  let size = nodes.length()
  let visited = []
  for _ in 0..<size {
    visited.push(0)
  }
  let mut id = 0
  for node in nodes {
    mrtree_node_set_id(node, id)
    id += 1
  }
  visited
}

///|
fn mrtree_dfs_treeifyer_dfs(
  node : MrtreeNode,
  visited : Array[Int],
  eliminated : Array[MrtreeEdge],
) -> Unit {
  visited[mrtree_node_id(node)] = 1
  for edge in mrtree_node_outgoing_edges(node) {
    let target = mrtree_edge_target(edge)
    let target_id = mrtree_node_id(target)
    if visited[target_id] == 1 {
      eliminated.push(edge)
    } else if visited[target_id] == 2 {
      visited[target_id] = 1
    } else {
      mrtree_dfs_treeifyer_dfs(target, visited, eliminated)
    }
  }
}

///|
fn mrtree_dfs_treeifyer_bfs(
  start_node : MrtreeNode,
  visited : Array[Int],
  eliminated : Array[MrtreeEdge],
) -> Unit {
  let queue = [start_node]
  let mut head = 0
  while head < queue.length() {
    let node = queue[head]
    head += 1
    visited[mrtree_node_id(node)] = 1
    for edge in mrtree_node_outgoing_edges(node) {
      let target = mrtree_edge_target(edge)
      let target_id = mrtree_node_id(target)
      if visited[target_id] == 1 {
        eliminated.push(edge)
      } else if visited[target_id] == 2 {
        visited[target_id] = 1
      } else {
        queue.push(target)
      }
    }
  }
}

///|
fn mrtree_dfs_treeifyer_collect_edges(
  graph : MrtreeGraph,
  visited : Array[Int],
) -> Array[MrtreeEdge] {
  let eliminated = []
  let treeifying_order = mrtree_graph_search_order(graph)
  for node in mrtree_graph_nodes(graph) {
    let node_id = mrtree_node_id(node)
    if visited[node_id] == 0 {
      match treeifying_order {
        MrtreeTreeifyingOrder::DFS =>
          mrtree_dfs_treeifyer_dfs(node, visited, eliminated)
        MrtreeTreeifyingOrder::BFS =>
          mrtree_dfs_treeifyer_bfs(node, visited, eliminated)
      }
      visited[node_id] = 2
    }
  }
  for edge in eliminated {
    let source = mrtree_edge_source(edge)
    let target = mrtree_edge_target(edge)
    mrtree_node_remove_outgoing_edge(source, edge)
    mrtree_node_remove_incoming_edge(target, edge)
  }
  eliminated
}

///|
fn mrtree_dfs_treeifyer_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("DFS Treeifying phase", 1.0))
    None => ()
  }

  let visited = mrtree_dfs_treeifyer_init(graph)
  let eliminated = mrtree_dfs_treeifyer_collect_edges(graph, visited)
  mrtree_graph_set_removable_edges(graph, eliminated)

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_dfs_treeifyer_layout_phase() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_phase(
    mrtree_dfs_treeifyer_process, mrtree_dfs_treeifyer_configuration,
  )
}
