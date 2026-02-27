///|
pub(all) suberror ModelOrderCycleBreakerException {
  UnsupportedGraphException(String)
} derive(Show, ToJson)

///|
fn[T] model_order_cycle_breaker_raise_unsupported_graph(
  message : String,
) -> T raise ModelOrderCycleBreakerException {
  raise ModelOrderCycleBreakerException::UnsupportedGraphException(message)
}

///|
fn model_order_cycle_breaker_require_target_node(
  edge : LEdge,
) -> LNode raise ModelOrderCycleBreakerException {
  let target = match edge.get_target() {
    Some(value) => value
    None =>
      model_order_cycle_breaker_raise_unsupported_graph(
        "edge has no target port",
      )
  }
  match target.get_node() {
    Some(node) => node
    None =>
      model_order_cycle_breaker_raise_unsupported_graph(
        "target port has no owner node",
      )
  }
}

///|
fn model_order_cycle_breaker_reverse_edge(edge : LEdge, graph : LGraph) -> Unit {
  edge.reverse(graph, true)
}

///|
fn model_order_cycle_breaker_configuration(
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
fn model_order_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Model order cycle breaking", 1.0))

  try {
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
    let enforce_group_model_order = group_order_strategy_equals(
      group_order_strategy_from_string(
        layered_graph.get_property_string(
          layered_options_consider_model_order_group_model_order_cb_group_order_strategy,
        ),
      ),
      GroupOrderStrategy::Enforced,
    )

    for source in layered_graph.get_layerless_nodes() {
      let calculator = new_group_model_order_calculator()
      let model_order_source = if enforce_group_model_order {
        calculator.compute_constraint_group_model_order(
          source, big_offset, offset,
        )
      } else {
        calculator.compute_constraint_model_order(source, offset)
      }

      for port in source.get_ports_by_type(PortType::Output) {
        for edge in port.get_outgoing_edges() {
          let target = model_order_cycle_breaker_require_target_node(edge)
          let model_order_target = if enforce_group_model_order {
            calculator.compute_constraint_group_model_order(
              target, big_offset, offset,
            )
          } else {
            calculator.compute_constraint_model_order(target, offset)
          }
          if model_order_target < model_order_source {
            rev_edges.push(edge)
          }
        }
      }
    }

    for edge in rev_edges {
      model_order_cycle_breaker_reverse_edge(edge, layered_graph)
      layered_graph.set_property_bool(internal_properties_cyclic, true)
    }
    rev_edges.clear()
  } catch {
    ModelOrderCycleBreakerException::UnsupportedGraphException(message) => {
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
pub fn new_model_order_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    model_order_cycle_breaker_process, model_order_cycle_breaker_configuration,
  )
}
