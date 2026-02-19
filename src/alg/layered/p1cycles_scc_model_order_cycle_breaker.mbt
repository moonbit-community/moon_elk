///|
fn scc_model_order_cycle_breaker_require_source_node(edge : LEdge) -> LNode {
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
  match source.get_node() {
    Some(node) => node
    None => abort("source port has no owner node")
  }
}

///|
fn scc_model_order_cycle_breaker_require_target_node(edge : LEdge) -> LNode {
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
fn scc_model_order_cycle_breaker_reverse_edge(edge : LEdge) -> Unit {
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
fn scc_model_order_cycle_breaker_configuration(
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
fn scc_model_order_cycle_breaker_scc_contains_node(
  strongly_connected_component : Array[LNode],
  node : LNode,
) -> Bool {
  for component_node in strongly_connected_component {
    if lnode_internal_handle(component_node) == lnode_internal_handle(node) {
      return true
    }
  }
  false
}

///|
fn scc_model_order_cycle_breaker_enforce_group_model_order(
  graph : LGraph,
) -> Bool {
  group_order_strategy_equals(
    group_order_strategy_from_string(
      graph.get_property_string(
        layered_options_consider_model_order_group_model_order_cb_group_order_strategy,
      ),
    ),
    GroupOrderStrategy::Enforced,
  )
}

///|
fn scc_model_order_cycle_breaker_compute_model_order(
  calculator : GroupModelOrderCalculator,
  node : LNode,
  enforce_group_model_order : Bool,
  offset : Int,
  big_offset : Int,
) -> Int {
  if enforce_group_model_order {
    calculator.compute_constraint_group_model_order(node, big_offset, offset)
  } else {
    calculator.compute_constraint_model_order(node, offset)
  }
}

///|
fn scc_model_order_cycle_breaker_find_nodes(
  graph : LGraph,
  strongly_connected_components : Array[Array[LNode]],
  rev_edges : Array[LEdge],
  offset : Int,
  big_offset : Int,
) -> Unit {
  let enforce_group_model_order = scc_model_order_cycle_breaker_enforce_group_model_order(
    graph,
  )

  for strongly_connected_component in strongly_connected_components {
    let mut max_node : LNode? = None
    let mut max_model_order = -@int.max_value
    let calculator = new_group_model_order_calculator()

    for node in strongly_connected_component {
      let model_order = scc_model_order_cycle_breaker_compute_model_order(
        calculator, node, enforce_group_model_order, offset, big_offset,
      )
      if model_order > max_model_order {
        max_model_order = model_order
        max_node = Some(node)
      }
    }

    match max_node {
      Some(maximum) =>
        for edge in maximum.get_outgoing_edges() {
          let target_node = scc_model_order_cycle_breaker_require_target_node(
            edge,
          )
          if scc_model_order_cycle_breaker_scc_contains_node(
              strongly_connected_component, target_node,
            ) {
            rev_edges.push(edge)
          }
        }
      None => ()
    }
  }
}

///|
fn scc_model_order_cycle_breaker_process_with_finder(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
  find_nodes : (LGraph, Array[Array[LNode]], Array[LEdge], Int, Int) -> Unit,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Model order cycle breaking", 1.0))

  let rev_edges = []
  let offset = if layered_graph.get_layerless_nodes().length() >
    layered_graph.get_property_int(internal_properties_max_model_order_nodes) {
    layered_graph.get_layerless_nodes().length()
  } else {
    layered_graph.get_property_int(internal_properties_max_model_order_nodes)
  }
  let big_offset = offset *
    layered_graph.get_property_int(
      internal_properties_cb_num_model_order_groups,
    )

  while true {
    let tarjan = new_tarjan(rev_edges)
    tarjan.reset_tarjan(layered_graph)
    tarjan.tarjan(layered_graph)

    let strongly_connected_components = tarjan.get_strongly_connected_components()
    if strongly_connected_components.length() == 0 {
      break
    }

    find_nodes(
      layered_graph, strongly_connected_components, rev_edges, offset, big_offset,
    )
    for edge in rev_edges {
      scc_model_order_cycle_breaker_reverse_edge(edge)
      layered_graph.set_property_bool(internal_properties_cyclic, true)
    }
    rev_edges.clear()
  }

  monitor.done()
}

///|
fn scc_model_order_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  scc_model_order_cycle_breaker_process_with_finder(
    layered_graph, progress_monitor, scc_model_order_cycle_breaker_find_nodes,
  )
}

///|
pub fn new_scc_model_order_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    scc_model_order_cycle_breaker_process, scc_model_order_cycle_breaker_configuration,
  )
}
