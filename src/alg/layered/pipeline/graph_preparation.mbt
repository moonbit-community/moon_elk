///|
pub fn graph_configurator_prepare_graph_for_layout(
  lgraph : LGraph,
) -> LayeredLayoutPlan {
  @transform.graph_configurator_configure_graph_properties(lgraph)
  new_layered_layout_plan(elk_layered_collect_algorithm_for_graph(lgraph))
}
