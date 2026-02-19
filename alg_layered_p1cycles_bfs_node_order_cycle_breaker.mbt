///|
struct BfsNodeOrderCycleBreakerState {
  sources : Map[Int, Bool]
  sinks : Map[Int, Bool]
  visited : Array[Bool]
  bfs_queue : Array[LNode]
  mut bfs_head : Int
  edges_to_be_reversed : Array[LEdge]
  graph : LGraph
}

///|
fn bfs_node_order_reverse_edge(edge : LEdge) -> Unit {
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
fn bfs_node_order_model_order_sort(values : Array[Int]) -> Unit {
  let mut i = 1
  while i < values.length() {
    let value = values[i]
    let mut j = i
    while j > 0 && values[j - 1] > value {
      values[j] = values[j - 1]
      j = j - 1
    }
    values[j] = value
    i = i + 1
  }
}

///|
fn bfs_node_order_node_set_contains(
  node_set : Map[Int, Bool],
  node : LNode,
) -> Bool {
  match node_set.get(node.get_handle()) {
    Some(value) => value
    None => false
  }
}

///|
fn bfs_node_order_state_group_model_order(
  state : BfsNodeOrderCycleBreakerState,
) -> Bool {
  group_order_strategy_equals(
    group_order_strategy_from_string(
      state.graph.get_property_string(
        layered_options_consider_model_order_group_model_order_cb_group_order_strategy,
      ),
    ),
    GroupOrderStrategy::Enforced,
  )
}

///|
fn bfs_node_order_target_model_order(
  state : BfsNodeOrderCycleBreakerState,
  edge : LEdge,
  model_order_map_size : Int,
  group_model_order : Bool,
) -> Int {
  let target = match edge.get_target() {
    Some(port) =>
      match port.get_node() {
        Some(node) => node
        None => return @int.max_value - model_order_map_size
      }
    None => return @int.max_value - model_order_map_size
  }
  if !target.has_property_int(internal_properties_model_order) {
    return @int.max_value - model_order_map_size
  }

  if group_model_order {
    let max_model_order_group_size = state.graph.get_property_int(
      internal_properties_max_model_order_nodes,
    )
    max_model_order_group_size *
    target.get_property_int(
      layered_options_consider_model_order_group_model_order_cycle_breaking_id,
    ) +
    target.get_property_int(internal_properties_model_order)
  } else {
    target.get_property_int(internal_properties_model_order)
  }
}

///|
fn bfs_node_order_visit_node(
  state : BfsNodeOrderCycleBreakerState,
  node : LNode,
) -> Unit {
  let node_id = node.get_id()
  if state.visited[node_id] {
    return
  }
  state.visited[node_id] = true

  let model_order_map : Map[Int, Array[LEdge]] = {}
  let group_model_order = bfs_node_order_state_group_model_order(state)

  for edge in node.get_outgoing_edges() {
    let target_model_order = bfs_node_order_target_model_order(
      state,
      edge,
      model_order_map.length(),
      group_model_order,
    )
    match model_order_map.get(target_model_order) {
      Some(grouped_edges) => grouped_edges.push(edge)
      None => model_order_map[target_model_order] = [edge]
    }
  }

  let model_orders = []
  for entry in model_order_map.to_array() {
    model_orders.push(entry.0)
  }
  bfs_node_order_model_order_sort(model_orders)

  for model_order in model_orders {
    let grouped_edges = match model_order_map.get(model_order) {
      Some(value) => value
      None => continue
    }
    if grouped_edges.is_empty() {
      continue
    }

    let out_edge = grouped_edges[0]
    if out_edge.is_self_loop() {
      continue
    }
    let target = match out_edge.get_target() {
      Some(port) =>
        match port.get_node() {
          Some(node) => node
          None => continue
        }
      None => continue
    }

    if state.visited[target.get_id()] &&
      !bfs_node_order_node_set_contains(state.sources, node) &&
      !bfs_node_order_node_set_contains(state.sinks, target) {
      for edge in grouped_edges {
        state.edges_to_be_reversed.push(edge)
      }
    } else {
      state.bfs_queue.push(target)
    }
  }
}

///|
fn bfs_node_order_loop(state : BfsNodeOrderCycleBreakerState) -> Unit {
  while state.bfs_head < state.bfs_queue.length() {
    let node = state.bfs_queue[state.bfs_head]
    state.bfs_head = state.bfs_head + 1
    bfs_node_order_visit_node(state, node)
  }
}

///|
fn bfs_node_order_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    layout_processor_configuration_create(layered_phase_descriptor).add_after(
      LayeredPhases::P5EdgeRouting,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::ReversedEdgeRestorer,
      ),
    ),
  )
}

///|
fn bfs_node_order_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Breadth-first cycle removal", 1.0))

  let nodes = graph.get_layerless_nodes()
  let state = {
    sources: {},
    sinks: {},
    visited: Array::make(nodes.length(), false),
    bfs_queue: [],
    bfs_head: 0,
    edges_to_be_reversed: [],
    graph,
  }

  for i = 0; i < nodes.length(); i = i + 1 {
    let node = nodes[i]
    node.set_id(i)
    if node.get_incoming_edges().is_empty() {
      state.sources[node.get_handle()] = true
    }
    if node.get_outgoing_edges().is_empty() {
      state.sinks[node.get_handle()] = true
    }
  }

  for source in nodes {
    if bfs_node_order_node_set_contains(state.sources, source) {
      state.bfs_queue.push(source)
      bfs_node_order_loop(state)
    }
  }

  bfs_node_order_loop(state)

  let mut changed = true
  while changed {
    changed = false
    for i = 0; i < nodes.length(); i = i + 1 {
      if !state.visited[i] {
        state.bfs_queue.push(nodes[i])
        changed = true
        break
      }
    }
    bfs_node_order_loop(state)
  }

  for edge in state.edges_to_be_reversed {
    bfs_node_order_reverse_edge(edge)
    graph.set_property_bool(internal_properties_cyclic, true)
  }

  monitor.done()
}

///|
pub fn new_bfs_node_order_cycle_breaker_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(bfs_node_order_process, bfs_node_order_configuration)
}
