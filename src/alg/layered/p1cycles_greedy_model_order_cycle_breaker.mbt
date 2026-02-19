///|
fn greedy_model_order_cycle_breaker_choose_node_with_max_outflow(
  nodes : Array[LNode],
  graph : LGraph,
  random : @random.Rand,
) -> LNode {
  let mut return_node : LNode? = None
  let mut minimum_model_order = @int.max_value
  let offset = if graph.get_layerless_nodes().length() >
    graph.get_property_int(internal_properties_max_model_order_nodes) {
    graph.get_layerless_nodes().length()
  } else {
    graph.get_property_int(internal_properties_max_model_order_nodes)
  }
  let big_offset = offset *
    graph.get_property_int(internal_properties_cb_num_model_order_groups)
  let mo_calculator = new_group_model_order_calculator()
  let enforce_group_model_order = group_order_strategy_equals(
    group_order_strategy_from_string(
      graph.get_property_string(
        layered_options_consider_model_order_group_model_order_cb_group_order_strategy,
      ),
    ),
    GroupOrderStrategy::Enforced,
  )

  for node in nodes {
    if node.has_property_int(internal_properties_model_order) {
      let model_order = if enforce_group_model_order {
        mo_calculator.compute_constraint_group_model_order(
          node, big_offset, offset,
        )
      } else {
        mo_calculator.compute_constraint_model_order(node, offset)
      }
      if minimum_model_order > model_order {
        minimum_model_order = model_order
        return_node = Some(node)
      }
    }
  }

  match return_node {
    Some(node) => node
    None =>
      greedy_cycle_breaker_choose_node_with_max_outflow_default(
        nodes, graph, random,
      )
  }
}

///|
fn greedy_model_order_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  greedy_cycle_breaker_process_with_chooser(
    layered_graph, progress_monitor, greedy_model_order_cycle_breaker_choose_node_with_max_outflow,
  )
}

///|
pub fn new_greedy_model_order_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    greedy_model_order_cycle_breaker_process, greedy_cycle_breaker_configuration,
  )
}
