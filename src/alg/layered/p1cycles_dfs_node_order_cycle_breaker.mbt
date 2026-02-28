///|
priv struct DfsNodeOrderCycleBreakerState {
  graph : LGraph
  visited : Array[Bool]
  active : Array[Bool]
  edges_to_be_reversed : Array[LEdge]
}

///|
pub(all) suberror DfsNodeOrderCycleBreakerException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] dfs_node_order_cycle_breaker_raise_unsupported_graph(
  message : String,
) -> T raise DfsNodeOrderCycleBreakerException {
  raise DfsNodeOrderCycleBreakerException::UnsupportedGraphException(message)
}

///|
fn dfs_node_order_cycle_breaker_require_target_node(
  edge : LEdge,
) -> LNode raise DfsNodeOrderCycleBreakerException {
  let target = match edge.get_target() {
    Some(value) => value
    None =>
      dfs_node_order_cycle_breaker_raise_unsupported_graph(
        "edge has no target port",
      )
  }
  match target.get_node() {
    Some(node) => node
    None =>
      dfs_node_order_cycle_breaker_raise_unsupported_graph(
        "target port has no owner node",
      )
  }
}

///|
fn dfs_node_order_cycle_breaker_reverse_edge(
  edge : LEdge,
  graph : LGraph,
) -> Unit {
  edge.reverse(graph, true)
}

///|
fn dfs_node_order_cycle_breaker_model_order_sort(values : Array[Int]) -> Unit {
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
fn dfs_node_order_cycle_breaker_group_model_order(
  state : DfsNodeOrderCycleBreakerState,
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
fn dfs_node_order_cycle_breaker_target_model_order(
  state : DfsNodeOrderCycleBreakerState,
  edge : LEdge,
  model_order_map_size : Int,
  group_model_order : Bool,
) -> Int raise DfsNodeOrderCycleBreakerException {
  let target = dfs_node_order_cycle_breaker_require_target_node(edge)
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
fn dfs_node_order_cycle_breaker_dfs(
  state : DfsNodeOrderCycleBreakerState,
  node : LNode,
) -> Unit raise DfsNodeOrderCycleBreakerException {
  let node_id = node.get_id()
  if state.visited[node_id] {
    return
  }

  state.visited[node_id] = true
  state.active[node_id] = true

  let model_order_map : Map[Int, Array[LEdge]] = {}
  let group_model_order = dfs_node_order_cycle_breaker_group_model_order(state)

  for edge in node.get_outgoing_edges() {
    let target_model_order = dfs_node_order_cycle_breaker_target_model_order(
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
  dfs_node_order_cycle_breaker_model_order_sort(model_orders)

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

    let target = dfs_node_order_cycle_breaker_require_target_node(out_edge)
    if state.active[target.get_id()] {
      for edge in grouped_edges {
        state.edges_to_be_reversed.push(edge)
      }
    } else {
      dfs_node_order_cycle_breaker_dfs(state, target)
    }
  }

  state.active[node_id] = false
}

///|
fn dfs_node_order_cycle_breaker_configuration(
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
fn dfs_node_order_cycle_breaker_process(
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
  let state = {
    graph,
    visited: Array::make(node_count, false),
    active: Array::make(node_count, false),
    edges_to_be_reversed: [],
  }
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
      dfs_node_order_cycle_breaker_dfs(state, source)
    }

    for i = 0; i < node_count; i = i + 1 {
      if !state.visited[i] {
        dfs_node_order_cycle_breaker_dfs(state, nodes[i])
      }
    }

    for edge in state.edges_to_be_reversed {
      dfs_node_order_cycle_breaker_reverse_edge(edge, graph)
      graph.set_property_bool(internal_properties_cyclic, true)
    }
  } catch {
    DfsNodeOrderCycleBreakerException::UnsupportedGraphException(message) => {
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
pub fn new_dfs_node_order_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    dfs_node_order_cycle_breaker_process, dfs_node_order_cycle_breaker_configuration,
  )
}
