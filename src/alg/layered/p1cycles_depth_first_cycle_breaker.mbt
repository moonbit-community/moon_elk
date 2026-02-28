///|
pub(all) suberror DepthFirstCycleBreakerException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] depth_first_cycle_breaker_raise_unsupported_graph(
  message : String,
) -> T raise DepthFirstCycleBreakerException {
  raise DepthFirstCycleBreakerException::UnsupportedGraphException(message)
}

///|
fn depth_first_cycle_breaker_require_target_node(
  edge : LEdge,
) -> LNode raise DepthFirstCycleBreakerException {
  let target = match edge.get_target() {
    Some(value) => value
    None =>
      depth_first_cycle_breaker_raise_unsupported_graph(
        "edge has no target port",
      )
  }
  match target.get_node() {
    Some(node) => node
    None =>
      depth_first_cycle_breaker_raise_unsupported_graph(
        "target port has no owner node",
      )
  }
}

///|
fn depth_first_cycle_breaker_reverse_edge(edge : LEdge, graph : LGraph) -> Unit {
  edge.reverse(graph, true)
}

///|
fn depth_first_cycle_breaker_dfs(
  node : LNode,
  visited : Array[Bool],
  active : Array[Bool],
  edges_to_be_reversed : Array[LEdge],
) -> Unit raise DepthFirstCycleBreakerException {
  let node_id = node.get_id()
  if visited[node_id] {
    return
  }

  visited[node_id] = true
  active[node_id] = true

  for edge in node.get_outgoing_edges() {
    if edge.is_self_loop() {
      continue
    }

    let target = depth_first_cycle_breaker_require_target_node(edge)
    let target_id = target.get_id()

    if active[target_id] {
      edges_to_be_reversed.push(edge)
    } else {
      depth_first_cycle_breaker_dfs(
        target, visited, active, edges_to_be_reversed,
      )
    }
  }

  active[node_id] = false
}

///|
fn depth_first_cycle_breaker_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Depth-first cycle removal", 1.0))

  let nodes = graph.get_layerless_nodes()
  let node_count = nodes.length()
  let visited = Array::make(node_count, false)
  let active = Array::make(node_count, false)
  let edges_to_be_reversed = []
  let sources = []

  for i = 0; i < node_count; i = i + 1 {
    let node = nodes[i]
    node.set_id(i)
    if node.get_incoming_edges().is_empty() {
      sources.push(node)
    }
  }

  try {
    for source in sources {
      depth_first_cycle_breaker_dfs(
        source, visited, active, edges_to_be_reversed,
      )
    }

    for i = 0; i < node_count; i = i + 1 {
      if !visited[i] {
        depth_first_cycle_breaker_dfs(
          nodes[i],
          visited,
          active,
          edges_to_be_reversed,
        )
      }
    }

    for edge in edges_to_be_reversed {
      depth_first_cycle_breaker_reverse_edge(edge, graph)
      graph.set_property_bool(internal_properties_cyclic, true)
    }
  } catch {
    DepthFirstCycleBreakerException::UnsupportedGraphException(message) => {
      @core.layout_runtime_report_unsupported_configuration(message)
      monitor.done()
      return
    }
  } noraise {
    _ => ()
  }

  monitor.done()
}

///|
fn depth_first_cycle_breaker_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(layered_phase_descriptor).add_after(
      LayeredPhases::P5EdgeRouting,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::ReversedEdgeRestorer,
      ),
    ),
  )
}

///|
pub fn new_depth_first_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    depth_first_cycle_breaker_process, depth_first_cycle_breaker_configuration,
  )
}
