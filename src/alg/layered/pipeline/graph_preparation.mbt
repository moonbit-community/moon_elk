///|
pub fn graph_configurator_prepare_graph_for_layout(
  registry : LayeredPhaseRegistry,
  lgraph : LGraph,
  state : @runtime.LayeredRunState,
) -> LayeredLayoutPlan raise {
  @transform.graph_configurator_configure_graph_properties(lgraph, state)
  new_layered_layout_plan(
    elk_layered_collect_algorithm_for_graph(registry, lgraph, state),
    state~,
  )
}
