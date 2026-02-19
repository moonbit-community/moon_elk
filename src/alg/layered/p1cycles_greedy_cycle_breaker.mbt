///|
struct GreedyCycleBreakerState {
  indeg : Array[Int]
  outdeg : Array[Int]
  mark : Array[Int]
  sources : Array[LNode]
  mut source_head : Int
  sinks : Array[LNode]
  mut sink_head : Int
  layered_graph : LGraph
  random : @random.Rand
}

///|
fn greedy_cycle_breaker_require_target_node(edge : LEdge) -> LNode {
  let target = match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
  match target.get_node() {
    Some(node) => node
    None => abort("target port has no owner node")
  }
}

///|
fn greedy_cycle_breaker_reverse_edge(edge : LEdge) -> Unit {
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
fn greedy_cycle_breaker_node_priority_contribution(priority : Int) -> Int {
  if priority > 0 {
    priority + 1
  } else {
    1
  }
}

///|
fn greedy_cycle_breaker_array_clear(values : Array[LNode]) -> Unit {
  values.clear()
}

///|
fn greedy_cycle_breaker_choose_node_with_max_outflow_default(
  nodes : Array[LNode],
  graph : LGraph,
  random : @random.Rand,
) -> LNode {
  ignore(graph)
  let index = random.int(limit=nodes.length())
  nodes[index]
}

///|
fn greedy_cycle_breaker_update_neighbors(
  state : GreedyCycleBreakerState,
  node : LNode,
) -> Unit {
  for port in node.get_ports() {
    for edge in port.get_connected_edges() {
      let source = edge.get_source()
      let target = edge.get_target()
      let connected_port = match (source, target) {
        (Some(source_port), Some(target_port)) =>
          if lport_internal_handle(source_port) == lport_internal_handle(port) {
            target_port
          } else {
            source_port
          }
        _ => continue
      }
      let endpoint = match connected_port.get_node() {
        Some(value) => value
        None => continue
      }

      if lnode_internal_handle(node) == lnode_internal_handle(endpoint) {
        continue
      }

      let mut priority = edge.get_property_int(
        layered_options_priority_direction,
      )
      if priority < 0 {
        priority = 0
      }
      let index = endpoint.get_id()
      if state.mark[index] == 0 {
        let edge_target = match edge.get_target() {
          Some(value) => value
          None => continue
        }
        if lport_internal_handle(edge_target) ==
          lport_internal_handle(connected_port) {
          state.indeg[index] = state.indeg[index] - priority - 1
          if state.indeg[index] <= 0 && state.outdeg[index] > 0 {
            state.sources.push(endpoint)
          }
        } else {
          state.outdeg[index] = state.outdeg[index] - priority - 1
          if state.outdeg[index] <= 0 && state.indeg[index] > 0 {
            state.sinks.push(endpoint)
          }
        }
      }
    }
  }
}

///|
fn greedy_cycle_breaker_collect_and_mark(
  state : GreedyCycleBreakerState,
  choose_node_with_max_outflow : (Array[LNode], LGraph, @random.Rand) -> LNode,
) -> Unit {
  let nodes = state.layered_graph.get_layerless_nodes()
  let mut unprocessed_node_count = nodes.length()
  let mut next_right = -1
  let mut next_left = 1
  let max_nodes = []

  while unprocessed_node_count > 0 {
    while state.sink_head < state.sinks.length() {
      let sink = state.sinks[state.sink_head]
      state.sink_head = state.sink_head + 1
      state.mark[sink.get_id()] = next_right
      next_right = next_right - 1
      greedy_cycle_breaker_update_neighbors(state, sink)
      unprocessed_node_count = unprocessed_node_count - 1
    }

    while state.source_head < state.sources.length() {
      let source = state.sources[state.source_head]
      state.source_head = state.source_head + 1
      state.mark[source.get_id()] = next_left
      next_left = next_left + 1
      greedy_cycle_breaker_update_neighbors(state, source)
      unprocessed_node_count = unprocessed_node_count - 1
    }

    if unprocessed_node_count > 0 {
      let mut max_outflow = -@int.max_value
      greedy_cycle_breaker_array_clear(max_nodes)

      for node in nodes {
        let node_id = node.get_id()
        if state.mark[node_id] == 0 {
          let outflow = state.outdeg[node_id] - state.indeg[node_id]
          if outflow >= max_outflow {
            if outflow > max_outflow {
              greedy_cycle_breaker_array_clear(max_nodes)
              max_outflow = outflow
            }
            max_nodes.push(node)
          }
        }
      }

      if max_nodes.is_empty() {
        abort("no node with maximal outflow found")
      }
      let max_node = choose_node_with_max_outflow(
        max_nodes,
        state.layered_graph,
        state.random,
      )
      state.mark[max_node.get_id()] = next_left
      next_left = next_left + 1
      greedy_cycle_breaker_update_neighbors(state, max_node)
      unprocessed_node_count = unprocessed_node_count - 1
    }
  }
}

///|
fn greedy_cycle_breaker_shift_sink_ranks(
  state : GreedyCycleBreakerState,
) -> Unit {
  let shift_base = state.layered_graph.get_layerless_nodes().length() + 1
  for i = 0; i < state.mark.length(); i = i + 1 {
    if state.mark[i] < 0 {
      state.mark[i] = state.mark[i] + shift_base
    }
  }
}

///|
fn greedy_cycle_breaker_reverse_edges_pointing_left(
  state : GreedyCycleBreakerState,
) -> Unit {
  for node in state.layered_graph.get_layerless_nodes() {
    let node_id = node.get_id()
    for port in node.get_ports() {
      let outgoing_edges = port.get_outgoing_edges().copy()
      for edge in outgoing_edges {
        let target_ix = greedy_cycle_breaker_require_target_node(edge).get_id()
        if state.mark[node_id] > state.mark[target_ix] {
          greedy_cycle_breaker_reverse_edge(edge)
          state.layered_graph.set_property_bool(
            internal_properties_cyclic, true,
          )
        }
      }
    }
  }
}

///|
fn greedy_cycle_breaker_configuration(
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
fn greedy_cycle_breaker_process_with_chooser(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
  choose_node_with_max_outflow : (Array[LNode], LGraph, @random.Rand) -> LNode,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Greedy cycle removal", 1.0))

  let nodes = layered_graph.get_layerless_nodes()
  let state = {
    indeg: Array::make(nodes.length(), 0),
    outdeg: Array::make(nodes.length(), 0),
    mark: Array::make(nodes.length(), 0),
    sources: [],
    source_head: 0,
    sinks: [],
    sink_head: 0,
    layered_graph,
    random: @random.Rand::new(),
  }

  for i = 0; i < nodes.length(); i = i + 1 {
    let node = nodes[i]
    node.set_id(i)

    for port in node.get_ports() {
      for edge in port.get_incoming_edges() {
        let source = match edge.get_source() {
          Some(value) => value
          None => continue
        }
        let source_node = match source.get_node() {
          Some(value) => value
          None => continue
        }
        if lnode_internal_handle(source_node) == lnode_internal_handle(node) {
          continue
        }
        let priority = edge.get_property_int(layered_options_priority_direction)
        state.indeg[i] = state.indeg[i] +
          greedy_cycle_breaker_node_priority_contribution(priority)
      }

      for edge in port.get_outgoing_edges() {
        let target = match edge.get_target() {
          Some(value) => value
          None => continue
        }
        let target_node = match target.get_node() {
          Some(value) => value
          None => continue
        }
        if lnode_internal_handle(target_node) == lnode_internal_handle(node) {
          continue
        }
        let priority = edge.get_property_int(layered_options_priority_direction)
        state.outdeg[i] = state.outdeg[i] +
          greedy_cycle_breaker_node_priority_contribution(priority)
      }
    }

    if state.outdeg[i] == 0 {
      state.sinks.push(node)
    } else if state.indeg[i] == 0 {
      state.sources.push(node)
    }
  }

  greedy_cycle_breaker_collect_and_mark(state, choose_node_with_max_outflow)
  greedy_cycle_breaker_shift_sink_ranks(state)
  greedy_cycle_breaker_reverse_edges_pointing_left(state)

  monitor.done()
}

///|
fn greedy_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  greedy_cycle_breaker_process_with_chooser(
    layered_graph, progress_monitor, greedy_cycle_breaker_choose_node_with_max_outflow_default,
  )
}

///|
pub fn new_greedy_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    greedy_cycle_breaker_process, greedy_cycle_breaker_configuration,
  )
}
