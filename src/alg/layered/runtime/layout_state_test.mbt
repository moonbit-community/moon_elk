///|
test "component copies share state retained by layout plan" {
  let graph = new_l_graph()
  graph.get_layout_state().initialize_random(42)

  let component = new_l_graph()
  component.copy_properties(graph)
  let plan = new_layered_layout_plan([], state=graph.get_layout_state())

  let expected = @state.new_layered_layout_state()
  expected.initialize_random(42)
  assert_eq(
    graph.get_layout_state().random(42).next_int(1000),
    expected.random(42).next_int(1000),
  )
  assert_eq(
    component.get_layout_state().random(42).next_int(1000),
    expected.random(42).next_int(1000),
  )
  assert_eq(
    plan.get_state().random(42).next_int(1000),
    expected.random(42).next_int(1000),
  )
}

///|
test "disposing graph clears per-layout state" {
  let graph = new_l_graph()
  let state = graph.get_layout_state()
  state.initialize_random(42)

  dispose_layered_graph(graph)

  assert_eq(state.first_random_boolean(), None)
}
