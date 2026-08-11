///|
pub fn graph_configurator_prepare_graph_for_layout(
  registry : LayeredPhaseRegistry,
  lgraph : LGraph,
) -> LayeredLayoutPlan raise {
  @transform.graph_configurator_configure_graph_properties(lgraph)
  new_layered_layout_plan(
    elk_layered_collect_algorithm_for_graph(registry, lgraph),
    state=lgraph.get_layout_state(),
  )
}
