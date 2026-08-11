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
) -> @core.TypedLayoutProcessor[LGraph] {
  match strategy {
    Polyline => new_polyline_edge_router_layout_phase()
    Splines => new_spline_edge_router_layout_phase()
    _ => new_orthogonal_edge_router_layout_phase()
  }
}

///|
pub fn edge_router_factory_factory_for(
  graph : LGraph,
  edge_routing_strategy : @core.EdgeRouting,
) -> @core.LayoutProcessorFactory {
  let ordinal = edge_router_factory_strategy_ordinal(edge_routing_strategy)
  @core.new_layout_processor_factory(24000 + ordinal, ordinal, graph, () => {
    edge_router_factory_create_router(edge_routing_strategy)
  })
}
