///|
fn scc_node_type_find_nodes(
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
    if strongly_connected_component.length() <= 1 {
      continue
    }

    let mut min_node : LNode? = None
    let mut max_node : LNode? = None
    let mut model_order_min = @int.max_value
    let mut model_order_max = -@int.max_value
    let calculator = new_group_model_order_calculator()

    for node in strongly_connected_component {
      let model_order_current = scc_model_order_cycle_breaker_compute_model_order(
        calculator, node, enforce_group_model_order, offset, big_offset,
      )
      match min_node {
        None => {
          min_node = Some(node)
          model_order_min = model_order_current
        }
        Some(_) =>
          if model_order_min > model_order_current {
            min_node = Some(node)
            model_order_min = model_order_current
          }
      }
      match max_node {
        None => {
          max_node = Some(node)
          model_order_max = model_order_current
        }
        Some(_) =>
          if model_order_max < model_order_current {
            max_node = Some(node)
            model_order_max = model_order_current
          }
      }
    }

    match (min_node, max_node) {
      (Some(minimum), Some(maximum)) => {
        let min_cycle_breaking_id = minimum.get_property_int(
          layered_options_consider_model_order_group_model_order_cycle_breaking_id,
        )
        let max_cycle_breaking_id = maximum.get_property_int(
          layered_options_consider_model_order_group_model_order_cycle_breaking_id,
        )
        let preferred_source_id = graph.get_property_int(
          layered_options_consider_model_order_group_model_order_cb_preferred_source_id,
        )
        let preferred_target_id = graph.get_property_int(
          layered_options_consider_model_order_group_model_order_cb_preferred_target_id,
        )

        if min_cycle_breaking_id == preferred_source_id {
          for edge in minimum.get_incoming_edges() {
            let source_node = scc_model_order_cycle_breaker_require_source_node(
              edge,
            )
            if scc_model_order_cycle_breaker_scc_contains_node(
                strongly_connected_component, source_node,
              ) {
              rev_edges.push(edge)
            }
          }
        } else if max_cycle_breaking_id == preferred_target_id {
          for edge in maximum.get_outgoing_edges() {
            let source_node = scc_model_order_cycle_breaker_require_source_node(
              edge,
            )
            if scc_model_order_cycle_breaker_scc_contains_node(
                strongly_connected_component, source_node,
              ) {
              rev_edges.push(edge)
            }
          }
        } else if minimum.get_incoming_edges().length() >
          maximum.get_outgoing_edges().length() {
          for edge in minimum.get_incoming_edges() {
            let source_node = scc_model_order_cycle_breaker_require_source_node(
              edge,
            )
            if scc_model_order_cycle_breaker_scc_contains_node(
                strongly_connected_component, source_node,
              ) {
              rev_edges.push(edge)
            }
          }
        } else {
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
        }
      }
      _ => ()
    }
  }
}

///|
fn scc_node_type_cycle_breaker_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  scc_model_order_cycle_breaker_process_with_finder(
    layered_graph, progress_monitor, scc_node_type_find_nodes,
  )
}

///|
pub fn new_scc_node_type_cycle_breaker_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    scc_node_type_cycle_breaker_process, scc_model_order_cycle_breaker_configuration,
  )
}
