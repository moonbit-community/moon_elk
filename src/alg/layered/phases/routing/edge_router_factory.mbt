///|
fn edge_router_factory_strategy_ordinal(strategy : @core.EdgeRouting) -> Int {
  match strategy {
    RoutingUndefined => 0
    Polyline => 1
    Splines => 2
    Orthogonal => 3
  }
}

///|
fn edge_router_factory_create_router(
  strategy : @core.EdgeRouting,
  state : @runtime.LayeredRunState,
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  match strategy {
    Polyline => new_polyline_edge_router_layout_phase(state~)
    Splines => new_spline_edge_router_layout_phase(state~)
    _ => new_orthogonal_edge_router_layout_phase(state~)
  }
}

///|
pub fn edge_router_factory_factory_for(
  graph : @runtime.LGraph,
  edge_routing_strategy : @core.EdgeRouting,
  state? : @runtime.LayeredRunState = @runtime.new_layered_run_state(),
) -> @core.LayoutProcessorFactory {
  let ordinal = edge_router_factory_strategy_ordinal(edge_routing_strategy)
  @core.new_layout_processor_factory(24000 + ordinal, ordinal, graph, () => {
    edge_router_factory_create_router(edge_routing_strategy, state)
  })
}
