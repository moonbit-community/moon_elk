///|
fn spore_max_st_phase_configuration(
  graph : SporeGraph,
) -> LayoutProcessorConfiguration[SPOrEPhases, SporeGraph]? {
  ignore(graph)
  Some(layout_processor_configuration_create(spore_phase_descriptor))
}

///|
fn spore_max_st_phase_process(
  graph : SporeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Maximum spanning tree construction", 1.0))

  if graph.vertices.is_empty() {
    graph.tree = None
    monitor.done()
    return
  }

  let inverted_cost_function : ICostFunction = edge => {
    -(graph.cost_function)(edge)
  }
  let root = match graph.preferred_root {
    Some(node) => node.vertex
    None => graph.vertices[0].vertex
  }
  let edges = match graph.t_edges {
    Some(value) => value
    None => []
  }
  let tree = naive_minst_create_spanning_tree(
    edges,
    root,
    inverted_cost_function,
    debug_output_file=if graph.debug_svg { Some("spore_20minst") } else { None },
  )
  spore_min_st_convert(tree, graph)

  monitor.done()
}

///|
pub fn new_spore_max_st_layout_phase() -> ILayoutProcessor[
  SPOrEPhases,
  SporeGraph,
] {
  new_layout_phase(spore_max_st_phase_process, spore_max_st_phase_configuration)
}
