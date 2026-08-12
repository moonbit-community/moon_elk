///|
test "component copies share state retained by layout plan" {
  let graph = new_l_graph()
  let state = @runtime.new_layered_run_state()
  state.initialize_random(42)

  let component = new_l_graph()
  component.copy_properties(graph)
  let plan = new_layered_layout_plan(
    @core.new_layout_processor_plan([]),
    state~,
  )

  let expected = @runtime.new_layered_run_state()
  expected.initialize_random(42)
  assert_eq(
    plan.get_state().random(42).next_int(1000),
    expected.random(42).next_int(1000),
  )
  assert_eq(component.get_id(), graph.get_id())
}

///|
test "disposing graph does not own per-layout state" {
  let graph = new_l_graph()
  let state = @runtime.new_layered_run_state()
  state.initialize_random(42)

  dispose_layered_graph(graph)

  assert_true(state.first_random_boolean() is Some(_))
  state.clear()
  assert_eq(state.first_random_boolean(), None)
}
