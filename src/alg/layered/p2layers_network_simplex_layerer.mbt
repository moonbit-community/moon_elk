///|
let network_simplex_layerer_iter_limit_factor = 4

///|
priv suberror NetworkSimplexLayererException {
  NetworkSimplexLayererException(String)
} derive(Show, ToJson)

///|
fn[T] network_simplex_layerer_raise(
  message : String,
) -> T raise NetworkSimplexLayererException {
  raise NetworkSimplexLayererException(message)
}

///|
fn network_simplex_layerer_exception_message(
  err : NetworkSimplexLayererException,
) -> String {
  match err {
    NetworkSimplexLayererException(message) => message
  }
}

///|
fn network_simplex_layerer_layer_constraint_preprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn network_simplex_layerer_layer_constraint_postprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let network_simplex_layerer_baseline_processing_configuration : @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = @core.layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    network_simplex_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    network_simplex_layerer_layer_constraint_postprocessor_factory(),
  )

///|
fn network_simplex_layerer_require_port_node(
  port : LPort,
) -> LNode raise NetworkSimplexLayererException {
  match port.get_node() {
    Some(value) => value
    None => network_simplex_layerer_raise("port has no owner node")
  }
}

///|
fn network_simplex_layerer_require_edge_source_port(
  edge : LEdge,
) -> LPort raise NetworkSimplexLayererException {
  match edge.get_source() {
    Some(value) => value
    None => network_simplex_layerer_raise("edge has no source port")
  }
}

///|
fn network_simplex_layerer_require_edge_target_port(
  edge : LEdge,
) -> LPort raise NetworkSimplexLayererException {
  match edge.get_target() {
    Some(value) => value
    None => network_simplex_layerer_raise("edge has no target port")
  }
}

///|
fn network_simplex_layerer_get_opposite(
  port : LPort,
  edge : LEdge,
) -> LPort raise NetworkSimplexLayererException {
  let source = network_simplex_layerer_require_edge_source_port(edge)
  let target = network_simplex_layerer_require_edge_target_port(edge)
  if lport_internal_handle(source) == lport_internal_handle(port) {
    target
  } else if lport_internal_handle(target) == lport_internal_handle(port) {
    source
  } else {
    network_simplex_layerer_raise(
      "Input edge is not connected to the input port.",
    )
  }
}

///|
fn network_simplex_layerer_create_edge(
  builder : @common.NEdgeBuilder,
) -> @common.NEdge raise NetworkSimplexLayererException {
  try builder.create() catch {
    err => network_simplex_layerer_raise(err.to_string())
  } noraise {
    edge => edge
  }
}

///|
fn network_simplex_layerer_connected_components_dfs(
  node : LNode,
  node_visited : Array[Bool],
  component_nodes : Array[LNode],
) -> Unit raise NetworkSimplexLayererException {
  node_visited[node.get_id()] = true
  component_nodes.push(node)

  for port in node.get_ports() {
    for edge in port.get_connected_edges() {
      let opposite = network_simplex_layerer_get_opposite(port, edge)
      let opposite_node = network_simplex_layerer_require_port_node(opposite)
      if !node_visited[opposite_node.get_id()] {
        network_simplex_layerer_connected_components_dfs(
          opposite_node, node_visited, component_nodes,
        )
      }
    }
  }
}

///|
fn network_simplex_layerer_connected_components(
  the_nodes : Array[LNode],
) -> Array[Array[LNode]] raise NetworkSimplexLayererException {
  let node_visited = Array::make(the_nodes.length(), false)
  let components : Array[Array[LNode]] = []

  let mut counter = 0
  for node in the_nodes {
    node.set_id(counter)
    counter += 1
  }

  for node in the_nodes {
    if !node_visited[node.get_id()] {
      let component_nodes = []
      network_simplex_layerer_connected_components_dfs(
        node, node_visited, component_nodes,
      )

      if components.is_empty() ||
        components[0].length() < component_nodes.length() {
        ignore(components.insert(0, component_nodes))
      } else {
        components.push(component_nodes)
      }
    }
  }

  components
}

///|
priv struct NetworkSimplexLayererInitResult {
  graph : @common.NGraph
  node_map : Map[Int, LNode]
}

///|
fn network_simplex_layerer_initialize(
  the_nodes : Array[LNode],
) -> NetworkSimplexLayererInitResult raise NetworkSimplexLayererException {
  let graph = @common.new_ngraph()
  let lnode_to_nnode : Map[Int, @common.NNode] = {}
  let node_map : Map[Int, LNode] = {}

  for lnode in the_nodes {
    let nnode = @common.nnode_of()
      .id(lnode.get_id())
      .origin(lnode.get_handle().to_string())
      .create(graph)
    lnode_to_nnode[lnode.get_handle()] = nnode
    node_map[lnode.get_id()] = lnode
  }

  for lnode in the_nodes {
    for ledge in lnode.get_outgoing_edges() {
      if ledge.is_self_loop() {
        continue
      }

      let source_lnode = network_simplex_layerer_require_port_node(
        network_simplex_layerer_require_edge_source_port(ledge),
      )
      let target_lnode = network_simplex_layerer_require_port_node(
        network_simplex_layerer_require_edge_target_port(ledge),
      )

      let source_nnode = match lnode_to_nnode.get(source_lnode.get_handle()) {
        Some(value) => value
        None => network_simplex_layerer_raise("missing transformed source node")
      }
      let target_nnode = match lnode_to_nnode.get(target_lnode.get_handle()) {
        Some(value) => value
        None => network_simplex_layerer_raise("missing transformed target node")
      }

      let shortness = ledge.get_property_int(layered_options_priority_shortness)
      let weight = (if shortness > 1 { shortness } else { 1 }).to_double()
      ignore(
        network_simplex_layerer_create_edge(
          @common.nedge_of()
          .origin(ledge.get_handle().to_string())
          .weight(weight)
          .delta(1)
          .source(source_nnode)
          .target(target_nnode),
        ),
      )
    }
  }

  { graph, node_map }
}

///|
fn network_simplex_layerer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(network_simplex_layerer_baseline_processing_configuration)
}

///|
fn network_simplex_layerer_process(
  the_layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Network simplex layering", 1.0))

  let thoroughness = the_layered_graph.get_property_int(
      layered_options_thoroughness,
    ) *
    network_simplex_layerer_iter_limit_factor

  let the_nodes = the_layered_graph.get_layerless_nodes()
  if the_nodes.length() < 1 {
    monitor.done()
    return
  }

  let connected_components = try
    network_simplex_layerer_connected_components(the_nodes)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        network_simplex_layerer_exception_message(err),
      )
      monitor.done()
      return
    }
  } noraise {
    value => value
  }
  let mut previous_layering_node_counts : Array[Int]? = None

  for conn_comp in connected_components {
    let iter_limit = thoroughness *
      conn_comp.length().to_double().sqrt().to_int()
    let initialized = try network_simplex_layerer_initialize(conn_comp) catch {
      err => {
        @core.layout_runtime_report_unsupported_configuration(
          network_simplex_layerer_exception_message(err),
        )
        monitor.done()
        return
      }
    } noraise {
      value => value
    }
    let graph = initialized.graph

    let simplex = @common.network_simplex_for_graph(graph)
    ignore(simplex.with_iteration_limit(iter_limit))
    match previous_layering_node_counts {
      Some(previous) => ignore(simplex.with_previous_layering(previous))
      None => ()
    }
    ignore(simplex.with_balancing(true))
    match monitor.sub_task(1.0) {
      Some(sub_monitor) => simplex.execute(monitor=sub_monitor)
      None => simplex.execute()
    }

    let layers = the_layered_graph.get_layers()
    for nnode in graph.nodes {
      let layer_index = nnode.get_layer()
      while layers.length() <= layer_index {
        layers.push(new_layer(the_layered_graph))
      }

      let lnode = match initialized.node_map.get(nnode.get_id()) {
        Some(value) => value
        None => {
          @core.layout_runtime_report_unsupported_configuration(
            "missing original node for network simplex node",
          )
          monitor.done()
          return
        }
      }
      lnode.set_layer(Some(layers[layer_index]))
    }

    if connected_components.length() > 1 {
      let counts = []
      for layer in the_layered_graph.get_layers() {
        counts.push(layer.get_nodes().length())
      }
      previous_layering_node_counts = Some(counts)
    }
  }

  the_nodes.clear()
  monitor.done()
}

///|
pub fn new_network_simplex_layerer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    network_simplex_layerer_process, network_simplex_layerer_configuration,
  )
}
