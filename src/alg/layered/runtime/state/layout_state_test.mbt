///|
test "layout state resets deterministic random sequence" {
  let state = new_layered_layout_state()
  state.initialize_random(42)
  let first = state.random(42).next_int(1000)
  assert_eq(state.first_random_boolean(), Some(true))

  state.clear()
  assert_eq(state.first_random_boolean(), None)

  state.initialize_random(42)
  assert_eq(state.random(42).next_int(1000), first)
}
