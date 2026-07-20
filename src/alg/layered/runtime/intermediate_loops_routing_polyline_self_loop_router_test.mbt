///|
fn polyline_self_loop_router_test_chain_to_string(
  chain : @core.KVectorChain,
) -> String {
  chain.to_string()
}

///|
test "polyline self loop router cut corners usual case" {
  let input = @core.new_kvector_chain()
  input.add_xy(0.0, 0.0)
  input.add_xy(100.0, 0.0)
  input.add_xy(100.0, 100.0)
  input.add_xy(-100.0, 100.0)
  input.add_xy(-100.0, -100.0)
  input.add_xy(0.0, -100.0)

  let expected = @core.new_kvector_chain()
  expected.add_xy(90.0, 0.0)
  expected.add_xy(100.0, 10.0)
  expected.add_xy(100.0, 90.0)
  expected.add_xy(90.0, 100.0)
  expected.add_xy(-90.0, 100.0)
  expected.add_xy(-100.0, 90.0)
  expected.add_xy(-100.0, -90.0)
  expected.add_xy(-90.0, -100.0)

  let actual = polyline_self_loop_router_cut_corners(input, 10.0)
  assert_eq(
    polyline_self_loop_router_test_chain_to_string(actual),
    polyline_self_loop_router_test_chain_to_string(expected),
  )
}

///|
test "polyline self loop router cut corners smaller distance" {
  let input = @core.new_kvector_chain()
  input.add_xy(0.0, 0.0)
  input.add_xy(100.0, 0.0)
  input.add_xy(100.0, 100.0)
  input.add_xy(-100.0, 100.0)
  input.add_xy(-100.0, -100.0)
  input.add_xy(0.0, -100.0)

  let expected = @core.new_kvector_chain()
  expected.add_xy(50.0, 0.0)
  expected.add_xy(100.0, 50.0)
  expected.add_xy(100.0, 50.0)
  expected.add_xy(50.0, 100.0)
  expected.add_xy(-20.0, 100.0)
  expected.add_xy(-100.0, 20.0)
  expected.add_xy(-100.0, -50.0)
  expected.add_xy(-50.0, -100.0)

  let actual = polyline_self_loop_router_cut_corners(input, 80.0)
  assert_eq(
    polyline_self_loop_router_test_chain_to_string(actual),
    polyline_self_loop_router_test_chain_to_string(expected),
  )
}
