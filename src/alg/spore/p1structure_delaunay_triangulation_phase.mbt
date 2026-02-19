///|
fn spore_delaunay_phase_configuration(
  graph : SporeGraph,
) -> @core.LayoutProcessorConfiguration[SPOrEPhases, SporeGraph]? {
  ignore(graph)
  Some(@core.layout_processor_configuration_create(spore_phase_descriptor))
}

///|
fn spore_append_tedge_unique(
  edges : Array[@common.TEdge],
  edge : @common.TEdge,
) -> Unit {
  for existing in edges {
    if existing.equals(edge) {
      return
    }
  }
  edges.push(edge)
}

///|
fn spore_delaunay_triangulation_phase_process(
  graph : SporeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Delaunay triangulation", 1.0))

  let vertices : Array[@core.KVector] = []
  for vertex in graph.vertices {
    vertices.push(vertex.original_vertex)
  }

  let debug_output = if graph.debug_svg { Some("spore_10bw") } else { None }

  let triangulation = @common.bowyer_watson_triangulate(
    vertices,
    debug_output_file=debug_output,
  )
  match graph.t_edges {
    Some(existing_edges) =>
      for edge in triangulation {
        spore_append_tedge_unique(existing_edges, edge)
      }
    None => graph.t_edges = Some(triangulation)
  }

  monitor.done()
}

///|
pub fn new_spore_delaunay_triangulation_layout_phase() -> @core.ILayoutProcessor[
  SPOrEPhases,
  SporeGraph,
] {
  @core.new_layout_phase(
    spore_delaunay_triangulation_phase_process, spore_delaunay_phase_configuration,
  )
}
