///|
pub fn register_edge_routing_phases(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  registry.register_edge_routing_phase("POLYLINE", 24001, state => {
    new_polyline_edge_router_layout_phase(state~)
  })
  registry.register_edge_routing_phase("SPLINES", 24002, state => {
    new_spline_edge_router_layout_phase(state~)
  })
  registry.register_edge_routing_phase("ORTHOGONAL", 24003, state => {
    new_orthogonal_edge_router_layout_phase(state~)
  })
}

///|
pub fn register_routing_processors(
  registry : @runtime.LayeredPhaseRegistry,
) -> Unit {
  registry.register_stateful_intermediate_processor(SelfLoopPreprocessor, state => {
    new_self_loop_pre_processor_layout_processor(state~)
  })
  registry.register_stateful_intermediate_processor(SelfLoopPortRestorer, state => {
    new_self_loop_port_restorer_layout_processor(state~)
  })
  registry.register_stateful_intermediate_processor(SelfLoopRouter, state => {
    new_self_loop_router_layout_processor(state~)
  })
  registry.register_stateful_intermediate_processor(SelfLoopPostprocessor, state => {
    new_self_loop_post_processor_layout_processor(state~)
  })
  registry.register_stateful_intermediate_processor(
    HierarchicalPortOrthogonalEdgeRouter,
    state => {
      new_hierarchical_port_orthogonal_edge_router_layout_processor(state~)
    },
  )
  registry.register_stateful_intermediate_processor(
    FinalSplineBendpointsCalculator,
    state => new_final_spline_bendpoints_calculator_layout_processor(state~),
  )
  registry.register_intermediate_processor(LabelDummyRemover, () => {
    new_label_dummy_remover_layout_processor()
  })
}
