///|
pub(all) suberror InteractiveCycleBreakerException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] interactive_cycle_breaker_raise_unsupported_graph(
  message : String,
) -> T raise InteractiveCycleBreakerException {
  raise InteractiveCycleBreakerException::UnsupportedGraphException(message)
}

///|
fn interactive_cycle_breaker_require_target_node(
  edge : LEdge,
) -> LNode raise InteractiveCycleBreakerException {
  let target = match edge.get_target() {
    Some(value) => value
    None =>
      interactive_cycle_breaker_raise_unsupported_graph(
        "edge has no target port",
      )
  }
  match target.get_node() {
    Some(node) => node
    None =>
      interactive_cycle_breaker_raise_unsupported_graph(
        "target port has no owner node",
      )
  }
}

///|
fn interactive_cycle_breaker_reverse_edge(edge : LEdge, graph : LGraph) -> Unit {
  edge.reverse(graph, true)
}

///|
fn interactive_cycle_breaker_find_cycles(
  node1 : LNode,
  rev_edges : Array[LEdge],
) -> Unit raise InteractiveCycleBreakerException {
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
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Interactive cycle breaking", 1.0))

  try {
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
      interactive_cycle_breaker_reverse_edge(edge, layered_graph)
      layered_graph.set_property_bool(internal_properties_cyclic, true)
    }

    rev_edges.clear()
    for node in layered_graph.get_layerless_nodes() {
      if node.get_id() > 0 {
        interactive_cycle_breaker_find_cycles(node, rev_edges)
      }
    }

    for edge in rev_edges {
      interactive_cycle_breaker_reverse_edge(edge, layered_graph)
      layered_graph.set_property_bool(internal_properties_cyclic, true)
    }

    rev_edges.clear()
  } catch {
    InteractiveCycleBreakerException::UnsupportedGraphException(message) => {
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
fn interactive_cycle_breaker_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(layered_phase_descriptor)
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
pub fn new_interactive_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    interactive_cycle_breaker_process, interactive_cycle_breaker_configuration,
  )
}
