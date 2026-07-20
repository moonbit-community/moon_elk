///|
test "graph preparation returns an execution plan" {
  let graph = new_l_graph()
  let plan = graph_configurator_prepare_graph_for_layout(graph)
  assert_false(plan.get_processors().is_empty())
}
