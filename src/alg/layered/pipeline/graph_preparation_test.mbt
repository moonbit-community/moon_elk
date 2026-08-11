///|
test "graph preparation returns an execution plan" {
  let graph = new_l_graph()
  let plan = graph_configurator_prepare_graph_for_layout(
    @engine.new_layered_phase_registry(),
    graph,
  )
  assert_false(plan.get_processors().is_empty())
}
