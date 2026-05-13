///|
let edge_router_factory_cache : Ref[
  Map[String, @core.ILayoutProcessorFactory[LayeredPhases, LGraph]],
] = Ref({})

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
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  match strategy {
    Polyline => new_polyline_edge_router_layout_phase()
    Splines => new_spline_edge_router_layout_phase()
    _ => new_orthogonal_edge_router_layout_phase()
  }
}

///|
pub fn edge_router_factory_factory_for(
  edge_routing_strategy : @core.EdgeRouting,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  let key = @core.edge_routing_to_string(edge_routing_strategy)
  match edge_router_factory_cache.val.get(key) {
    Some(factory) => factory
    None => {
      let ordinal = edge_router_factory_strategy_ordinal(edge_routing_strategy)
      let factory = @core.new_layout_processor_factory(
        24000 + ordinal,
        ordinal,
        () => edge_router_factory_create_router(edge_routing_strategy),
      )
      edge_router_factory_cache.val[key] = factory
      factory
    }
  }
}
