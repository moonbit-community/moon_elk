///|
fn self_loop_router_parse_edge_routing(value : String) -> EdgeRouting {
  match value {
    "POLYLINE" => EdgeRouting::Polyline
    "SPLINES" => EdgeRouting::Splines
    "ORTHOGONAL" => EdgeRouting::Orthogonal
    _ => EdgeRouting::RoutingUndefined
  }
}

///|
fn self_loop_router_router_for_graph(graph : LGraph) -> AbstractSelfLoopRouter {
  match
    self_loop_router_parse_edge_routing(graph.get_property_string(edge_routing)) {
    EdgeRouting::Polyline => new_polyline_self_loop_router()
    EdgeRouting::Splines => new_spline_self_loop_router()
    _ => new_orthogonal_self_loop_router()
  }
}

///|
fn self_loop_router_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn self_loop_router_process_node(
  sl_holder : SelfLoopHolder,
  label_manager : ILabelManager?,
  routing_director : RoutingDirector,
  label_placer : LabelPlacer,
  routing_slot_assigner : RoutingSlotAssigner,
  sl_router : AbstractSelfLoopRouter,
  monitor : IElkProgressMonitor?,
) -> Unit {
  routing_director.determine_loop_routes(sl_holder)
  label_placer.place_labels(sl_holder, label_manager, monitor)
  routing_slot_assigner.assign_routing_slots(sl_holder)
  sl_router.route_self_loops(sl_holder)
}

///|
fn self_loop_router_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Self-Loop routing", 1.0))

  let router = self_loop_router_router_for_graph(graph)
  let routing_director = new_routing_director()
  let label_placer = new_label_placer()
  let routing_slot_assigner = new_routing_slot_assigner()
  let label_manager = graph.get_property_i_label_manager(
    label_management_options_label_manager,
  )
  for layer in graph.get_layers() {
    for l_node in layer.get_nodes() {
      if !self_loop_router_node_type_is_normal(l_node.get_type()) {
        continue
      }
      if !l_node.has_property_self_loop_holder(
          internal_properties_self_loop_holder,
        ) {
        continue
      }
      match
        l_node.get_property_self_loop_holder(
          internal_properties_self_loop_holder,
        ) {
        Some(sl_holder) =>
          self_loop_router_process_node(
            sl_holder,
            label_manager,
            routing_director,
            label_placer,
            routing_slot_assigner,
            router,
            Some(monitor),
          )
        None => ()
      }
    }
  }

  monitor.done()
}

///|
pub fn new_self_loop_router_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(self_loop_router_process)
}
