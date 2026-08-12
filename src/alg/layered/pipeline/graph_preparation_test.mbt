///|
test "graph preparation returns an execution plan" {
  let graph = new_l_graph()
  let state = @runtime.new_layered_run_state()
  let plan = graph_configurator_prepare_graph_for_layout(
    @engine.new_layered_phase_registry(),
    graph,
    state,
  )
  assert_false(plan.get_processors().is_empty())
}
