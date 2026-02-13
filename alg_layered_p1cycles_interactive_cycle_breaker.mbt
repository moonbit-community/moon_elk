///|
fn interactive_cycle_breaker_require_target_node(edge : LEdge) -> LNode {
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
fn interactive_cycle_breaker_reverse_edge(edge : LEdge) -> Unit {
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
fn interactive_cycle_breaker_find_cycles(
  node1 : LNode,
  rev_edges : Array[LEdge],
) -> Unit {
  node1.set_id(-1)
  for port in node1.get_ports_by_type(PortType::Output) {
    for edge in port.get_outgoing_edges() {
      let node2 = interactive_cycle_breaker_require_target_node(edge)
      if node1.get_handle() != node2.get_handle() {
        if node2.get_id() < 0 {
          rev_edges.push(edge)
        } else if node2.get_id() > 0 {
          interactive_cycle_breaker_find_cycles(node2, rev_edges)
        }
      }
    }
  }
  node1.set_id(0)
}

///|
fn interactive_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Interactive cycle breaking", 1.0))

  let rev_edges = []
  for source in layered_graph.get_layerless_nodes() {
    source.set_id(1)
    let sourcex = source.get_position().x
    for port in source.get_ports_by_type(PortType::Output) {
      for edge in port.get_outgoing_edges() {
        let target = interactive_cycle_breaker_require_target_node(edge)
        if target.get_handle() != source.get_handle() {
          let targetx = target.get_position().x
          if targetx < sourcex {
            rev_edges.push(edge)
          }
        }
      }
    }
  }

  for edge in rev_edges {
    interactive_cycle_breaker_reverse_edge(edge)
    layered_graph.set_property_bool(internal_properties_cyclic, true)
  }

  rev_edges.clear()
  for node in layered_graph.get_layerless_nodes() {
    if node.get_id() > 0 {
      interactive_cycle_breaker_find_cycles(node, rev_edges)
    }
  }

  for edge in rev_edges {
    interactive_cycle_breaker_reverse_edge(edge)
    layered_graph.set_property_bool(internal_properties_cyclic, true)
  }

  rev_edges.clear()
  monitor.done()
}

///|
fn interactive_cycle_breaker_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    layout_processor_configuration_create(layered_phase_descriptor)
    .add_before(
      LayeredPhases::P1CycleBreaking,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::InteractiveExternalPortPositioner,
      ),
    )
    .add_after(
      LayeredPhases::P5EdgeRouting,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::ReversedEdgeRestorer,
      ),
    ),
  )
}

///|
pub fn new_interactive_cycle_breaker_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    interactive_cycle_breaker_process, interactive_cycle_breaker_configuration,
  )
}
