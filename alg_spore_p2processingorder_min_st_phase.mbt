///|
fn spore_min_st_phase_configuration(
  graph : SporeGraph,
) -> LayoutProcessorConfiguration[SPOrEPhases, SporeGraph]? {
  ignore(graph)
  Some(layout_processor_configuration_create(spore_phase_descriptor))
}

///|
priv struct SporeKVectorNodeEntry {
  vector : KVector
  node : Node
}

///|
fn spore_kvector_node_find(
  entries : Array[SporeKVectorNodeEntry],
  vector : KVector,
) -> Node? {
  for entry in entries {
    if entry.vector.equals(vector) {
      return Some(entry.node)
    }
  }
  None
}

///|
fn spore_min_st_add_node(
  node_map : Array[SporeKVectorNodeEntry],
  target : Tree[Node],
  source : Tree[KVector],
) -> Unit {
  for child in source.children {
    let mapped = match spore_kvector_node_find(node_map, child.node) {
      Some(node) => node
      None => continue
    }
    let converted = new_tree(mapped)
    target.children.push(converted)
    spore_min_st_add_node(node_map, converted, child)
  }
}

///|
pub fn spore_min_st_convert(tree : Tree[KVector], graph : SporeGraph) -> Unit {
  let node_map : Array[SporeKVectorNodeEntry] = []
  for node in graph.vertices {
    node_map.push({ vector: node.original_vertex, node })
  }
  let root = match spore_kvector_node_find(node_map, tree.node) {
    Some(node) => new_tree(node)
    None => return
  }
  spore_min_st_add_node(node_map, root, tree)
  graph.tree = Some(root)
}

///|
fn spore_min_st_phase_process(
  graph : SporeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Minimum spanning tree construction", 1.0))

  if graph.vertices.is_empty() {
    graph.tree = None
    monitor.done()
    return
  }

  let root = match graph.preferred_root {
    Some(node) => node.original_vertex
    None => graph.vertices[0].original_vertex
  }
  let edges = match graph.t_edges {
    Some(value) => value
    None => []
  }

  let tree = naive_minst_create_spanning_tree(
    edges,
    root,
    graph.cost_function,
    debug_output_file=if graph.debug_svg { Some("spore_20minst") } else { None },
  )
  spore_min_st_convert(tree, graph)

  monitor.done()
}

///|
pub fn new_spore_min_st_layout_phase() -> ILayoutProcessor[
  SPOrEPhases,
  SporeGraph,
] {
  new_layout_phase(spore_min_st_phase_process, spore_min_st_phase_configuration)
}
